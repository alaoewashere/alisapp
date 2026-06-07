-- Souq IQ — schema extensions (skips objects from 000000 / 000001 / 000002)
-- Adds: governorates, reports, boosts + missing columns, indexes, RLS, Realtime

-- ---------------------------------------------------------------------------
-- ENUM types (new)
-- ---------------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE public.listing_condition AS ENUM ('new', 'used');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.listing_availability AS ENUM ('active', 'sold', 'deleted');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE public.boost_type AS ENUM ('featured', 'boosted', 'urgent');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ---------------------------------------------------------------------------
-- profiles — extend (table exists)
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS full_name TEXT,
  ADD COLUMN IF NOT EXISTS avatar_url TEXT,
  ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE public.profiles
SET full_name = display_name
WHERE full_name IS NULL AND display_name <> '';

CREATE INDEX IF NOT EXISTS profiles_city_idx ON public.profiles (city);

-- Keep full_name in sync with display_name for Google OAuth signups
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  resolved_name TEXT;
BEGIN
  resolved_name := COALESCE(
    NEW.raw_user_meta_data->>'display_name',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''),
    ''
  );

  INSERT INTO public.profiles (id, phone, display_name, full_name)
  VALUES (NEW.id, NEW.phone, resolved_name, resolved_name)
  ON CONFLICT (id) DO UPDATE
    SET full_name = COALESCE(public.profiles.full_name, EXCLUDED.full_name),
        display_name = CASE
          WHEN public.profiles.display_name = '' THEN EXCLUDED.display_name
          ELSE public.profiles.display_name
        END;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.sync_profile_names()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.full_name IS NOT NULL AND NEW.full_name <> '' AND NEW.display_name = '' THEN
    NEW.display_name := NEW.full_name;
  ELSIF NEW.display_name IS NOT NULL AND NEW.display_name <> '' AND NEW.full_name IS NULL THEN
    NEW.full_name := NEW.display_name;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS profiles_sync_names ON public.profiles;
CREATE TRIGGER profiles_sync_names
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.sync_profile_names();

-- ---------------------------------------------------------------------------
-- categories — extend (table exists)
-- ---------------------------------------------------------------------------
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS name_ku TEXT,
  ADD COLUMN IF NOT EXISTS name_en TEXT,
  ADD COLUMN IF NOT EXISTS parent_id INT REFERENCES public.categories(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS categories_parent_idx ON public.categories (parent_id);

-- Backfill English names for seeded categories
UPDATE public.categories SET name_en = 'Real Estate' WHERE slug = 'real_estate' AND name_en IS NULL;
UPDATE public.categories SET name_en = 'Cars'          WHERE slug = 'cars'         AND name_en IS NULL;
UPDATE public.categories SET name_en = 'Electronics'    WHERE slug = 'electronics'  AND name_en IS NULL;
UPDATE public.categories SET name_en = 'Jobs'           WHERE slug = 'jobs'         AND name_en IS NULL;
UPDATE public.categories SET name_en = 'Services'      WHERE slug = 'services'     AND name_en IS NULL;

-- ---------------------------------------------------------------------------
-- listings — extend (table exists)
-- App uses: title, description, price_iqd, status (pending|approved|rejected)
-- Spec adds: title_ar, description_ar, price, currency, condition, geo, boosts, expires_at
-- Lifecycle: availability (active|sold|deleted) separate from moderation status
-- ---------------------------------------------------------------------------
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS title_ar TEXT,
  ADD COLUMN IF NOT EXISTS description_ar TEXT,
  ADD COLUMN IF NOT EXISTS price BIGINT,
  ADD COLUMN IF NOT EXISTS currency TEXT NOT NULL DEFAULT 'IQD',
  ADD COLUMN IF NOT EXISTS is_negotiable BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS condition public.listing_condition,
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS availability public.listing_availability NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS views_count INT NOT NULL DEFAULT 0 CHECK (views_count >= 0),
  ADD COLUMN IF NOT EXISTS is_featured BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_boosted BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ;

UPDATE public.listings
SET
  title_ar = title,
  description_ar = description,
  price = price_iqd
WHERE title_ar IS NULL OR description_ar IS NULL OR price IS NULL;

CREATE OR REPLACE FUNCTION public.sync_listing_bilingual_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title_ar IS NULL OR NEW.title_ar = '' THEN
    NEW.title_ar := NEW.title;
  END IF;
  IF NEW.description_ar IS NULL THEN
    NEW.description_ar := NEW.description;
  END IF;
  IF NEW.price IS NULL THEN
    NEW.price := NEW.price_iqd;
  END IF;
  IF NEW.price_iqd IS NULL OR NEW.price_iqd = 0 THEN
    NEW.price_iqd := COALESCE(NEW.price, 0);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS listings_sync_bilingual ON public.listings;
CREATE TRIGGER listings_sync_bilingual
  BEFORE INSERT OR UPDATE ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.sync_listing_bilingual_fields();

CREATE INDEX IF NOT EXISTS listings_city_idx ON public.listings (city);
CREATE INDEX IF NOT EXISTS listings_user_id_idx ON public.listings (user_id);
CREATE INDEX IF NOT EXISTS listings_created_at_idx ON public.listings (created_at DESC);
CREATE INDEX IF NOT EXISTS listings_featured_idx ON public.listings (is_featured, created_at DESC)
  WHERE is_featured = TRUE;
CREATE INDEX IF NOT EXISTS listings_boosted_idx ON public.listings (is_boosted, created_at DESC)
  WHERE is_boosted = TRUE;

-- Refresh public-read policy to exclude sold/deleted listings
DROP POLICY IF EXISTS "Public read approved listings" ON public.listings;
CREATE POLICY "Public read approved listings"
  ON public.listings FOR SELECT
  USING (status = 'approved' AND availability = 'active');

DROP POLICY IF EXISTS "Owners update own pending listings" ON public.listings;
CREATE POLICY "Owners update own listings"
  ON public.listings FOR UPDATE
  USING (
    auth.uid() = user_id
    AND (
      status IN ('pending', 'rejected')
      OR (status = 'approved' AND availability IN ('active', 'sold', 'deleted'))
    )
  );

-- ---------------------------------------------------------------------------
-- listing_images — extend (table exists)
-- App uses storage_path + sort_order; spec adds url, order, is_primary
-- ---------------------------------------------------------------------------
ALTER TABLE public.listing_images
  ADD COLUMN IF NOT EXISTS url TEXT,
  ADD COLUMN IF NOT EXISTS "order" INT,
  ADD COLUMN IF NOT EXISTS is_primary BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE public.listing_images
SET
  "order" = sort_order,
  url = storage_path
WHERE "order" IS NULL OR url IS NULL;

CREATE OR REPLACE FUNCTION public.sync_listing_image_fields()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW."order" IS NULL THEN
    NEW."order" := NEW.sort_order;
  END IF;
  IF NEW.sort_order IS NULL OR NEW.sort_order = 0 THEN
    NEW.sort_order := COALESCE(NEW."order", 0);
  END IF;
  IF NEW.url IS NULL OR NEW.url = '' THEN
    NEW.url := NEW.storage_path;
  END IF;
  IF NEW.storage_path IS NULL OR NEW.storage_path = '' THEN
    NEW.storage_path := COALESCE(NEW.url, '');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS listing_images_sync_fields ON public.listing_images;
CREATE TRIGGER listing_images_sync_fields
  BEFORE INSERT OR UPDATE ON public.listing_images
  FOR EACH ROW EXECUTE FUNCTION public.sync_listing_image_fields();

CREATE INDEX IF NOT EXISTS listing_images_primary_idx
  ON public.listing_images (listing_id, is_primary)
  WHERE is_primary = TRUE;

-- ---------------------------------------------------------------------------
-- favorites — extend (table exists; composite PK kept for app compat)
-- ---------------------------------------------------------------------------
ALTER TABLE public.favorites
  ADD COLUMN IF NOT EXISTS id UUID DEFAULT gen_random_uuid();

UPDATE public.favorites SET id = gen_random_uuid() WHERE id IS NULL;

ALTER TABLE public.favorites
  ALTER COLUMN id SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS favorites_id_idx ON public.favorites (id);
CREATE INDEX IF NOT EXISTS favorites_user_id_idx ON public.favorites (user_id);
CREATE INDEX IF NOT EXISTS favorites_listing_id_idx ON public.favorites (listing_id);
CREATE INDEX IF NOT EXISTS favorites_created_at_idx ON public.favorites (created_at DESC);

-- ---------------------------------------------------------------------------
-- messages — extend (table exists; app uses body)
-- ---------------------------------------------------------------------------
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS content TEXT,
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE public.messages SET content = body WHERE content IS NULL;

CREATE OR REPLACE FUNCTION public.sync_message_content()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.content IS NULL OR NEW.content = '' THEN
    NEW.content := NEW.body;
  END IF;
  IF NEW.body IS NULL OR NEW.body = '' THEN
    NEW.body := COALESCE(NEW.content, '');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS messages_sync_content ON public.messages;
CREATE TRIGGER messages_sync_content
  BEFORE INSERT OR UPDATE ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.sync_message_content();

CREATE INDEX IF NOT EXISTS messages_is_read_idx
  ON public.messages (conversation_id, is_read)
  WHERE is_read = FALSE;

DROP POLICY IF EXISTS "Participants send messages" ON public.messages;
CREATE POLICY "Participants send messages"
  ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
    )
  );

CREATE POLICY "Participants mark messages read"
  ON public.messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
    )
  );

-- ---------------------------------------------------------------------------
-- governorates — NEW
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.governorates (
  id SERIAL PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name_ar TEXT NOT NULL,
  name_ku TEXT,
  name_en TEXT NOT NULL
);

INSERT INTO public.governorates (slug, name_ar, name_ku, name_en) VALUES
  ('baghdad',     'بغداد',       'بەغدا',           'Baghdad'),
  ('basra',       'البصرة',      'بەسرە',           'Basra'),
  ('nineveh',     'نينوى',       'نەینەوا',         'Nineveh'),
  ('erbil',       'أربيل',       'هەولێر',          'Erbil'),
  ('sulaymaniyah','السليمانية',  'سلێمانی',         'Sulaymaniyah'),
  ('duhok',       'دهوك',        'دهۆک',            'Duhok'),
  ('kirkuk',      'كركوك',       'کەرکوک',          'Kirkuk'),
  ('anbar',       'الأنبار',     'ئەنبار',          'Anbar'),
  ('babil',       'بابل',        'بابل',            'Babil'),
  ('diyala',      'ديالى',       'دیالە',           'Diyala'),
  ('karbala',     'كربلاء',      'کەربەلا',         'Karbala'),
  ('najaf',       'النجف',       'نجف',             'Najaf'),
  ('wasit',       'واسط',        'واسط',            'Wasit'),
  ('maysan',      'ميسان',       'میسان',           'Maysan'),
  ('dhi_qar',     'ذي قار',      'ذی قار',          'Dhi Qar'),
  ('muthanna',    'المثنى',      'المثنى',          'Muthanna'),
  ('qadisiyyah',  'القادسية',    'قادسیە',          'Qadisiyyah'),
  ('saladin',     'صلاح الدين',  'سەلاحەددین',      'Saladin')
ON CONFLICT (slug) DO NOTHING;

ALTER TABLE public.governorates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Governorates are publicly readable" ON public.governorates;
CREATE POLICY "Governorates are publicly readable"
  ON public.governorates FOR SELECT
  USING (true);

CREATE INDEX IF NOT EXISTS governorates_name_ar_idx ON public.governorates (name_ar);

-- ---------------------------------------------------------------------------
-- reports — NEW
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (char_length(trim(reason)) >= 3),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (listing_id, reporter_id)
);

CREATE INDEX IF NOT EXISTS reports_listing_id_idx ON public.reports (listing_id);
CREATE INDEX IF NOT EXISTS reports_reporter_id_idx ON public.reports (reporter_id);
CREATE INDEX IF NOT EXISTS reports_created_at_idx ON public.reports (created_at DESC);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users create reports" ON public.reports;
CREATE POLICY "Authenticated users create reports"
  ON public.reports FOR INSERT
  WITH CHECK (
    auth.uid() = reporter_id
    AND auth.uid() IS NOT NULL
    AND NOT EXISTS (
      SELECT 1 FROM public.listings l
      WHERE l.id = listing_id AND l.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users read own reports" ON public.reports;
CREATE POLICY "Users read own reports"
  ON public.reports FOR SELECT
  USING (auth.uid() = reporter_id);

-- ---------------------------------------------------------------------------
-- boosts — NEW (monetization)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.boosts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type public.boost_type NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  amount_paid BIGINT NOT NULL DEFAULT 0 CHECK (amount_paid >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (expires_at > started_at)
);

CREATE INDEX IF NOT EXISTS boosts_listing_id_idx ON public.boosts (listing_id);
CREATE INDEX IF NOT EXISTS boosts_user_id_idx ON public.boosts (user_id);
CREATE INDEX IF NOT EXISTS boosts_expires_at_idx ON public.boosts (listing_id, expires_at DESC);

ALTER TABLE public.boosts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Owners read own boosts" ON public.boosts;
CREATE POLICY "Owners read own boosts"
  ON public.boosts FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public read active boosts on approved listings" ON public.boosts;
CREATE POLICY "Public read active boosts on approved listings"
  ON public.boosts FOR SELECT
  USING (
    expires_at > NOW()
    AND EXISTS (
      SELECT 1 FROM public.listings l
      WHERE l.id = listing_id
      AND l.status = 'approved'
      AND l.availability = 'active'
    )
  );

DROP POLICY IF EXISTS "Listing owners purchase boosts" ON public.boosts;
CREATE POLICY "Listing owners purchase boosts"
  ON public.boosts FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.listings l
      WHERE l.id = listing_id
      AND l.user_id = auth.uid()
    )
  );

-- Sync is_featured / is_boosted flags when boost rows are inserted
CREATE OR REPLACE FUNCTION public.apply_listing_boost_flags()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.type = 'featured' THEN
    UPDATE public.listings SET is_featured = TRUE WHERE id = NEW.listing_id;
  ELSIF NEW.type IN ('boosted', 'urgent') THEN
    UPDATE public.listings SET is_boosted = TRUE WHERE id = NEW.listing_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_boost_created ON public.boosts;
CREATE TRIGGER on_boost_created
  AFTER INSERT ON public.boosts
  FOR EACH ROW EXECUTE FUNCTION public.apply_listing_boost_flags();

-- ---------------------------------------------------------------------------
-- Realtime (messages already added in 000000; add conversations)
-- Storage bucket listing-images already in 000001 — skipped
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'conversations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
  END IF;
END $$;
