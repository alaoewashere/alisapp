-- Fix missing logo_url for مركبات تجارية (veh_commercial) brands.
-- SVG brands: run `dart run scripts/upload_logos.dart --only=DAF,Foton,Dongfeng,...`
-- PNG fallbacks below (no reliable Wikipedia SVG on Commons).

UPDATE public.categories
SET logo_url = 'https://www.carlogos.org/car-logos/king-long-logo.png'
WHERE slug = 'veh_comm_br_king_long';

UPDATE public.categories
SET logo_url = 'https://www.carlogos.org/car-logos/yutong-logo.png'
WHERE slug = 'veh_comm_br_yutong';

UPDATE public.categories
SET logo_url = 'https://www.carlogos.org/car-logos/faw-logo.png'
WHERE slug = 'veh_comm_br_faw';

UPDATE public.categories
SET logo_url = 'https://www.carlogos.org/car-logos/scania-logo.png'
WHERE slug = 'veh_comm_br_scania';

-- Jinbei: no reliable public SVG/PNG source found; letter fallback remains.
