const BUCKET = "listing-images";

/**
 * Builds a public URL for a listing image. Mirrors the Flutter app: a value
 * that already looks like a URL is returned as-is, otherwise it is resolved
 * against the public storage bucket.
 */
export function publicImageUrl(path: string | null | undefined): string | null {
  if (!path) return null;
  if (path.startsWith("http")) return path;
  const base = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
  return `${base}/storage/v1/object/public/${BUCKET}/${path}`;
}

/** Picks the cover image from a listing's joined images array. */
export function coverImage(
  images: { storage_path: string; url: string | null; is_primary: boolean; sort_order: number }[] | null | undefined,
): string | null {
  if (!images || images.length === 0) return null;
  const sorted = [...images].sort((a, b) => {
    if (a.is_primary !== b.is_primary) return a.is_primary ? -1 : 1;
    return a.sort_order - b.sort_order;
  });
  const first = sorted[0];
  return publicImageUrl(first.url ?? first.storage_path);
}
