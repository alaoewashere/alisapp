-- Real trim/engine dropdown options for the most common car brands in Iraq's
-- market. Other brands fall back to a generic list on the client.
CREATE TABLE IF NOT EXISTS public.vehicle_trim_options (
  id SERIAL PRIMARY KEY,
  brand_slug TEXT NOT NULL,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.vehicle_engine_options (
  id SERIAL PRIMARY KEY,
  brand_slug TEXT NOT NULL,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS vehicle_trim_options_brand_idx
  ON public.vehicle_trim_options (brand_slug, sort_order);
CREATE INDEX IF NOT EXISTS vehicle_engine_options_brand_idx
  ON public.vehicle_engine_options (brand_slug, sort_order);

ALTER TABLE public.vehicle_trim_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicle_engine_options ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.vehicle_trim_options TO anon, authenticated;
GRANT SELECT ON public.vehicle_engine_options TO anon, authenticated;

DROP POLICY IF EXISTS "Anyone reads trim options" ON public.vehicle_trim_options;
CREATE POLICY "Anyone reads trim options"
  ON public.vehicle_trim_options FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone reads engine options" ON public.vehicle_engine_options;
CREATE POLICY "Anyone reads engine options"
  ON public.vehicle_engine_options FOR SELECT USING (true);

-- Idempotent reseed.
DELETE FROM public.vehicle_trim_options;
DELETE FROM public.vehicle_engine_options;

INSERT INTO public.vehicle_trim_options (brand_slug, name, sort_order) VALUES
  ('veh_auto_br_toyota', 'L', 1), ('veh_auto_br_toyota', 'LE', 2), ('veh_auto_br_toyota', 'SE', 3),
  ('veh_auto_br_toyota', 'XLE', 4), ('veh_auto_br_toyota', 'XSE', 5), ('veh_auto_br_toyota', 'Limited', 6),
  ('veh_auto_br_toyota', 'Platinum', 7), ('veh_auto_br_toyota', 'TRD', 8), ('veh_auto_br_toyota', 'GR Sport', 9),

  ('veh_auto_br_hyundai', 'SE', 1), ('veh_auto_br_hyundai', 'SEL', 2), ('veh_auto_br_hyundai', 'GLS', 3),
  ('veh_auto_br_hyundai', 'Limited', 4), ('veh_auto_br_hyundai', 'N Line', 5), ('veh_auto_br_hyundai', 'Calligraphy', 6),
  ('veh_auto_br_hyundai', 'Comfort', 7), ('veh_auto_br_hyundai', 'Smart', 8),

  ('veh_auto_br_kia', 'LX', 1), ('veh_auto_br_kia', 'EX', 2), ('veh_auto_br_kia', 'EX+', 3),
  ('veh_auto_br_kia', 'GT-Line', 4), ('veh_auto_br_kia', 'GT', 5), ('veh_auto_br_kia', 'SX', 6),
  ('veh_auto_br_kia', 'Signature', 7),

  ('veh_auto_br_nissan', 'S', 1), ('veh_auto_br_nissan', 'SV', 2), ('veh_auto_br_nissan', 'SL', 3),
  ('veh_auto_br_nissan', 'SR', 4), ('veh_auto_br_nissan', 'Platinum', 5), ('veh_auto_br_nissan', 'Titanium', 6),

  ('veh_auto_br_mercedes_benz', 'Base', 1), ('veh_auto_br_mercedes_benz', 'Avantgarde', 2),
  ('veh_auto_br_mercedes_benz', 'Exclusive', 3), ('veh_auto_br_mercedes_benz', 'AMG Line', 4),
  ('veh_auto_br_mercedes_benz', 'AMG', 5), ('veh_auto_br_mercedes_benz', '4MATIC', 6),

  ('veh_auto_br_bmw', 'Base', 1), ('veh_auto_br_bmw', 'Sport Line', 2), ('veh_auto_br_bmw', 'Luxury Line', 3),
  ('veh_auto_br_bmw', 'M Sport', 4), ('veh_auto_br_bmw', 'M', 5), ('veh_auto_br_bmw', 'xDrive', 6),

  ('veh_auto_br_chevrolet', 'LS', 1), ('veh_auto_br_chevrolet', 'LT', 2), ('veh_auto_br_chevrolet', 'LTZ', 3),
  ('veh_auto_br_chevrolet', 'Premier', 4), ('veh_auto_br_chevrolet', 'RS', 5), ('veh_auto_br_chevrolet', 'SS', 6),
  ('veh_auto_br_chevrolet', 'Z71', 7),

  ('veh_auto_br_honda', 'LX', 1), ('veh_auto_br_honda', 'EX', 2), ('veh_auto_br_honda', 'EX-L', 3),
  ('veh_auto_br_honda', 'Sport', 4), ('veh_auto_br_honda', 'Touring', 5), ('veh_auto_br_honda', 'Type R', 6),

  ('veh_auto_br_ford', 'S', 1), ('veh_auto_br_ford', 'SE', 2), ('veh_auto_br_ford', 'SEL', 3),
  ('veh_auto_br_ford', 'Titanium', 4), ('veh_auto_br_ford', 'ST-Line', 5), ('veh_auto_br_ford', 'ST', 6),
  ('veh_auto_br_ford', 'Limited', 7), ('veh_auto_br_ford', 'Platinum', 8), ('veh_auto_br_ford', 'Raptor', 9),

  ('veh_auto_br_mitsubishi', 'ES', 1), ('veh_auto_br_mitsubishi', 'SE', 2), ('veh_auto_br_mitsubishi', 'SEL', 3),
  ('veh_auto_br_mitsubishi', 'GT', 4), ('veh_auto_br_mitsubishi', 'Black Edition', 5),

  ('veh_auto_br_mazda', 'Sport', 1), ('veh_auto_br_mazda', 'Touring', 2), ('veh_auto_br_mazda', 'Grand Touring', 3),
  ('veh_auto_br_mazda', 'Carbon Edition', 4), ('veh_auto_br_mazda', 'Signature', 5),

  ('veh_auto_br_volkswagen', 'Trendline', 1), ('veh_auto_br_volkswagen', 'Comfortline', 2),
  ('veh_auto_br_volkswagen', 'Highline', 3), ('veh_auto_br_volkswagen', 'R-Line', 4),
  ('veh_auto_br_volkswagen', 'GTI', 5), ('veh_auto_br_volkswagen', 'R', 6),

  ('veh_auto_br_genesis', 'Standard', 1), ('veh_auto_br_genesis', 'Advanced', 2),
  ('veh_auto_br_genesis', 'Prestige', 3), ('veh_auto_br_genesis', 'Sport', 4),

  ('veh_auto_br_lexus', 'Base', 1), ('veh_auto_br_lexus', 'F Sport', 2),
  ('veh_auto_br_lexus', 'Luxury', 3), ('veh_auto_br_lexus', 'Ultra Luxury', 4), ('veh_auto_br_lexus', 'F', 5),

  ('veh_auto_br_suzuki', 'GL', 1), ('veh_auto_br_suzuki', 'GLX', 2), ('veh_auto_br_suzuki', 'GLX+', 3),

  ('veh_auto_br_peugeot', 'Active', 1), ('veh_auto_br_peugeot', 'Allure', 2),
  ('veh_auto_br_peugeot', 'GT Line', 3), ('veh_auto_br_peugeot', 'GT', 4),

  ('veh_auto_br_audi', 'Base', 1), ('veh_auto_br_audi', 'Premium', 2), ('veh_auto_br_audi', 'Premium Plus', 3),
  ('veh_auto_br_audi', 'Prestige', 4), ('veh_auto_br_audi', 'S Line', 5), ('veh_auto_br_audi', 'quattro', 6)
;

INSERT INTO public.vehicle_engine_options (brand_slug, name, sort_order) VALUES
  ('veh_auto_br_toyota', '1.6L', 1), ('veh_auto_br_toyota', '1.8L', 2), ('veh_auto_br_toyota', '2.0L', 3),
  ('veh_auto_br_toyota', '2.4L', 4), ('veh_auto_br_toyota', '2.5L', 5), ('veh_auto_br_toyota', '2.7L', 6),
  ('veh_auto_br_toyota', '3.5L V6', 7), ('veh_auto_br_toyota', '4.0L V6', 8), ('veh_auto_br_toyota', '4.6L V8', 9),
  ('veh_auto_br_toyota', '5.7L V8', 10), ('veh_auto_br_toyota', 'Hybrid', 11), ('veh_auto_br_toyota', 'Electric', 12),

  ('veh_auto_br_hyundai', '1.6L', 1), ('veh_auto_br_hyundai', '2.0L', 2), ('veh_auto_br_hyundai', '2.4L', 3),
  ('veh_auto_br_hyundai', '2.5L', 4), ('veh_auto_br_hyundai', '3.3L V6', 5), ('veh_auto_br_hyundai', '3.8L V6', 6),
  ('veh_auto_br_hyundai', '2.0L Turbo', 7), ('veh_auto_br_hyundai', 'Hybrid', 8), ('veh_auto_br_hyundai', 'Electric', 9),

  ('veh_auto_br_kia', '1.6L', 1), ('veh_auto_br_kia', '2.0L', 2), ('veh_auto_br_kia', '2.4L', 3),
  ('veh_auto_br_kia', '2.5L', 4), ('veh_auto_br_kia', '3.3L V6', 5), ('veh_auto_br_kia', '3.8L V6', 6),
  ('veh_auto_br_kia', '1.6L Turbo', 7), ('veh_auto_br_kia', 'Hybrid', 8), ('veh_auto_br_kia', 'Electric', 9),

  ('veh_auto_br_nissan', '1.6L', 1), ('veh_auto_br_nissan', '1.8L', 2), ('veh_auto_br_nissan', '2.0L', 3),
  ('veh_auto_br_nissan', '2.5L', 4), ('veh_auto_br_nissan', '3.5L V6', 5), ('veh_auto_br_nissan', '3.7L V6', 6),
  ('veh_auto_br_nissan', '4.0L V6', 7), ('veh_auto_br_nissan', '5.6L V8', 8), ('veh_auto_br_nissan', 'Electric', 9),

  ('veh_auto_br_mercedes_benz', '1.5L', 1), ('veh_auto_br_mercedes_benz', '2.0L', 2),
  ('veh_auto_br_mercedes_benz', '2.0L Turbo', 3), ('veh_auto_br_mercedes_benz', '3.0L I6', 4),
  ('veh_auto_br_mercedes_benz', '3.0L V6', 5), ('veh_auto_br_mercedes_benz', '4.0L V8', 6),
  ('veh_auto_br_mercedes_benz', '6.0L V12', 7), ('veh_auto_br_mercedes_benz', 'Hybrid', 8),
  ('veh_auto_br_mercedes_benz', 'Electric', 9),

  ('veh_auto_br_bmw', '1.5L', 1), ('veh_auto_br_bmw', '2.0L', 2), ('veh_auto_br_bmw', '2.0L Turbo', 3),
  ('veh_auto_br_bmw', '3.0L I6', 4), ('veh_auto_br_bmw', '4.4L V8', 5), ('veh_auto_br_bmw', '6.6L V12', 6),
  ('veh_auto_br_bmw', 'Hybrid', 7), ('veh_auto_br_bmw', 'Electric', 8),

  ('veh_auto_br_chevrolet', '1.2L', 1), ('veh_auto_br_chevrolet', '1.4L Turbo', 2), ('veh_auto_br_chevrolet', '1.5L Turbo', 3),
  ('veh_auto_br_chevrolet', '2.0L Turbo', 4), ('veh_auto_br_chevrolet', '2.5L', 5), ('veh_auto_br_chevrolet', '3.6L V6', 6),
  ('veh_auto_br_chevrolet', '5.3L V8', 7), ('veh_auto_br_chevrolet', '6.2L V8', 8), ('veh_auto_br_chevrolet', 'Electric', 9),

  ('veh_auto_br_honda', '1.5L Turbo', 1), ('veh_auto_br_honda', '1.8L', 2), ('veh_auto_br_honda', '2.0L', 3),
  ('veh_auto_br_honda', '2.4L', 4), ('veh_auto_br_honda', '3.5L V6', 5), ('veh_auto_br_honda', 'Hybrid', 6),

  ('veh_auto_br_ford', '1.0L EcoBoost', 1), ('veh_auto_br_ford', '1.5L EcoBoost', 2),
  ('veh_auto_br_ford', '2.0L EcoBoost', 3), ('veh_auto_br_ford', '2.3L EcoBoost', 4),
  ('veh_auto_br_ford', '2.7L EcoBoost V6', 5), ('veh_auto_br_ford', '3.5L V6', 6),
  ('veh_auto_br_ford', '5.0L V8', 7), ('veh_auto_br_ford', 'Hybrid', 8), ('veh_auto_br_ford', 'Electric', 9),

  ('veh_auto_br_mitsubishi', '1.5L Turbo', 1), ('veh_auto_br_mitsubishi', '1.6L', 2),
  ('veh_auto_br_mitsubishi', '2.0L', 3), ('veh_auto_br_mitsubishi', '2.4L', 4), ('veh_auto_br_mitsubishi', '3.0L V6', 5),

  ('veh_auto_br_mazda', '1.5L', 1), ('veh_auto_br_mazda', '2.0L', 2), ('veh_auto_br_mazda', '2.5L', 3),
  ('veh_auto_br_mazda', '2.5L Turbo', 4), ('veh_auto_br_mazda', '3.0L', 5), ('veh_auto_br_mazda', 'Electric', 6),

  ('veh_auto_br_volkswagen', '1.4L TSI', 1), ('veh_auto_br_volkswagen', '1.5L TSI', 2),
  ('veh_auto_br_volkswagen', '2.0L TSI', 3), ('veh_auto_br_volkswagen', '2.0L TDI', 4),
  ('veh_auto_br_volkswagen', '3.6L V6', 5), ('veh_auto_br_volkswagen', 'Electric', 6),

  ('veh_auto_br_genesis', '2.5L Turbo', 1), ('veh_auto_br_genesis', '3.3L V6 Turbo', 2),
  ('veh_auto_br_genesis', '3.8L V6', 3), ('veh_auto_br_genesis', '5.0L V8', 4), ('veh_auto_br_genesis', 'Electric', 5),

  ('veh_auto_br_lexus', '2.0L Turbo', 1), ('veh_auto_br_lexus', '2.5L', 2), ('veh_auto_br_lexus', '3.5L V6', 3),
  ('veh_auto_br_lexus', '5.0L V8', 4), ('veh_auto_br_lexus', 'Hybrid', 5),

  ('veh_auto_br_suzuki', '1.0L', 1), ('veh_auto_br_suzuki', '1.2L', 2), ('veh_auto_br_suzuki', '1.4L Turbo', 3),
  ('veh_auto_br_suzuki', '1.6L', 4), ('veh_auto_br_suzuki', '2.4L', 5),

  ('veh_auto_br_peugeot', '1.2L PureTech', 1), ('veh_auto_br_peugeot', '1.6L THP', 2),
  ('veh_auto_br_peugeot', '1.5L BlueHDi', 3), ('veh_auto_br_peugeot', '2.0L BlueHDi', 4), ('veh_auto_br_peugeot', 'Hybrid', 5),

  ('veh_auto_br_audi', '1.4L TFSI', 1), ('veh_auto_br_audi', '2.0L TFSI', 2), ('veh_auto_br_audi', '3.0L V6 TFSI', 3),
  ('veh_auto_br_audi', '4.0L V8 TFSI', 4), ('veh_auto_br_audi', 'Electric', 5)
;
