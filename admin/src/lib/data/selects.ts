// Shared PostgREST select strings. FK hints disambiguate the multiple
// profiles relationships (reports.reporter_id / reports.resolved_by).

export const LISTING_CARD_SELECT = `
  id, title, price_iqd, governorate, city, status, availability, views_count,
  created_at, is_featured, is_boosted, condition, category_id, user_id,
  seller:profiles!listings_user_id_fkey(id, display_name, full_name),
  categories(id, name_ar),
  listing_images(storage_path, url, is_primary, sort_order)
` as const;

export const LISTING_DETAIL_SELECT = `
  *,
  seller:profiles!listings_user_id_fkey(id, display_name, full_name, phone, avatar_url, governorate, created_at, is_suspended),
  categories(id, name_ar, slug),
  listing_images(id, storage_path, url, is_primary, sort_order)
` as const;

export const REPORT_SELECT = `
  id, listing_id, reporter_id, reason, status, admin_note, resolved_at, created_at,
  reporter:profiles!reports_reporter_id_fkey(id, display_name, full_name),
  listing:listings!reports_listing_id_fkey(id, title, status, availability, user_id)
` as const;
