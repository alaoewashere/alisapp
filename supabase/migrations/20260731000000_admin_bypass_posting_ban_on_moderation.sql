-- Admin dashboard uses service_role (auth.uid() is NULL). Skip posting-ban and
-- content moderation for privileged callers, and for updates that do not touch
-- listing text (e.g. soft-delete via availability = 'deleted').

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

  IF public.is_privileged_backend_caller() THEN
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
  IF public.is_privileged_backend_caller() THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF NEW.title IS NOT DISTINCT FROM OLD.title
       AND NEW.title_ar IS NOT DISTINCT FROM OLD.title_ar
       AND NEW.description IS NOT DISTINCT FROM OLD.description
       AND NEW.description_ar IS NOT DISTINCT FROM OLD.description_ar THEN
      RETURN NEW;
    END IF;
  END IF;

  IF public.is_user_posting_banned(v_user) THEN
    RAISE EXCEPTION 'user_posting_banned: %',
      public.posting_ban_message_ar(v_user)
      USING ERRCODE = 'P0001';
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
