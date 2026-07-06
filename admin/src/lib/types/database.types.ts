// Hand-maintained subset of the Sello Supabase schema used by the admin
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
  | "listing_rejected"
  | "rating_request";

export type ProfileRow = {
  id: string;
  phone: string | null;
  display_name: string;
  full_name: string | null;
  avatar_url: string | null;
  city: string | null;
  governorate: string | null;
  is_verified: boolean;
  verification_status?: "unverified" | "pending" | "verified" | "rejected";
  verification_submitted_at?: string | null;
  verification_reviewed_at?: string | null;
  rejection_reason?: string | null;
  avg_rating?: number;
  rating_count?: number;
  is_deleted: boolean;
  is_suspended: boolean;
  suspended_reason: string | null;
  suspended_at: string | null;
  moderation_violation_count?: number;
  last_moderation_violation_at?: string | null;
  is_banned?: boolean;
  banned_until?: string | null;
  ban_count?: number;
  ban_reason?: string | null;
  banned_by?: string | null;
  created_at: string;
  updated_at: string;
}

export type ListingRow = {
  id: string;
  user_id: string;
  category_id: number;
  title: string;
  title_ar?: string | null;
  description: string;
  description_ar?: string | null;
  reference_no?: number;
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
  is_verified_seller?: boolean;
  metadata?: Record<string, unknown> | null;
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

export type ListingPurchaseRow = {
  id: string;
  user_id: string;
  listing_id: string;
  package_type: "pro" | "premium";
  price: number;
  purchased_at: string;
  user_name: string;
  user_phone: string | null;
  user_email: string | null;
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

export type BlockedWordRow = {
  id: string;
  word: string;
  normalized_form: string;
  severity: "low" | "medium" | "high";
  active: boolean;
  created_at: string;
  created_by: string | null;
}

export type RatingRow = {
  id: string;
  listing_id: string;
  reviewer_id: string;
  reviewed_id: string;
  stars: number;
  review_text: string | null;
  hidden: boolean;
  created_at: string;
}

export type VerificationRequestRow = {
  id: string;
  user_id: string;
  document_type: "national_id" | "passport" | "drivers_license";
  front_image_url: string;
  back_image_url: string | null;
  submitted_at: string;
  status: "pending" | "verified" | "rejected";
  reviewed_by: string | null;
  reviewed_at: string | null;
  rejection_reason: string | null;
}

export type SupportSenderRole = "user" | "admin";

export type SupportMessageRow = {
  id: string;
  user_id: string;
  sender_role: SupportSenderRole;
  body: string;
  is_read: boolean;
  created_at: string;
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
      listing_purchases: Table<ListingPurchaseRow>;
      search_logs: Table<SearchLogRow>;
      admin_users: Table<AdminUserRow>;
      app_settings: Table<AppSettingRow>;
      notifications: Table<NotificationRow>;
      governorates: Table<GovernorateRow>;
      blocked_words: Table<BlockedWordRow>;
      ratings: Table<RatingRow>;
      verification_requests: Table<VerificationRequestRow>;
      support_messages: Table<SupportMessageRow>;
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
