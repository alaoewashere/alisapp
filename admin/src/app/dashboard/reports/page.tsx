import { Card, CardContent } from "@/components/ui/card";
import { ReportsTable } from "@/components/tables/reports-table";
import { DateRangeFilter, FilterSelect, Pagination, TableSearch } from "@/components/tables/controls";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { REPORT_SELECT } from "@/lib/data/selects";
import type { ReportWithRelations } from "@/lib/data/types";
import { parseReportStatus } from "@/lib/utils/filters";

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

export default async function ReportsPage({ searchParams }: { searchParams: SearchParams }) {
  await requireAdmin();
  const supabase = createAdminClient();

  // Default to pending so moderators see the queue first.
  const status = param(searchParams, "status") ?? "pending";
  const q = param(searchParams, "q");
  const from = param(searchParams, "from");
  const to = param(searchParams, "to");
  const page = Math.max(1, Number(param(searchParams, "page") ?? "1") || 1);
  const offset = (page - 1) * PAGE_SIZE;

  let query = supabase.from("reports").select(REPORT_SELECT, { count: "exact" });
  if (status !== "all") {
    const reportStatus = parseReportStatus(status);
    if (reportStatus) query = query.eq("status", reportStatus);
  }
  if (q) query = query.ilike("reason", `%${q.replace(/[%,]/g, "")}%`);
  if (from) query = query.gte("created_at", new Date(from).toISOString());
  if (to) query = query.lte("created_at", endOfDayIso(to));

  const { data, count } = await query
    .order("created_at", { ascending: false })
    .range(offset, offset + PAGE_SIZE - 1);

  const reports = (data ?? []) as unknown as ReportWithRelations[];

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="flex flex-wrap items-center gap-3 p-4">
          <TableSearch placeholder="بحث في نص البلاغ..." />
          <FilterSelect
            param="status"
            allLabel="كل الحالات"
            options={[
              { value: "pending", label: "قيد الانتظار" },
              { value: "resolved", label: "تم الحل" },
              { value: "dismissed", label: "مرفوض" },
            ]}
          />
          <DateRangeFilter />
        </CardContent>
      </Card>

      <ReportsTable data={reports} />

      <Pagination page={page} pageSize={PAGE_SIZE} total={count ?? 0} />
    </div>
  );
}
