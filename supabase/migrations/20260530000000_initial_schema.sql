-- Souq IQ — initial schema, RLS, seeds
-- Run via Supabase CLI or SQL Editor after project creation

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Profiles (linked to auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT,
  display_name TEXT NOT NULL DEFAULT '',
  city TEXT,
  governorate TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Categories
CREATE TABLE public.categories (
  id SERIAL PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name_ar TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'category'
);

-- Listings
CREATE TYPE public.listing_status AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE public.listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id INT NOT NULL REFERENCES public.categories(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price_iqd BIGINT NOT NULL CHECK (price_iqd >= 0),
  city TEXT NOT NULL,
  governorate TEXT NOT NULL,
  status public.listing_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, ''))
  ) STORED
);

CREATE INDEX listings_search_idx ON public.listings USING GIN (search_vector);
CREATE INDEX listings_status_created_idx ON public.listings (status, created_at DESC);
CREATE INDEX listings_category_idx ON public.listings (category_id);
CREATE INDEX listings_governorate_idx ON public.listings (governorate);
CREATE INDEX listings_price_idx ON public.listings (price_iqd);

-- Listing images
CREATE TABLE public.listing_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX listing_images_listing_idx ON public.listing_images (listing_id, sort_order);

-- Favorites
CREATE TABLE public.favorites (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, listing_id)
);

-- Conversations (1:1 per listing per buyer)
CREATE TABLE public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_message_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (listing_id, buyer_id)
);

CREATE INDEX conversations_buyer_idx ON public.conversations (buyer_id, last_message_at DESC);
CREATE INDEX conversations_seller_idx ON public.conversations (seller_id, last_message_at DESC);

-- Messages
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body TEXT NOT NULL CHECK (char_length(body) > 0 AND char_length(body) <= 2000),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX messages_conversation_idx ON public.messages (conversation_id, created_at);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, phone, display_name)
  VALUES (
    NEW.id,
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'display_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update conversation last_message_at on new message
CREATE OR REPLACE FUNCTION public.update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_message_created
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_conversation_timestamp();

-- updated_at trigger
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER listings_updated_at BEFORE UPDATE ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Seed categories
INSERT INTO public.categories (slug, name_ar, icon) VALUES
  ('real_estate', 'عقارات', 'home'),
  ('cars', 'سيارات', 'directions_car'),
  ('electronics', 'إلكترونيات', 'devices'),
  ('jobs', 'وظائف', 'work'),
  ('services', 'خدمات', 'handyman');

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "Profiles are publicly readable"
  ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Categories (public read)
CREATE POLICY "Categories are publicly readable"
  ON public.categories FOR SELECT USING (true);

-- Listings
CREATE POLICY "Public read approved listings"
  ON public.listings FOR SELECT USING (status = 'approved');

CREATE POLICY "Owners read own listings"
  ON public.listings FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users create listings"
  ON public.listings FOR INSERT WITH CHECK (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Owners update own pending listings"
  ON public.listings FOR UPDATE USING (auth.uid() = user_id AND status IN ('pending', 'rejected'));

CREATE POLICY "Owners delete own listings"
  ON public.listings FOR DELETE USING (auth.uid() = user_id);

-- Listing images
CREATE POLICY "Public read listing images for approved listings"
  ON public.listing_images FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.listings l
      WHERE l.id = listing_id
      AND (l.status = 'approved' OR l.user_id = auth.uid())
    )
  );

CREATE POLICY "Owners manage listing images"
  ON public.listing_images FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.listings l
      WHERE l.id = listing_id AND l.user_id = auth.uid()
    )
  );

-- Favorites
CREATE POLICY "Users manage own favorites"
  ON public.favorites FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users read favorites join data"
  ON public.favorites FOR SELECT USING (auth.uid() = user_id);

-- Conversations
CREATE POLICY "Participants read conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Buyers create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() = buyer_id AND buyer_id != seller_id);

-- Messages
CREATE POLICY "Participants read messages"
  ON public.messages FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
    )
  );

CREATE POLICY "Participants send messages"
  ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM public.conversations c
      WHERE c.id = conversation_id
      AND (c.buyer_id = auth.uid() OR c.seller_id = auth.uid())
    )
  );

-- Storage bucket (run in Supabase dashboard or via API)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('listing-images', 'listing-images', true);

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
