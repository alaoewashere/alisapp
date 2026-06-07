import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, BadgeCheck } from "lucide-react";

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
import { ListingStatusBadge, UserStatusBadge } from "@/components/ui/status-badge";
import {
  DeleteUserButton,
  SuspendUserButton,
  UnsuspendUserButton,
  VerifyButton,
} from "@/app/dashboard/users/user-actions";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import type { ListingRow, ProfileRow, ReportRow } from "@/lib/types/database.types";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatIqd, formatNumber } from "@/lib/utils/format-iqd";
import { formatDate } from "@/lib/utils/format-date";

export const dynamic = "force-dynamic";

type ListingLite = Pick<
  ListingRow,
  "id" | "title" | "price_iqd" | "status" | "availability" | "views_count" | "created_at"
>;
type ReportLite = Pick<ReportRow, "id" | "reason" | "status" | "created_at"> & {
  listing: Pick<ListingRow, "id" | "title"> | null;
};

export default async function UserDetailPage({ params }: { params: { id: string } }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const { data: profileData } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", params.id)
    .maybeSingle();
  if (!profileData) notFound();
  const profile = profileData as ProfileRow;

  const [allListingsRes, recentRes, reportsMadeRes, reportsReceivedRes] = await Promise.all([
    supabase.from("listings").select("status, availability, views_count").eq("user_id", params.id),
    supabase
      .from("listings")
      .select("id, title, price_iqd, status, availability, views_count, created_at")
      .eq("user_id", params.id)
      .order("created_at", { ascending: false })
      .limit(10),
    supabase
      .from("reports")
      .select("id, reason, status, created_at, listing:listings!reports_listing_id_fkey(id, title)")
      .eq("reporter_id", params.id)
      .order("created_at", { ascending: false })
      .limit(10),
    supabase
      .from("reports")
      .select("id, reason, status, created_at, listing:listings!reports_listing_id_fkey!inner(id, title, user_id)")
      .eq("listing.user_id", params.id)
      .order("created_at", { ascending: false })
      .limit(10),
  ]);

  const allListings = (allListingsRes.data ?? []) as Pick<
    ListingRow,
    "status" | "availability" | "views_count"
  >[];
  const stats = {
    total: allListings.length,
    active: allListings.filter((l) => l.status === "approved" && l.availability === "active").length,
    sold: allListings.filter((l) => l.availability === "sold").length,
    views: allListings.reduce((sum, l) => sum + (l.views_count ?? 0), 0),
  };

  const recent = (recentRes.data ?? []) as unknown as ListingLite[];
  const reportsMade = (reportsMadeRes.data ?? []) as unknown as ReportLite[];
  const reportsReceived = (reportsReceivedRes.data ?? []) as unknown as ReportLite[];
  const name = profile.full_name || profile.display_name || "—";

  return (
    <div className="space-y-4">
      <Button asChild variant="ghost" size="sm">
        <Link href="/dashboard/users">
          <ArrowRight className="size-4" /> العودة للمستخدمين
        </Link>
      </Button>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4">
          <Card>
            <CardContent className="space-y-4 p-6 text-center">
              <div className="mx-auto flex size-20 items-center justify-center rounded-full bg-muted text-2xl font-bold">
                {name.charAt(0)}
              </div>
              <div>
                <h2 className="flex items-center justify-center gap-1 text-lg font-bold">
                  {name}
                  {profile.is_verified && <BadgeCheck className="size-5 text-primary" />}
                </h2>
                <p dir="ltr" className="text-sm text-muted-foreground">{profile.phone ?? "—"}</p>
              </div>
              <div className="flex justify-center">
                <UserStatusBadge suspended={profile.is_suspended} />
              </div>
              {profile.is_suspended && profile.suspended_reason && (
                <p className="rounded-md bg-red-50 p-2 text-xs text-red-700">
                  سبب التعليق: {profile.suspended_reason}
                </p>
              )}
              <div className="space-y-1 text-sm text-muted-foreground">
                <p>المحافظة: {governorateNameAr(profile.governorate)}</p>
                <p>عضو منذ: {formatDate(profile.created_at)}</p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>الإجراءات</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-2">
              <VerifyButton id={profile.id} verified={profile.is_verified} />
              {profile.is_suspended ? (
                <UnsuspendUserButton id={profile.id} />
              ) : (
                <SuspendUserButton id={profile.id} />
              )}
              <DeleteUserButton id={profile.id} />
            </CardContent>
          </Card>
        </div>

        <div className="space-y-4 lg:col-span-2">
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <StatBox label="إجمالي الإعلانات" value={formatNumber(stats.total)} />
            <StatBox label="نشطة" value={formatNumber(stats.active)} />
            <StatBox label="مباعة" value={formatNumber(stats.sold)} />
            <StatBox label="إجمالي المشاهدات" value={formatNumber(stats.views)} />
          </div>

          <Card>
            <CardHeader>
              <CardTitle>أحدث الإعلانات</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>العنوان</TableHead>
                    <TableHead>السعر</TableHead>
                    <TableHead>المشاهدات</TableHead>
                    <TableHead>التاريخ</TableHead>
                    <TableHead>الحالة</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {recent.map((l) => (
                    <TableRow key={l.id}>
                      <TableCell>
                        <Link href={`/dashboard/listings/${l.id}`} className="line-clamp-1 hover:text-primary">
                          {l.title}
                        </Link>
                      </TableCell>
                      <TableCell>{formatIqd(l.price_iqd)}</TableCell>
                      <TableCell>{l.views_count}</TableCell>
                      <TableCell className="text-muted-foreground">{formatDate(l.created_at)}</TableCell>
                      <TableCell>
                        <ListingStatusBadge status={l.status} />
                      </TableCell>
                    </TableRow>
                  ))}
                  {recent.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={5} className="py-6 text-center text-muted-foreground">
                        لا توجد إعلانات
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>

          <div className="grid gap-4 md:grid-cols-2">
            <ReportsList title="بلاغات قدّمها" reports={reportsMade} />
            <ReportsList title="بلاغات على إعلاناته" reports={reportsReceived} />
          </div>
        </div>
      </div>
    </div>
  );
}

function StatBox({ label, value }: { label: string; value: string }) {
  return (
    <Card className="p-4">
      <p className="text-sm text-muted-foreground">{label}</p>
      <p className="mt-1 text-2xl font-bold">{value}</p>
    </Card>
  );
}

function ReportsList({ title, reports }: { title: string; reports: ReportLite[] }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">
          {title} ({reports.length})
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        {reports.length === 0 && <p className="text-sm text-muted-foreground">لا يوجد</p>}
        {reports.map((r) => (
          <div key={r.id} className="rounded-md border border-border p-2 text-sm">
            <div className="flex items-center justify-between gap-2">
              <span className="line-clamp-1">{r.reason}</span>
              <Badge variant={r.status === "pending" ? "warning" : "muted"}>
                {r.status === "pending" ? "معلّق" : "مغلق"}
              </Badge>
            </div>
            {r.listing && (
              <Link href={`/dashboard/listings/${r.listing.id}`} className="text-xs text-muted-foreground hover:text-primary">
                {r.listing.title}
              </Link>
            )}
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
