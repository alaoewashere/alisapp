import Link from "next/link";

import { BarChart } from "@/components/charts/bar-chart";
import { LineChart, type SeriesPoint } from "@/components/charts/line-chart";
import { PieChart } from "@/components/charts/pie-chart";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { RangeSelector } from "@/app/dashboard/analytics/range-selector";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { buildDailySeries } from "@/lib/data/series";
import type { CategoryRow, ListingRow, SearchLogRow } from "@/lib/types/database.types";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatNumber } from "@/lib/utils/format-iqd";
import { formatRelative } from "@/lib/utils/format-date";

export const dynamic = "force-dynamic";

type SearchParams = { [key: string]: string | string[] | undefined };

function topN(map: Map<string, number>, n: number): SeriesPoint[] {
  return [...map.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, n)
    .map(([label, value]) => ({ label, value }));
}

export default async function AnalyticsPage({ searchParams }: { searchParams: SearchParams }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const daysRaw = Array.isArray(searchParams.days) ? searchParams.days[0] : searchParams.days;
  const days = [7, 30, 90].includes(Number(daysRaw)) ? Number(daysRaw) : 30;
  const since = new Date();
  since.setDate(since.getDate() - (days - 1));
  since.setHours(0, 0, 0, 0);
  const sinceIso = since.toISOString();

  const [listingsRes, usersRes, searchRes, topViewedRes, categoriesRes] = await Promise.all([
    supabase
      .from("listings")
      .select("created_at, category_id, governorate, condition")
      .gte("created_at", sinceIso),
    supabase.from("profiles").select("created_at").gte("created_at", sinceIso),
    supabase.from("search_logs").select("query, created_at").gte("created_at", sinceIso),
    supabase
      .from("listings")
      .select("id, title, views_count")
      .order("views_count", { ascending: false })
      .limit(10),
    supabase.from("categories").select("id, name_ar, parent_id"),
  ]);

  const listings = (listingsRes.data ?? []) as Pick<
    ListingRow,
    "created_at" | "category_id" | "governorate" | "condition"
  >[];
  const users = (usersRes.data ?? []) as { created_at: string }[];
  const searchLogs = (searchRes.data ?? []) as Pick<SearchLogRow, "query" | "created_at">[];
  const topViewed = (topViewedRes.data ?? []) as Pick<ListingRow, "id" | "title" | "views_count">[];
  const categories = (categoriesRes.data ?? []) as Pick<CategoryRow, "id" | "name_ar" | "parent_id">[];

  const categoryName = new Map(categories.map((c) => [c.id, c.name_ar]));
  const parentOf = new Map(categories.map((c) => [c.id, c.parent_id]));

  // Series
  const listingsSeries = buildDailySeries(listings, days, (r) => r.created_at);
  const usersSeries = buildDailySeries(users, days, (r) => r.created_at);

  // Listings by parent category
  const categoryCounts = new Map<string, number>();
  for (const l of listings) {
    const parentId = parentOf.get(l.category_id) ?? l.category_id;
    const name = categoryName.get(parentId) ?? "غير مصنّف";
    categoryCounts.set(name, (categoryCounts.get(name) ?? 0) + 1);
  }
  const categoryBars = topN(categoryCounts, 10);

  // Listings by governorate
  const govCounts = new Map<string, number>();
  for (const l of listings) {
    const name = governorateNameAr(l.governorate);
    govCounts.set(name, (govCounts.get(name) ?? 0) + 1);
  }
  const govBars = topN(govCounts, 18);

  // Condition pie
  const newCount = listings.filter((l) => l.condition === "new").length;
  const usedCount = listings.filter((l) => l.condition === "used").length;
  const conditionPie: SeriesPoint[] = [
    { label: "جديد", value: newCount },
    { label: "مستعمل", value: usedCount },
  ];

  // Top search queries
  const queryCounts = new Map<string, { count: number; last: string }>();
  for (const log of searchLogs) {
    const key = log.query.trim();
    if (!key) continue;
    const existing = queryCounts.get(key);
    if (existing) {
      existing.count += 1;
      if (log.created_at > existing.last) existing.last = log.created_at;
    } else {
      queryCounts.set(key, { count: 1, last: log.created_at });
    }
  }
  const topQueries = [...queryCounts.entries()]
    .sort((a, b) => b[1].count - a[1].count)
    .slice(0, 10);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold">التحليلات</h2>
        <RangeSelector />
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>الإعلانات عبر الزمن</CardTitle>
          </CardHeader>
          <CardContent>
            <LineChart data={listingsSeries} color="#16a34a" valueName="إعلانات" />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>المستخدمون عبر الزمن</CardTitle>
          </CardHeader>
          <CardContent>
            <LineChart data={usersSeries} color="#0ea5e9" valueName="مستخدمون" />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>الإعلانات حسب الفئة</CardTitle>
          </CardHeader>
          <CardContent>
            <BarChart data={categoryBars} valueName="إعلانات" />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>الإعلانات حسب المحافظة</CardTitle>
          </CardHeader>
          <CardContent>
            <BarChart data={govBars} valueName="إعلانات" horizontal height={420} color="#0ea5e9" />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>الإعلانات حسب الجودة</CardTitle>
          </CardHeader>
          <CardContent>
            <PieChart data={conditionPie} />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>أكثر عمليات البحث</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>الكلمة</TableHead>
                  <TableHead>المرات</TableHead>
                  <TableHead>آخر بحث</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {topQueries.map(([query, info]) => (
                  <TableRow key={query}>
                    <TableCell className="font-medium">{query}</TableCell>
                    <TableCell>{formatNumber(info.count)}</TableCell>
                    <TableCell className="text-muted-foreground">{formatRelative(info.last)}</TableCell>
                  </TableRow>
                ))}
                {topQueries.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={3} className="py-6 text-center text-muted-foreground">
                      لا توجد عمليات بحث
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>الأكثر مشاهدة</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>الإعلان</TableHead>
                <TableHead>المشاهدات</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {topViewed.map((l) => (
                <TableRow key={l.id}>
                  <TableCell>
                    <Link href={`/dashboard/listings/${l.id}`} className="line-clamp-1 font-medium hover:text-primary">
                      {l.title}
                    </Link>
                  </TableCell>
                  <TableCell>{formatNumber(l.views_count)}</TableCell>
                </TableRow>
              ))}
              {topViewed.length === 0 && (
                <TableRow>
                  <TableCell colSpan={2} className="py-6 text-center text-muted-foreground">
                    لا توجد بيانات
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
