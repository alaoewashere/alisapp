-- Fix broken Wikipedia SVG logo_url for سيارات كلاسيكية (veh_classic) brands.
-- Stale Commons hashes return 404; PNGs uploaded to brand-logos bucket.

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/dodge.png'
WHERE slug = 'veh_classic_br_dodge';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/rolls-royce.png'
WHERE slug = 'veh_classic_br_rolls_royce';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/cadillac.png'
WHERE slug = 'veh_classic_br_cadillac';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/alfa-romeo.png'
WHERE slug = 'veh_classic_br_alfa_romeo';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/ferrari.png'
WHERE slug = 'veh_classic_br_ferrari';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/lincoln.png'
WHERE slug = 'veh_classic_br_lincoln';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/pontiac.png'
WHERE slug = 'veh_classic_br_pontiac';

UPDATE public.categories
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/oldsmobile.png'
WHERE slug = 'veh_classic_br_oldsmobile';
