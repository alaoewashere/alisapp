-- Posting bans (chat + listings) with escalating auto-ban on profanity blocks.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_banned BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS banned_until TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS ban_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS ban_reason TEXT,
  ADD COLUMN IF NOT EXISTS banned_by UUID REFERENCES auth.users (id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS profiles_posting_ban_idx
  ON public.profiles (is_banned, banned_until)
  WHERE is_banned = TRUE;

-- Violation count within rolling 30-day window (warn vs block).
CREATE OR REPLACE FUNCTION public.effective_moderation_violation_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT CASE
    WHEN p.last_moderation_violation_at IS NULL THEN 0
    WHEN p.last_moderation_violation_at < NOW() - INTERVAL '30 days' THEN 0
    ELSE COALESCE(p.moderation_violation_count, 0)
  END
  FROM public.profiles p
  WHERE p.id = p_user_id;
$$;

GRANT EXECUTE ON FUNCTION public.effective_moderation_violation_count(UUID) TO authenticated;

-- Active posting ban (expired timed bans are ignored at check time).
CREATE OR REPLACE FUNCTION public.is_user_posting_banned(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (
      SELECT p.is_banned
        AND (p.banned_until IS NULL OR p.banned_until > NOW())
      FROM public.profiles p
      WHERE p.id = p_user_id
    ),
    FALSE
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_user_posting_banned(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.posting_ban_message_ar(p_user_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_until TIMESTAMPTZ;
  v_is_banned BOOLEAN;
BEGIN
  SELECT p.is_banned, p.banned_until
  INTO v_is_banned, v_until
  FROM public.profiles p
  WHERE p.id = p_user_id;

  IF NOT COALESCE(v_is_banned, FALSE)
     OR (v_until IS NOT NULL AND v_until <= NOW()) THEN
    RETURN '';
  END IF;

  IF v_until IS NULL THEN
    RETURN 'أنت محظور بشكل دائم من الدردشة والنشر';
  END IF;

  RETURN 'أنت محظور من الدردشة والنشر حتى '
    || to_char(v_until AT TIME ZONE 'Asia/Baghdad', 'YYYY-MM-DD HH24:MI');
END;
$$;

GRANT EXECUTE ON FUNCTION public.posting_ban_message_ar(UUID) TO authenticated;

-- Escalating auto-ban: 2 days first lifetime ban, 1 month thereafter.
CREATE OR REPLACE FUNCTION public.apply_auto_profanity_ban(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ban_count INT := 0;
  v_until TIMESTAMPTZ;
  v_is_first BOOLEAN;
BEGIN
  SELECT COALESCE(ban_count, 0)
  INTO v_ban_count
  FROM public.profiles
  WHERE id = p_user_id;

  v_is_first := v_ban_count = 0;

  IF v_is_first THEN
    v_until := NOW() + INTERVAL '2 days';
  ELSE
    v_until := NOW() + INTERVAL '1 month';
  END IF;

  UPDATE public.profiles
  SET
    is_banned = TRUE,
    banned_until = v_until,
    ban_reason = 'profanity_auto',
    banned_by = NULL,
    ban_count = ban_count + 1
  WHERE id = p_user_id;

  RETURN jsonb_build_object(
    'is_first_ban', v_is_first,
    'banned_until', v_until,
    'is_permanent', FALSE,
    'ban_count', v_ban_count + 1
  );
END;
$$;

REVOKE ALL ON FUNCTION public.apply_auto_profanity_ban(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.apply_auto_profanity_ban(UUID) TO authenticated;

-- Client-callable when local moderation blocks before insert.
CREATE OR REPLACE FUNCTION public.record_moderation_block(
  p_source TEXT,
  p_field_name TEXT DEFAULT NULL,
  p_excerpt TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_effective INT;
  v_ban JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = 'P0001';
  END IF;

  IF public.is_user_posting_banned(v_user) THEN
    RAISE EXCEPTION 'user_posting_banned: %',
      public.posting_ban_message_ar(v_user)
      USING ERRCODE = 'P0001';
  END IF;

  v_effective := public.effective_moderation_violation_count(v_user);

  IF v_effective <= 0 THEN
    RAISE EXCEPTION 'invalid_moderation_block' USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.profiles
  SET
    moderation_violation_count = moderation_violation_count + 1,
    last_moderation_violation_at = NOW()
  WHERE id = v_user;

  INSERT INTO public.moderation_violations (
    user_id, source, field_name, original_excerpt, action
  ) VALUES (
    v_user,
    p_source,
    p_field_name,
    left(COALESCE(p_excerpt, ''), 120),
    'blocked'
  );

  v_ban := public.apply_auto_profanity_ban(v_user);

  RETURN v_ban || jsonb_build_object(
    'message', public.posting_ban_message_ar(v_user)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_moderation_block(TEXT, TEXT, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_posting_ban_status()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_row public.profiles%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN
    RETURN jsonb_build_object('is_banned', FALSE);
  END IF;

  SELECT * INTO v_row FROM public.profiles WHERE id = v_user;

  RETURN jsonb_build_object(
    'is_banned', public.is_user_posting_banned(v_user),
    'banned_until', v_row.banned_until,
    'is_permanent', v_row.is_banned AND v_row.banned_until IS NULL,
    'ban_count', COALESCE(v_row.ban_count, 0),
    'ban_reason', v_row.ban_reason,
    'message', public.posting_ban_message_ar(v_user),
    'effective_violation_count',
      public.effective_moderation_violation_count(v_user),
    'moderation_violation_count', COALESCE(v_row.moderation_violation_count, 0),
    'last_moderation_violation_at', v_row.last_moderation_violation_at
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_my_posting_ban_status() TO authenticated;

-- ---------------------------------------------------------------------------
-- Update moderation to use 30-day window + auto-ban on block
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.apply_content_moderation(
  p_user_id UUID,
  p_text TEXT,
  p_source TEXT,
  p_field_name TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_original TEXT := COALESCE(p_text, '');
  r JSONB;
  v_effective INT := 0;
  v_had_violation BOOLEAN;
  v_should_block BOOLEAN := FALSE;
  v_action TEXT := 'allowed';
  v_ban JSONB;
BEGIN
  IF v_original = '' OR p_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'censored_text', v_original,
      'had_violation', FALSE,
      'should_block', FALSE,
      'action', 'allowed'
    );
  END IF;

  IF public.is_admin() THEN
    RETURN jsonb_build_object(
      'censored_text', v_original,
      'had_violation', FALSE,
      'should_block', FALSE,
      'action', 'allowed'
    );
  END IF;

  IF public.is_user_posting_banned(p_user_id) THEN
    RAISE EXCEPTION 'user_posting_banned: %',
      public.posting_ban_message_ar(p_user_id)
      USING ERRCODE = 'P0001';
  END IF;

  r := public.moderate_text_content(v_original);
  v_had_violation := (r->>'had_violation')::BOOLEAN;

  IF NOT v_had_violation THEN
    RETURN jsonb_build_object(
      'censored_text', v_original,
      'had_violation', FALSE,
      'should_block', FALSE,
      'action', 'allowed'
    );
  END IF;

  v_effective := public.effective_moderation_violation_count(p_user_id);

  IF v_effective > 0 THEN
    v_should_block := TRUE;
    v_action := 'blocked';
  ELSE
    v_action := 'censored';
  END IF;

  UPDATE public.profiles
  SET
    moderation_violation_count = moderation_violation_count + 1,
    last_moderation_violation_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO public.moderation_violations (
    user_id, source, field_name, original_excerpt, action
  ) VALUES (
    p_user_id,
    p_source,
    p_field_name,
    left(v_original, 120),
    v_action
  );

  IF v_should_block THEN
    v_ban := public.apply_auto_profanity_ban(p_user_id);
    RETURN jsonb_build_object(
      'censored_text', v_original,
      'had_violation', TRUE,
      'should_block', TRUE,
      'action', 'blocked',
      'ban', v_ban
    );
  END IF;

  RETURN jsonb_build_object(
    'censored_text', r->>'censored_text',
    'had_violation', TRUE,
    'should_block', FALSE,
    'action', 'censored'
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_message_moderation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_body TEXT := COALESCE(NEW.content, NEW.body, '');
  r JSONB;
BEGIN
  IF public.is_user_posting_banned(NEW.sender_id) THEN
    RAISE EXCEPTION 'user_posting_banned: %',
      public.posting_ban_message_ar(NEW.sender_id)
      USING ERRCODE = 'P0001';
  END IF;

  r := public.apply_content_moderation(NEW.sender_id, v_body, 'chat', 'body');
  IF (r->>'should_block')::BOOLEAN THEN
    RAISE EXCEPTION 'content_moderation_blocked'
      USING ERRCODE = 'P0001';
  END IF;
  IF (r->>'had_violation')::BOOLEAN THEN
    NEW.body := r->>'censored_text';
    NEW.content := r->>'censored_text';
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.enforce_listing_moderation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r JSONB;
  v_user UUID := NEW.user_id;
  v_effective INT := 0;
  v_had_any BOOLEAN := FALSE;
  v_ban JSONB;
BEGIN
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  IF public.is_user_posting_banned(v_user) THEN
    RAISE EXCEPTION 'user_posting_banned: %',
      public.posting_ban_message_ar(v_user)
      USING ERRCODE = 'P0001';
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF NEW.title IS NOT DISTINCT FROM OLD.title
       AND NEW.title_ar IS NOT DISTINCT FROM OLD.title_ar
       AND NEW.description IS NOT DISTINCT FROM OLD.description
       AND NEW.description_ar IS NOT DISTINCT FROM OLD.description_ar THEN
      RETURN NEW;
    END IF;
  END IF;

  IF NEW.title IS NOT NULL AND NEW.title <> '' THEN
    r := public.moderate_text_content(NEW.title);
    IF (r->>'had_violation')::BOOLEAN THEN
      v_had_any := TRUE;
      NEW.title := r->>'censored_text';
    END IF;
  END IF;

  IF NEW.title_ar IS NOT NULL AND NEW.title_ar <> '' THEN
    r := public.moderate_text_content(NEW.title_ar);
    IF (r->>'had_violation')::BOOLEAN THEN
      v_had_any := TRUE;
      NEW.title_ar := r->>'censored_text';
    END IF;
  END IF;

  IF NEW.description IS NOT NULL AND NEW.description <> '' THEN
    r := public.moderate_text_content(NEW.description);
    IF (r->>'had_violation')::BOOLEAN THEN
      v_had_any := TRUE;
      NEW.description := r->>'censored_text';
    END IF;
  END IF;

  IF NEW.description_ar IS NOT NULL AND NEW.description_ar <> '' THEN
    r := public.moderate_text_content(NEW.description_ar);
    IF (r->>'had_violation')::BOOLEAN THEN
      v_had_any := TRUE;
      NEW.description_ar := r->>'censored_text';
    END IF;
  END IF;

  IF NOT v_had_any THEN
    RETURN NEW;
  END IF;

  v_effective := public.effective_moderation_violation_count(v_user);

  IF v_effective > 0 THEN
    UPDATE public.profiles
    SET
      moderation_violation_count = moderation_violation_count + 1,
      last_moderation_violation_at = NOW()
    WHERE id = v_user;

    INSERT INTO public.moderation_violations (
      user_id, source, field_name, original_excerpt, action
    ) VALUES (
      v_user,
      'listing',
      'title/description',
      left(COALESCE(NEW.title_ar, NEW.title, ''), 120),
      'blocked'
    );

    PERFORM public.apply_auto_profanity_ban(v_user);
    RAISE EXCEPTION 'content_moderation_blocked' USING ERRCODE = 'P0001';
  END IF;

  UPDATE public.profiles
  SET
    moderation_violation_count = moderation_violation_count + 1,
    last_moderation_violation_at = NOW()
  WHERE id = v_user;

  INSERT INTO public.moderation_violations (
    user_id, source, field_name, original_excerpt, action
  ) VALUES (
    v_user,
    'listing',
    'title/description',
    left(COALESCE(NEW.title_ar, NEW.title, ''), 120),
    'censored'
  );

  RETURN NEW;
END;
$$;
