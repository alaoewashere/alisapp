import type {
  CategoryRow,
  ListingImageRow,
  ListingRow,
  ProfileRow,
  ReportRow,
} from "@/lib/types/database.types";

export type SellerLite = Pick<ProfileRow, "id" | "display_name" | "full_name">;
export type ListingImageLite = Pick<
  ListingImageRow,
  "storage_path" | "url" | "is_primary" | "sort_order"
>;

export interface ListingCard
  extends Pick<
    ListingRow,
    | "id"
    | "title"
    | "price_iqd"
    | "governorate"
    | "city"
    | "status"
    | "availability"
    | "views_count"
    | "created_at"
    | "is_featured"
    | "is_boosted"
    | "condition"
    | "category_id"
    | "user_id"
  > {
  seller: SellerLite | null;
  categories: Pick<CategoryRow, "id" | "name_ar"> | null;
  listing_images: ListingImageLite[];
}

export interface ListingDetail extends ListingRow {
  seller:
    | (Pick<
        ProfileRow,
        "id" | "display_name" | "full_name" | "phone" | "avatar_url" | "governorate" | "created_at" | "is_suspended"
      >)
    | null;
  categories: Pick<CategoryRow, "id" | "name_ar" | "slug"> | null;
  listing_images: (ListingImageLite & Pick<ListingImageRow, "id">)[];
}

export interface ReportWithRelations
  extends Pick<
    ReportRow,
    "id" | "listing_id" | "reporter_id" | "reason" | "status" | "admin_note" | "resolved_at" | "created_at"
  > {
  reporter: SellerLite | null;
  listing:
    | Pick<ListingRow, "id" | "title" | "status" | "availability" | "user_id">
    | null;
}
