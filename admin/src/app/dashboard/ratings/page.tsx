import { Card, CardContent } from "@/components/ui/card";
import { FilterSelect, Pagination } from "@/components/tables/controls";
import {
  RatingsTable,
  type AdminRatingRow,
} from "@/components/tables/ratings-table";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { formatDateTime } from "@/lib/utils/format-date";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 25;
type SearchParams = { [key: string]: string | string[] | undefined };

function param(sp: SearchParams, key: string): string | undefined {
  const v = sp[key];
  return Array.isArray(v) ? v[0] : v;
}

export default async function RatingsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  await requireAdmin();
  const supabase = createAdminClient();

  const starsParam = param(searchParams, "stars") ?? "all";
  const page = Math.max(1, Number(param(searchParams, "page") ?? "1") || 1);
  const offset = (page - 1) * PAGE_SIZE;

  let query = supabase
    .from("ratings")
    .select(
      `
      id,
      stars,
      review_text,
      created_at,
      reviewer:profiles!ratings_reviewer_id_fkey(full_name, display_name),
      reviewed:profiles!ratings_reviewed_id_fkey(full_name, display_name),
      listing:listings(title_ar, reference_no)
    `,
      { count: "exact" },
    )
    .eq("hidden", false)
    .order("created_at", { ascending: false });

  if (starsParam !== "all") {
    const stars = Number(starsParam);
    if (stars >= 1 && stars <= 5) {
      query = query.eq("stars", stars);
    }
  }

  const { data, count } = await query.range(offset, offset + PAGE_SIZE - 1);

  const rows: AdminRatingRow[] = (data ?? []).map((row) => {
    const reviewer = row.reviewer as {
      full_name?: string | null;
      display_name?: string | null;
    } | null;
    const reviewed = row.reviewed as {
      full_name?: string | null;
      display_name?: string | null;
    } | null;
    const listing = row.listing as {
      title_ar?: string | null;
      reference_no?: number | null;
    } | null;

    return {
      id: row.id as string,
      stars: row.stars as number,
      reviewText: (row.review_text as string | null) ?? null,
      createdAtLabel: formatDateTime(row.created_at as string),
      reviewerName:
        reviewer?.full_name ?? reviewer?.display_name ?? "—",
      reviewedName:
        reviewed?.full_name ?? reviewed?.display_name ?? "—",
      listingTitle: listing?.title_ar ?? "—",
      listingRef:
        listing?.reference_no != null ? String(listing.reference_no) : null,
    };
  });

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex flex-wrap items-center gap-3 p-4">
          <FilterSelect
            param="stars"
            allLabel="كل النجوم"
            options={[
              { value: "5", label: "5 نجوم" },
              { value: "4", label: "4 نجوم" },
              { value: "3", label: "3 نجوم" },
              { value: "2", label: "2 نجوم" },
              { value: "1", label: "1 نجمة" },
            ]}
          />
        </CardContent>
      </Card>

      <RatingsTable rows={rows} />

      <Pagination page={page} pageSize={PAGE_SIZE} total={count ?? 0} />
    </div>
  );
}
