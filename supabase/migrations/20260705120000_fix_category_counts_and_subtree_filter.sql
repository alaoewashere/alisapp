-- Fix 1: the earlier category_listing_counts() overload (no args) was never
-- dropped when category_listing_counts(p_listing_type TEXT DEFAULT NULL) was
-- added. Since the new overload's only parameter has a default, PostgREST
-- cannot disambiguate a zero-argument call between the two functions and
-- errors with PGRST203 ("Could not choose the best candidate function") —
-- silently caught client-side, making every category's listing count show 0.
DROP FUNCTION IF EXISTS public.category_listing_counts();

-- Fix 2: filtering listings by an ancestor category (e.g. "Vehicles") requires
-- matching against every descendant id. The previous approach fetched the
-- full subtree id array to the client and passed it back as a `category_id
-- IN (...)` list — for large branches (e.g. vehicles: ~3,900 descendant ids)
-- this built a multi-KB request that hung or failed outright. This function
-- does the containment check inside Postgres instead, so the client only
-- ever sends a single root_id.
CREATE OR REPLACE FUNCTION public.listings_under_category(root_id INT)
RETURNS SETOF public.listings
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH RECURSIVE tree AS (
    SELECT id FROM public.categories WHERE id = root_id
    UNION ALL
    SELECT c.id FROM public.categories c JOIN tree t ON c.parent_id = t.id
  )
  SELECT l.* FROM public.listings l WHERE l.category_id IN (SELECT id FROM tree);
$$;

GRANT EXECUTE ON FUNCTION public.listings_under_category(INT) TO anon, authenticated;
