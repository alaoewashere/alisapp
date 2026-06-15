import { Card, CardContent } from "@/components/ui/card";
import { PurchasesTable } from "@/components/tables/purchases-table";
import { DateRangeFilter, FilterSelect, Pagination, TableSearch } from "@/components/tables/controls";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import type { ListingPurchaseRow } from "@/lib/types/database.types";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 25;
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

export default async function PurchasesPage({ searchParams }: { searchParams: SearchParams }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const q = param(searchParams, "q");
  const packageType = param(searchParams, "package");
  const from = param(searchParams, "from");
  const to = param(searchParams, "to");
  const dir = param(searchParams, "dir") === "asc" ? "asc" : "desc";
  const page = Math.max(1, Number(param(searchParams, "page") ?? "1") || 1);
  const offset = (page - 1) * PAGE_SIZE;

  let query = supabase.from("listing_purchases").select("*", { count: "exact" });

  if (q) {
    const safe = q.replace(/[%,]/g, "");
    query = query.or(
      `user_name.ilike.%${safe}%,user_phone.ilike.%${safe}%,user_email.ilike.%${safe}%,listing_id.ilike.%${safe}%`,
    );
  }
  if (packageType === "pro" || packageType === "premium") {
    query = query.eq("package_type", packageType);
  }
  if (from) query = query.gte("purchased_at", new Date(from).toISOString());
  if (to) query = query.lte("purchased_at", endOfDayIso(to));

  const { data, count } = await query
    .order("purchased_at", { ascending: dir === "asc" })
    .range(offset, offset + PAGE_SIZE - 1);

  const purchases = (data ?? []) as ListingPurchaseRow[];

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex flex-wrap items-center gap-3 p-4">
          <TableSearch placeholder="بحث بالاسم أو الهاتف أو الإعلان..." />
          <FilterSelect
            param="package"
            allLabel="كل الباقات"
            options={[
              { value: "pro", label: "برو" },
              { value: "premium", label: "مميز" },
            ]}
          />
          <DateRangeFilter />
        </CardContent>
      </Card>

      <PurchasesTable data={purchases} />

      <Pagination page={page} pageSize={PAGE_SIZE} total={count ?? 0} />
    </div>
  );
}
