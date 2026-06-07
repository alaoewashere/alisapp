import Link from "next/link";
import { Flag, Package, TrendingUp, Users } from "lucide-react";

import { ListingsChart } from "@/components/charts/listings-chart";
import { UsersChart } from "@/components/charts/users-chart";
import { StatCard } from "@/components/layout/stat-card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Thumbnail } from "@/components/ui/thumbnail";
import { ListingStatusBadge } from "@/components/ui/status-badge";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { buildDailySeries } from "@/lib/data/series";
import { LISTING_CARD_SELECT, REPORT_SELECT } from "@/lib/data/selects";
import type { ListingCard, ReportWithRelations } from "@/lib/data/types";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatIqd, formatNumber } from "@/lib/utils/format-iqd";
import { formatRelative } from "@/lib/utils/format-date";
import { coverImage } from "@/lib/utils/image-url";
import { ResolveReportButton } from "@/app/dashboard/reports/report-actions";

export const dynamic = "force-dynamic";

function startOfDay(offsetDays = 0): string {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  d.setDate(d.getDate() - offsetDays);
  return d.toISOString();
}

function trendPct(today: number, yesterday: number): number | null {
  if (yesterday === 0) return today > 0 ? 100 : null;
  return ((today - yesterday) / yesterday) * 100;
}

async function countSince(
  table: "listings" | "profiles",
  from: string,
  to?: string,
): Promise<number> {
  const supabase = createAdminClient();
  let query = supabase
    .from(table)
    .select("id", { count: "exact", head: true })
    .gte("created_at", from);
  if (to) query = query.lt("created_at", to);
  const { count } = await query;
  return count ?? 0;
}

export default async function OverviewPage() {
  await requireAdmin();
  const supabase = createAdminClient();

  const todayStart = startOfDay(0);
  const yesterdayStart = startOfDay(1);
  const thirtyDaysAgo = startOfDay(29);

  const [
    totalUsers,
    activeListings,
    listingsToday,
    listingsYesterday,
    usersToday,
    usersYesterday,
    pendingReports,
    listingDates,
    userDates,
    recentListingsRes,
    recentReportsRes,
  ] = await Promise.all([
    supabase.from("profiles").select("id", { count: "exact", head: true }).eq("is_deleted", false),
    supabase
      .from("listings")
      .select("id", { count: "exact", head: true })
      .eq("status", "approved")
      .eq("availability", "active"),
    countSince("listings", todayStart),
    countSince("listings", yesterdayStart, todayStart),
    countSince("profiles", todayStart),
    countSince("profiles", yesterdayStart, todayStart),
    supabase.from("reports").select("id", { count: "exact", head: true }).eq("status", "pending"),
    supabase.from("listings").select("created_at").gte("created_at", thirtyDaysAgo),
    supabase.from("profiles").select("created_at").gte("created_at", thirtyDaysAgo),
    supabase.from("listings").select(LISTING_CARD_SELECT).order("created_at", { ascending: false }).limit(10),
    supabase.from("reports").select(REPORT_SELECT).eq("status", "pending").order("created_at", { ascending: false }).limit(5),
  ]);

  const listingsSeries = buildDailySeries(
    (listingDates.data ?? []) as { created_at: string }[],
    30,
    (r) => r.created_at,
  );
  const usersSeries = buildDailySeries(
    (userDates.data ?? []) as { created_at: string }[],
    30,
    (r) => r.created_at,
  );

  const recentListings = (recentListingsRes.data ?? []) as unknown as ListingCard[];
  const recentReports = (recentReportsRes.data ?? []) as unknown as ReportWithRelations[];

  return (
    <div className="space-y-6">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="إجمالي المستخدمين"
          value={formatNumber(totalUsers.count ?? 0)}
          icon={Users}
          trend={trendPct(usersToday, usersYesterday)}
          accent="blue"
        />
        <StatCard
          label="الإعلانات النشطة"
          value={formatNumber(activeListings.count ?? 0)}
          icon={Package}
          accent="primary"
        />
        <StatCard
          label="إعلانات اليوم"
          value={formatNumber(listingsToday)}
          icon={TrendingUp}
          trend={trendPct(listingsToday, listingsYesterday)}
          accent="amber"
        />
        <StatCard
          label="بلاغات قيد الانتظار"
          value={formatNumber(pendingReports.count ?? 0)}
          icon={Flag}
          accent="red"
        />
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>الإعلانات الجديدة — آخر ٣٠ يوم</CardTitle>
          </CardHeader>
          <CardContent>
            <ListingsChart data={listingsSeries} />
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>المستخدمون الجدد — آخر ٣٠ يوم</CardTitle>
          </CardHeader>
          <CardContent>
            <UsersChart data={usersSeries} />
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="flex-row items-center justify-between">
          <CardTitle>أحدث الإعلانات</CardTitle>
          <Button asChild variant="outline" size="sm">
            <Link href="/dashboard/listings">عرض الكل</Link>
          </Button>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>الإعلان</TableHead>
                <TableHead>البائع</TableHead>
                <TableHead>السعر</TableHead>
                <TableHead>المحافظة</TableHead>
                <TableHead>الوقت</TableHead>
                <TableHead>الحالة</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recentListings.map((listing) => (
                <TableRow key={listing.id}>
                  <TableCell>
                    <Link
                      href={`/dashboard/listings/${listing.id}`}
                      className="flex items-center gap-3 hover:text-primary"
                    >
                      <Thumbnail
                        src={coverImage(listing.listing_images)}
                        alt={listing.title}
                        className="size-10"
                      />
                      <span className="line-clamp-1 font-medium">{listing.title}</span>
                    </Link>
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {listing.seller?.full_name || listing.seller?.display_name || "—"}
                  </TableCell>
                  <TableCell>{formatIqd(listing.price_iqd)}</TableCell>
                  <TableCell>{governorateNameAr(listing.governorate)}</TableCell>
                  <TableCell className="text-muted-foreground">
                    {formatRelative(listing.created_at)}
                  </TableCell>
                  <TableCell>
                    <ListingStatusBadge status={listing.status} />
                  </TableCell>
                </TableRow>
              ))}
              {recentListings.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="py-8 text-center text-muted-foreground">
                    لا توجد إعلانات
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex-row items-center justify-between">
          <CardTitle>أحدث البلاغات</CardTitle>
          <Button asChild variant="outline" size="sm">
            <Link href="/dashboard/reports">عرض الكل</Link>
          </Button>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>الإعلان</TableHead>
                <TableHead>السبب</TableHead>
                <TableHead>المُبلِّغ</TableHead>
                <TableHead>الوقت</TableHead>
                <TableHead>إجراء</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recentReports.map((report) => (
                <TableRow key={report.id}>
                  <TableCell>
                    {report.listing ? (
                      <Link
                        href={`/dashboard/listings/${report.listing.id}`}
                        className="line-clamp-1 font-medium hover:text-primary"
                      >
                        {report.listing.title}
                      </Link>
                    ) : (
                      <span className="text-muted-foreground">إعلان محذوف</span>
                    )}
                  </TableCell>
                  <TableCell className="max-w-xs">
                    <span className="line-clamp-1">{report.reason}</span>
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {report.reporter?.full_name || report.reporter?.display_name || "—"}
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {formatRelative(report.created_at)}
                  </TableCell>
                  <TableCell>
                    <ResolveReportButton reportId={report.id} />
                  </TableCell>
                </TableRow>
              ))}
              {recentReports.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="py-8 text-center text-muted-foreground">
                    <Badge variant="success">لا توجد بلاغات معلّقة</Badge>
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
