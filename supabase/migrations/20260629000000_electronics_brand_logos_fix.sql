-- Fix electronics brand logos: Wikipedia SVG hashes 404 from the app.
-- PNG/SVG assets uploaded to public `brand-logos` bucket (elec-*.svg).
-- Regenerate with: dart run scripts/upload_logos.dart --electronics

UPDATE public.categories c
SET logo_url = 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-' ||
  lower(regexp_replace(regexp_replace(c.name_ar, '&', 'and', 'g'), '[^a-zA-Z0-9]+', '-', 'g')) || '.svg'
WHERE c.icon = 'brand'
  AND c.slug LIKE 'elec\_%' ESCAPE '\'
  AND c.name_ar IN (
    'Apple', 'Samsung', 'Huawei', 'Xiaomi', 'Oppo', 'Vivo', 'OnePlus', 'Tecno', 'Infinix',
    'Dell', 'HP', 'Lenovo', 'Asus', 'MSI', 'LG', 'Sony', 'TCL', 'Canon', 'Nikon', 'GoPro',
    'JBL', 'Bose', 'Sony PlayStation', 'Microsoft Xbox', 'Nintendo', 'TP-Link', 'Cisco', 'Epson',
    'Bosch', 'Siemens', 'Electrolux', 'Whirlpool', 'Haier', 'Midea', 'Gree', 'Carrier', 'Daikin',
    'Toshiba', 'Hitachi', 'Panasonic', 'York', 'DJI', 'BenQ', 'ViewSonic'
  );
