import { Card, CardContent } from "@/components/ui/card";
import { ListingsTable } from "@/components/tables/listings-table";
import {
  DateRangeFilter,
  FilterSelect,
  Pagination,
  TableSearch,
} from "@/components/tables/controls";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { LISTING_CARD_SELECT } from "@/lib/data/selects";
import type { ListingCard } from "@/lib/data/types";
import type { CategoryRow } from "@/lib/types/database.types";
import { governorates } from "@/lib/constants/governorates";
import { parseListingStatus } from "@/lib/utils/filters";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 25;
const SORTABLE = new Set(["title", "price_iqd", "views_count", "created_at"]);

type SearchParams = { [key: string]: string | string[] | undefined };

function param(sp: SearchParams, key: string): string | undefined {
  const v = sp[key];
  return Array.isArray(v) ? v[0] : v;
}

function endOfDayIso(date: string): string {
  const d = new Date(date);
  d.setHours(23, 59, 59, 999);
  return d.toISOString();
}

export default async function ListingsPage({ searchParams }: { searchParams: SearchParams }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const status = param(searchParams, "status");
  const governorate = param(searchParams, "governorate");
  const category = param(searchParams, "category");
  const from = param(searchParams, "from");
  const to = param(searchParams, "to");
  const q = param(searchParams, "q");
  const sort = param(searchParams, "sort");
  const dir = param(searchParams, "dir") === "asc" ? "asc" : "desc";
  const page = Math.max(1, Number(param(searchParams, "page") ?? "1") || 1);
  const offset = (page - 1) * PAGE_SIZE;

  let query = supabase
    .from("listings")
    .select(LISTING_CARD_SELECT, { count: "exact" });

  const listingStatus = parseListingStatus(status);
  if (listingStatus) query = query.eq("status", listingStatus);
  if (governorate) query = query.eq("governorate", governorate);
  if (category) query = query.eq("category_id", Number(category));
  if (from) query = query.gte("created_at", new Date(from).toISOString());
  if (to) query = query.lte("created_at", endOfDayIso(to));
  if (q) query = query.ilike("title", `%${q}%`);

  const sortColumn = sort && SORTABLE.has(sort) ? sort : "created_at";
  query = query
    .order(sortColumn, { ascending: dir === "asc" })
    .range(offset, offset + PAGE_SIZE - 1);

  const [{ data, count }, categoriesRes] = await Promise.all([
    query,
    supabase.from("categories").select("id, name_ar, parent_id").order("name_ar"),
  ]);

  const listings = (data ?? []) as unknown as ListingCard[];
  const categories = (categoriesRes.data ?? []) as Pick<CategoryRow, "id" | "name_ar" | "parent_id">[];

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex flex-wrap items-center gap-3 p-4">
          <TableSearch placeholder="بحث بعنوان الإعلان..." />
          <FilterSelect
            param="status"
            allLabel="كل الحالات"
            options={[
              { value: "approved", label: "مقبول" },
              { value: "pending", label: "قيد المراجعة" },
              { value: "rejected", label: "مرفوض" },
            ]}
          />
          <FilterSelect
            param="governorate"
            allLabel="كل المحافظات"
            options={governorates.map((g) => ({ value: g.slug, label: g.nameAr }))}
          />
          <FilterSelect
            param="category"
            allLabel="كل الفئات"
            options={categories.map((c) => ({ value: String(c.id), label: c.name_ar }))}
          />
          <DateRangeFilter />
        </CardContent>
      </Card>

      <ListingsTable data={listings} />

      <Pagination page={page} pageSize={PAGE_SIZE} total={count ?? 0} />
    </div>
  );
}
