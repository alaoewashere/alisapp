// Hand-maintained subset of the Souq IQ Supabase schema used by the admin
// dashboard. Mirrors supabase/migrations. Regenerate with the Supabase CLI
// (`supabase gen types typescript`) if you prefer full coverage.

export type ListingStatus = "pending" | "approved" | "rejected";
export type ListingAvailability = "active" | "sold" | "deleted";
export type ListingCondition = "new" | "used";
export type ReportStatus = "pending" | "resolved" | "dismissed";
export type AdminRole = "admin" | "super_admin";
export type NotificationType =
  | "info"
  | "warning"
  | "listing_approved"
  | "listing_rejected";

export type ProfileRow = {
  id: string;
  phone: string | null;
  display_name: string;
  full_name: string | null;
  avatar_url: string | null;
  city: string | null;
  governorate: string | null;
  is_verified: boolean;
  is_deleted: boolean;
  is_suspended: boolean;
  suspended_reason: string | null;
  suspended_at: string | null;
  created_at: string;
  updated_at: string;
}

export type ListingRow = {
  id: string;
  user_id: string;
  category_id: number;
  title: string;
  description: string;
  price_iqd: number;
  price: number | null;
  currency: string;
  is_negotiable: boolean;
  condition: ListingCondition | null;
  city: string;
  governorate: string;
  status: ListingStatus;
  availability: ListingAvailability;
  rejection_reason: string | null;
  views_count: number;
  is_featured: boolean;
  is_boosted: boolean;
  latitude: number | null;
  longitude: number | null;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
  reviewed_at: string | null;
}

export type ListingImageRow = {
  id: string;
  listing_id: string;
  storage_path: string;
  url: string | null;
  sort_order: number;
  is_primary: boolean;
  created_at: string;
}

export type CategoryRow = {
  id: number;
  slug: string;
  name_ar: string;
  name_ku: string | null;
  name_en: string | null;
  icon: string;
  parent_id: number | null;
  display_order: number;
}

export type ReportRow = {
  id: string;
  listing_id: string;
  reporter_id: string;
  reason: string;
  status: ReportStatus;
  resolved_at: string | null;
  resolved_by: string | null;
  admin_note: string | null;
  created_at: string;
}

export type FavoriteRow = {
  id: string;
  user_id: string;
  listing_id: string;
  created_at: string;
}

export type BoostRow = {
  id: string;
  listing_id: string;
  user_id: string;
  type: "featured" | "boosted" | "urgent";
  started_at: string;
  expires_at: string;
  amount_paid: number;
  created_at: string;
}

export type SearchLogRow = {
  id: string;
  user_id: string | null;
  query: string;
  results_count: number;
  created_at: string;
}

export type AdminUserRow = {
  id: string;
  email: string;
  role: AdminRole;
  created_at: string;
}

export type AppSettingRow = {
  key: string;
  value: string;
  updated_at: string;
}

export type NotificationRow = {
  id: string;
  user_id: string;
  listing_id: string | null;
  type: NotificationType;
  title: string;
  body: string;
  is_read: boolean;
  created_at: string;
}

export type GovernorateRow = {
  id: number;
  slug: string;
  name_ar: string;
  name_ku: string | null;
  name_en: string;
}

type Table<Row, Insert = Partial<Row>, Update = Partial<Row>> = {
  Row: Row;
  Insert: Insert;
  Update: Update;
  Relationships: [];
};

export type Database = {
  public: {
    Tables: {
      profiles: Table<ProfileRow>;
      listings: Table<ListingRow>;
      listing_images: Table<ListingImageRow>;
      categories: Table<CategoryRow>;
      reports: Table<ReportRow>;
      favorites: Table<FavoriteRow>;
      boosts: Table<BoostRow>;
      search_logs: Table<SearchLogRow>;
      admin_users: Table<AdminUserRow>;
      app_settings: Table<AppSettingRow>;
      notifications: Table<NotificationRow>;
      governorates: Table<GovernorateRow>;
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: {
      listing_status: ListingStatus;
      listing_availability: ListingAvailability;
      listing_condition: ListingCondition;
    };
    CompositeTypes: Record<string, never>;
  };
}
