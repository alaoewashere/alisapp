-- Listings are tagged at the leaf (model/brand) category level, but users
-- browse/filter at any ancestor level (e.g. "Vehicles" or "Mercedes-Benz").
-- Exact category_id matching on the listings table misses everything tagged
-- under a descendant category. This RPC resolves a category id to itself
-- plus all descendant ids, so callers can filter with `category_id = ANY(...)`.
CREATE OR REPLACE FUNCTION public.category_subtree_ids(root_id INT)
RETURNS INT[]
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
  SELECT COALESCE(array_agg(id), ARRAY[root_id]) FROM tree;
$$;

GRANT EXECUTE ON FUNCTION public.category_subtree_ids(INT) TO anon, authenticated;
