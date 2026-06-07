-- Rename top-level vehicles root: السيارات → المركبات (slug stays `cars`).
UPDATE public.categories
SET name_ar = 'المركبات'
WHERE slug = 'cars' AND parent_id IS NULL;
