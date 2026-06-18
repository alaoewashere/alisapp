-- Content moderation: blocked_words, violation tracking, server-side enforcement.

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.blocked_words (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word TEXT NOT NULL,
  normalized_form TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'high'
    CHECK (severity IN ('low', 'medium', 'high')),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users (id) ON DELETE SET NULL,
  CONSTRAINT blocked_words_normalized_form_key UNIQUE (normalized_form)
);

CREATE INDEX IF NOT EXISTS blocked_words_active_idx
  ON public.blocked_words (active)
  WHERE active = TRUE;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS moderation_violation_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_moderation_violation_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.moderation_violations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  source TEXT NOT NULL,
  field_name TEXT,
  original_excerpt TEXT,
  action TEXT NOT NULL CHECK (action IN ('censored', 'blocked')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS moderation_violations_user_idx
  ON public.moderation_violations (user_id, created_at DESC);

-- Placeholder test words — replace via admin panel with real dialect terms.
INSERT INTO public.blocked_words (word, normalized_form, severity, active)
VALUES
  ('testbadword1', 'testbadword1', 'high', TRUE),
  ('testbadword2', 'testbadword2', 'high', TRUE),
  ('testbadword3', 'testbadword3', 'medium', TRUE)
ON CONFLICT (normalized_form) DO NOTHING;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
ALTER TABLE public.blocked_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_violations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated read active blocked words" ON public.blocked_words;
CREATE POLICY "Authenticated read active blocked words"
  ON public.blocked_words FOR SELECT
  TO authenticated
  USING (active = TRUE);

DROP POLICY IF EXISTS "Admins manage blocked words" ON public.blocked_words;
CREATE POLICY "Admins manage blocked words"
  ON public.blocked_words FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Users read own moderation violations" ON public.moderation_violations;
CREATE POLICY "Users read own moderation violations"
  ON public.moderation_violations FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins read moderation violations" ON public.moderation_violations;
CREATE POLICY "Admins read moderation violations"
  ON public.moderation_violations FOR SELECT
  TO authenticated
  USING (public.is_admin());

GRANT SELECT ON public.blocked_words TO authenticated;
GRANT SELECT ON public.moderation_violations TO authenticated;

-- ---------------------------------------------------------------------------
-- Normalization (mirrors lib/core/utils/arabic_text_normalizer.dart)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.normalize_arabic_for_moderation(p_text TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
DECLARE
  v TEXT := COALESCE(p_text, '');
  ch TEXT;
  prev TEXT := '';
  out TEXT := '';
  i INT;
BEGIN
  v := lower(v);
  -- Strip Arabic diacritics / tashkeel
  v := regexp_replace(v, '[\u064B-\u065F\u0670]', '', 'g');
  -- Letter variants
  v := translate(v, 'أإآٱةىؤئ', 'ااااهيوي');
  -- Keep letters and digits only for matching
  FOR i IN 1..length(v) LOOP
    ch := substr(v, i, 1);
    IF ch ~ '^[[:alnum:]]$' OR ch ~ '[ء-ي]' THEN
      IF ch = prev AND length(out) >= 2 AND substr(out, length(out), 1) = ch
         AND substr(out, length(out) - 1, 1) = ch THEN
        CONTINUE;
      END IF;
      out := out || ch;
      prev := ch;
    ELSE
      prev := '';
    END IF;
  END LOOP;
  RETURN out;
END;
$$;

GRANT EXECUTE ON FUNCTION public.normalize_arabic_for_moderation(TEXT) TO authenticated;

-- Flexible pattern: optional spaces/punctuation between letters (filter evasion).
CREATE OR REPLACE FUNCTION public.blocked_word_flexible_pattern(p_word TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
DECLARE
  norm TEXT := public.normalize_arabic_for_moderation(p_word);
  ch TEXT;
  parts TEXT[] := ARRAY[]::TEXT[];
  i INT;
BEGIN
  IF norm IS NULL OR norm = '' THEN
    RETURN NULL;
  END IF;
  FOR i IN 1..length(norm) LOOP
    ch := substr(norm, i, 1);
    IF ch ~ '[^\w]' THEN
      parts := parts || regexp_replace(ch, '([\\.*+?^${}()|\[\]])', '\\\1', 'g');
    ELSE
      parts := parts || ch;
    END IF;
  END LOOP;
  RETURN array_to_string(parts, '[[:space:][:punct:]]*');
END;
$$;

-- Pure detect + censor (no violation side effects).
CREATE OR REPLACE FUNCTION public.moderate_text_content(p_text TEXT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_original TEXT := COALESCE(p_text, '');
  v_normalized TEXT;
  v_censored TEXT := v_original;
  v_had_violation BOOLEAN := FALSE;
  bw RECORD;
  v_pattern TEXT;
BEGIN
  IF v_original = '' THEN
    RETURN jsonb_build_object(
      'censored_text', v_original,
      'had_violation', FALSE
    );
  END IF;

  v_normalized := public.normalize_arabic_for_moderation(v_original);

  FOR bw IN
    SELECT normalized_form, word
    FROM public.blocked_words
    WHERE active = TRUE
  LOOP
    IF position(bw.normalized_form IN v_normalized) > 0 THEN
      v_had_violation := TRUE;
      v_pattern := public.blocked_word_flexible_pattern(bw.word);
      IF v_pattern IS NOT NULL AND v_pattern <> '' THEN
        v_censored := regexp_replace(
          v_censored,
          v_pattern,
          repeat('*', GREATEST(length(bw.word), 3)),
          'gi'
        );
      END IF;
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'censored_text', v_censored,
    'had_violation', v_had_violation
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.moderate_text_content(TEXT) TO authenticated;

-- Single-field moderation with violation accounting (chat, profile).
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
  v_count INT := 0;
  v_had_violation BOOLEAN;
  v_should_block BOOLEAN := FALSE;
  v_action TEXT := 'allowed';
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

  SELECT COALESCE(moderation_violation_count, 0)
  INTO v_count
  FROM public.profiles
  WHERE id = p_user_id;

  IF v_count > 0 THEN
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

  RETURN jsonb_build_object(
    'censored_text', CASE
      WHEN v_should_block THEN v_original
      ELSE r->>'censored_text'
    END,
    'had_violation', TRUE,
    'should_block', v_should_block,
    'action', v_action
  );
END;
$$;

REVOKE ALL ON FUNCTION public.apply_content_moderation(UUID, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.apply_content_moderation(UUID, TEXT, TEXT, TEXT) TO authenticated;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
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

DROP TRIGGER IF EXISTS trg_messages_content_moderation ON public.messages;
CREATE TRIGGER trg_messages_content_moderation
  BEFORE INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_message_moderation();

CREATE OR REPLACE FUNCTION public.enforce_listing_moderation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r JSONB;
  v_user UUID := NEW.user_id;
  v_count INT := 0;
  v_had_any BOOLEAN := FALSE;
  v_should_block BOOLEAN := FALSE;
  v_action TEXT;
BEGIN
  IF public.is_admin() THEN
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

  SELECT COALESCE(moderation_violation_count, 0)
  INTO v_count
  FROM public.profiles
  WHERE id = v_user;

  IF v_count > 0 THEN
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

DROP TRIGGER IF EXISTS trg_listings_content_moderation ON public.listings;
CREATE TRIGGER trg_listings_content_moderation
  BEFORE INSERT OR UPDATE ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_listing_moderation();

CREATE OR REPLACE FUNCTION public.enforce_profile_moderation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r JSONB;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.full_name IS NOT DISTINCT FROM OLD.full_name
       AND NEW.display_name IS NOT DISTINCT FROM OLD.display_name THEN
      RETURN NEW;
    END IF;
  END IF;

  IF NEW.full_name IS NOT NULL AND NEW.full_name <> '' THEN
    r := public.apply_content_moderation(NEW.id, NEW.full_name, 'profile', 'full_name');
    IF (r->>'should_block')::BOOLEAN THEN
      RAISE EXCEPTION 'content_moderation_blocked' USING ERRCODE = 'P0001';
    END IF;
    IF (r->>'had_violation')::BOOLEAN THEN
      NEW.full_name := r->>'censored_text';
      NEW.display_name := r->>'censored_text';
    END IF;
  ELSIF NEW.display_name IS NOT NULL AND NEW.display_name <> '' THEN
    r := public.apply_content_moderation(NEW.id, NEW.display_name, 'profile', 'display_name');
    IF (r->>'should_block')::BOOLEAN THEN
      RAISE EXCEPTION 'content_moderation_blocked' USING ERRCODE = 'P0001';
    END IF;
    IF (r->>'had_violation')::BOOLEAN THEN NEW.display_name := r->>'censored_text'; END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_content_moderation ON public.profiles;
CREATE TRIGGER trg_profiles_content_moderation
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_profile_moderation();
