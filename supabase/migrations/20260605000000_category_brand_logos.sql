-- Car brand logos (carlogos.org CDN) + listing count RPC for browse screen

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS logo_url TEXT;

UPDATE public.categories
SET logo_url = CASE name_ar
    WHEN 'Acura' THEN 'https://www.carlogos.org/car-logos/acura-logo.png'
    WHEN 'Alfa Romeo' THEN 'https://www.carlogos.org/car-logos/alfa-romeo-logo.png'
    WHEN 'Aston Martin' THEN 'https://www.carlogos.org/car-logos/aston-martin-logo.png'
    WHEN 'Audi' THEN 'https://www.carlogos.org/car-logos/audi-logo.png'
    WHEN 'BAIC' THEN 'https://www.carlogos.org/car-logos/baic-logo.png'
    WHEN 'BMW' THEN 'https://www.carlogos.org/car-logos/bmw-logo.png'
    WHEN 'BYD' THEN 'https://www.carlogos.org/car-logos/byd-logo.png'
    WHEN 'Bentley' THEN 'https://www.carlogos.org/car-logos/bentley-logo.png'
    WHEN 'Brilliance' THEN 'https://www.carlogos.org/car-logos/brilliance-logo.png'
    WHEN 'Bugatti' THEN 'https://www.carlogos.org/car-logos/bugatti-logo.png'
    WHEN 'Buick' THEN 'https://www.carlogos.org/car-logos/buick-logo.png'
    WHEN 'Cadillac' THEN 'https://www.carlogos.org/car-logos/cadillac-logo.png'
    WHEN 'Changan' THEN 'https://www.carlogos.org/car-logos/changan-logo.png'
    WHEN 'Chery' THEN 'https://www.carlogos.org/car-logos/chery-logo.png'
    WHEN 'Chevrolet' THEN 'https://www.carlogos.org/car-logos/chevrolet-logo.png'
    WHEN 'Citroen' THEN 'https://www.carlogos.org/car-logos/citroen-logo.png'
    WHEN 'Daewoo' THEN 'https://www.carlogos.org/car-logos/daewoo-logo.png'
    WHEN 'Daihatsu' THEN 'https://www.carlogos.org/car-logos/daihatsu-logo.png'
    WHEN 'Dodge' THEN 'https://www.carlogos.org/car-logos/dodge-logo.png'
    WHEN 'Dongfeng' THEN 'https://www.carlogos.org/car-logos/dongfeng-logo.png'
    WHEN 'FAW' THEN 'https://www.carlogos.org/car-logos/faw-logo.png'
    WHEN 'Ferrari' THEN 'https://www.carlogos.org/car-logos/ferrari-logo.png'
    WHEN 'Fiat' THEN 'https://www.carlogos.org/car-logos/fiat-logo.png'
    WHEN 'Ford' THEN 'https://www.carlogos.org/car-logos/ford-logo.png'
    WHEN 'Foton' THEN 'https://www.carlogos.org/car-logos/foton-logo.png'
    WHEN 'GAC' THEN 'https://www.carlogos.org/car-logos/gac-logo.png'
    WHEN 'GMC' THEN 'https://www.carlogos.org/car-logos/gmc-logo.png'
    WHEN 'Geely' THEN 'https://www.carlogos.org/car-logos/geely-logo.png'
    WHEN 'Genesis' THEN 'https://www.carlogos.org/car-logos/genesis-logo.png'
    WHEN 'Great Wall' THEN 'https://www.carlogos.org/car-logos/great-wall-logo.png'
    WHEN 'Haval' THEN 'https://www.carlogos.org/car-logos/haval-logo.png'
    WHEN 'Hino' THEN 'https://www.carlogos.org/car-logos/hino-logo.png'
    WHEN 'Honda' THEN 'https://www.carlogos.org/car-logos/honda-logo.png'
    WHEN 'Hummer' THEN 'https://www.carlogos.org/car-logos/hummer-logo.png'
    WHEN 'Hyundai' THEN 'https://www.carlogos.org/car-logos/hyundai-logo.png'
    WHEN 'IVECO' THEN 'https://www.carlogos.org/car-logos/iveco-logo.png'
    WHEN 'Infiniti' THEN 'https://www.carlogos.org/car-logos/infiniti-logo.png'
    WHEN 'Iran Khodro' THEN 'https://www.carlogos.org/car-logos/iran-khodro-logo.png'
    WHEN 'Isuzu' THEN 'https://www.carlogos.org/car-logos/isuzu-logo.png'
    WHEN 'JAC' THEN 'https://www.carlogos.org/car-logos/jac-logo.png'
    WHEN 'Jaguar' THEN 'https://www.carlogos.org/car-logos/jaguar-logo.png'
    WHEN 'Jeep' THEN 'https://www.carlogos.org/car-logos/jeep-logo.png'
    WHEN 'Jinbei' THEN 'https://www.carlogos.org/car-logos/jinbei-logo.png'
    WHEN 'Kia' THEN 'https://www.carlogos.org/car-logos/kia-logo.png'
    WHEN 'King Long' THEN 'https://www.carlogos.org/car-logos/king-long-logo.png'
    WHEN 'Lamborghini' THEN 'https://www.carlogos.org/car-logos/lamborghini-logo.png'
    WHEN 'Land Rover' THEN 'https://www.carlogos.org/car-logos/land-rover-logo.png'
    WHEN 'Lexus' THEN 'https://www.carlogos.org/car-logos/lexus-logo.png'
    WHEN 'Lifan' THEN 'https://www.carlogos.org/car-logos/lifan-logo.png'
    WHEN 'Lincoln' THEN 'https://www.carlogos.org/car-logos/lincoln-logo.png'
    WHEN 'MG' THEN 'https://www.carlogos.org/car-logos/mg-logo.png'
    WHEN 'Maserati' THEN 'https://www.carlogos.org/car-logos/maserati-logo.png'
    WHEN 'Maxus' THEN 'https://www.carlogos.org/car-logos/maxus-logo.png'
    WHEN 'Mazda' THEN 'https://www.carlogos.org/car-logos/mazda-logo.png'
    WHEN 'McLaren' THEN 'https://www.carlogos.org/car-logos/mclaren-logo.png'
    WHEN 'Mercedes-Benz' THEN 'https://www.carlogos.org/car-logos/mercedes-benz-logo.png'
    WHEN 'Mercury' THEN 'https://www.carlogos.org/car-logos/mercury-logo.png'
    WHEN 'Mini' THEN 'https://www.carlogos.org/car-logos/mini-logo.png'
    WHEN 'Mitsubishi' THEN 'https://www.carlogos.org/car-logos/mitsubishi-logo.png'
    WHEN 'Nissan' THEN 'https://www.carlogos.org/car-logos/nissan-logo.png'
    WHEN 'Oldsmobile' THEN 'https://www.carlogos.org/car-logos/oldsmobile-logo.png'
    WHEN 'Opel' THEN 'https://www.carlogos.org/car-logos/opel-logo.png'
    WHEN 'Peugeot' THEN 'https://www.carlogos.org/car-logos/peugeot-logo.png'
    WHEN 'Pontiac' THEN 'https://www.carlogos.org/car-logos/pontiac-logo.png'
    WHEN 'Porsche' THEN 'https://www.carlogos.org/car-logos/porsche-logo.png'
    WHEN 'Renault' THEN 'https://www.carlogos.org/car-logos/renault-logo.png'
    WHEN 'Rolls-Royce' THEN 'https://www.carlogos.org/car-logos/rolls-royce-logo.png'
    WHEN 'Saab' THEN 'https://www.carlogos.org/car-logos/saab-logo.png'
    WHEN 'Saipa' THEN 'https://www.carlogos.org/car-logos/saipa-logo.png'
    WHEN 'Scion' THEN 'https://www.carlogos.org/car-logos/scion-logo.png'
    WHEN 'Seat' THEN 'https://www.carlogos.org/car-logos/seat-logo.png'
    WHEN 'Skoda' THEN 'https://www.carlogos.org/car-logos/skoda-logo.png'
    WHEN 'SsangYong' THEN 'https://www.carlogos.org/car-logos/ssangyong-logo.png'
    WHEN 'Subaru' THEN 'https://www.carlogos.org/car-logos/subaru-logo.png'
    WHEN 'Suzuki' THEN 'https://www.carlogos.org/car-logos/suzuki-logo.png'
    WHEN 'Tesla' THEN 'https://www.carlogos.org/car-logos/tesla-logo.png'
    WHEN 'Toyota' THEN 'https://www.carlogos.org/car-logos/toyota-logo.png'
    WHEN 'Volkswagen' THEN 'https://www.carlogos.org/car-logos/volkswagen-logo.png'
    WHEN 'Volvo' THEN 'https://www.carlogos.org/car-logos/volvo-logo.png'
    ELSE logo_url
END
WHERE icon = 'brand';

CREATE OR REPLACE FUNCTION public.category_listing_counts()
RETURNS TABLE(category_id INT, listing_count BIGINT)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT l.category_id, COUNT(*)::BIGINT
  FROM public.listings l
  WHERE l.status = 'approved'
    AND l.availability = 'active'
  GROUP BY l.category_id;
$$;

GRANT EXECUTE ON FUNCTION public.category_listing_counts() TO anon, authenticated;
