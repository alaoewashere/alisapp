import { Card, CardContent } from "@/components/ui/card";
import { UsersTable, type UserRowData } from "@/components/tables/users-table";
import { DateRangeFilter, FilterSelect, Pagination, TableSearch } from "@/components/tables/controls";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import type { ProfileRow } from "@/lib/types/database.types";
import { governorates } from "@/lib/constants/governorates";

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

export default async function UsersPage({ searchParams }: { searchParams: SearchParams }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const q = param(searchParams, "q");
  const governorate = param(searchParams, "governorate");
  const verified = param(searchParams, "verified");
  const from = param(searchParams, "from");
  const to = param(searchParams, "to");
  const dir = param(searchParams, "dir") === "asc" ? "asc" : "desc";
  const page = Math.max(1, Number(param(searchParams, "page") ?? "1") || 1);
  const offset = (page - 1) * PAGE_SIZE;

  let query = supabase
    .from("profiles")
    .select("*", { count: "exact" })
    .eq("is_deleted", false);

  if (q) {
    const safe = q.replace(/[%,]/g, "");
    query = query.or(
      `full_name.ilike.%${safe}%,display_name.ilike.%${safe}%,phone.ilike.%${safe}%`,
    );
  }
  if (governorate) query = query.eq("governorate", governorate);
  if (verified === "true") query = query.eq("is_verified", true);
  if (verified === "false") query = query.eq("is_verified", false);
  if (from) query = query.gte("created_at", new Date(from).toISOString());
  if (to) query = query.lte("created_at", endOfDayIso(to));

  const { data, count } = await query
    .order("created_at", { ascending: dir === "asc" })
    .range(offset, offset + PAGE_SIZE - 1);

  const profiles = (data ?? []) as ProfileRow[];
  const ids = profiles.map((p) => p.id);

  const counts = new Map<string, number>();
  if (ids.length > 0) {
    const { data: listingRows } = await supabase
      .from("listings")
      .select("user_id")
      .in("user_id", ids)
      .neq("availability", "deleted");
    for (const row of (listingRows ?? []) as { user_id: string }[]) {
      counts.set(row.user_id, (counts.get(row.user_id) ?? 0) + 1);
    }
  }

  const rows: UserRowData[] = profiles.map((p) => ({
    ...p,
    listingsCount: counts.get(p.id) ?? 0,
  }));

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex flex-wrap items-center gap-3 p-4">
          <TableSearch placeholder="بحث بالاسم أو الهاتف..." />
          <FilterSelect
            param="governorate"
            allLabel="كل المحافظات"
            options={governorates.map((g) => ({ value: g.slug, label: g.nameAr }))}
          />
          <FilterSelect
            param="verified"
            allLabel="الكل (توثيق)"
            options={[
              { value: "true", label: "موثّق" },
              { value: "false", label: "غير موثّق" },
            ]}
          />
          <DateRangeFilter />
        </CardContent>
      </Card>

      <UsersTable data={rows} />

      <Pagination page={page} pageSize={PAGE_SIZE} total={count ?? 0} />
    </div>
  );
}
