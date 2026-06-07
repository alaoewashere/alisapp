import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, Eye, Heart, MapPin } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ActionDialog } from "@/components/ui/action-dialog";
import { Thumbnail } from "@/components/ui/thumbnail";
import {
  AvailabilityBadge,
  ListingStatusBadge,
  ReportStatusBadge,
} from "@/components/ui/status-badge";
import {
  FlagSwitch,
  StatusControl,
} from "@/app/dashboard/listings/[id]/listing-controls";
import { ResolveReportButton } from "@/app/dashboard/reports/report-actions";
import { deleteListing, setListingStatus, warnSeller } from "@/app/actions/listings";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { LISTING_DETAIL_SELECT } from "@/lib/data/selects";
import type { ListingDetail } from "@/lib/data/types";
import type { ReportRow, ProfileRow } from "@/lib/types/database.types";
import { governorateNameAr } from "@/lib/constants/governorates";
import { formatIqd } from "@/lib/utils/format-iqd";
import { formatDateTime } from "@/lib/utils/format-date";
import { publicImageUrl } from "@/lib/utils/image-url";

export const dynamic = "force-dynamic";

type ReportWithReporter = Pick<
  ReportRow,
  "id" | "reason" | "status" | "created_at" | "reporter_id"
> & { reporter: Pick<ProfileRow, "display_name" | "full_name"> | null };

export default async function ListingDetailPage({ params }: { params: { id: string } }) {
  await requireAdmin();
  const supabase = createAdminClient();

  const [{ data: listingData }, favoritesRes, reportsRes] = await Promise.all([
    supabase.from("listings").select(LISTING_DETAIL_SELECT).eq("id", params.id).maybeSingle(),
    supabase.from("favorites").select("id", { count: "exact", head: true }).eq("listing_id", params.id),
    supabase
      .from("reports")
      .select("id, reason, status, created_at, reporter_id, reporter:profiles!reports_reporter_id_fkey(display_name, full_name)")
      .eq("listing_id", params.id)
      .order("created_at", { ascending: false }),
  ]);

  if (!listingData) notFound();
  const listing = listingData as unknown as ListingDetail;
  const reports = (reportsRes.data ?? []) as unknown as ReportWithReporter[];
  const favoritesCount = favoritesRes.count ?? 0;

  const images = [...listing.listing_images].sort((a, b) => {
    if (a.is_primary !== b.is_primary) return a.is_primary ? -1 : 1;
    return a.sort_order - b.sort_order;
  });
  const sellerName =
    listing.seller?.full_name || listing.seller?.display_name || "بائع غير معروف";

  return (
    <div className="space-y-4">
      <Button asChild variant="ghost" size="sm">
        <Link href="/dashboard/listings">
          <ArrowRight className="size-4" /> العودة للإعلانات
        </Link>
      </Button>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Left: media + details */}
        <div className="space-y-4 lg:col-span-2">
          <Card>
            <CardContent className="p-4">
              {images.length > 0 ? (
                <div className="space-y-3">
                  <Thumbnail
                    src={publicImageUrl(images[0].url ?? images[0].storage_path)}
                    alt={listing.title}
                    className="aspect-video w-full"
                  />
                  {images.length > 1 && (
                    <div className="grid grid-cols-5 gap-2">
                      {images.slice(1).map((img) => (
                        <Thumbnail
                          key={img.id}
                          src={publicImageUrl(img.url ?? img.storage_path)}
                          alt={listing.title}
                          className="aspect-square w-full"
                        />
                      ))}
                    </div>
                  )}
                </div>
              ) : (
                <div className="flex h-48 items-center justify-center text-muted-foreground">
                  لا توجد صور
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>{listing.title}</CardTitle>
              <p className="text-2xl font-bold text-primary">{formatIqd(listing.price_iqd)}</p>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="whitespace-pre-wrap leading-relaxed text-muted-foreground">
                {listing.description || "لا يوجد وصف"}
              </p>
              <div className="grid grid-cols-2 gap-3 text-sm sm:grid-cols-3">
                <Detail label="الفئة" value={listing.categories?.name_ar ?? "—"} />
                <Detail label="الحالة" value={listing.condition === "new" ? "جديد" : listing.condition === "used" ? "مستعمل" : "—"} />
                <Detail label="المحافظة" value={governorateNameAr(listing.governorate)} />
                <Detail label="المدينة" value={listing.city || "—"} />
                <Detail label="قابل للتفاوض" value={listing.is_negotiable ? "نعم" : "لا"} />
                <Detail label="المشاهدات" value={String(listing.views_count)} />
              </div>
              {listing.latitude != null && listing.longitude != null && (
                <a
                  href={`https://www.google.com/maps?q=${listing.latitude},${listing.longitude}`}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-1 text-sm text-primary hover:underline"
                >
                  <MapPin className="size-4" /> عرض الموقع على الخريطة
                </a>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Right: controls */}
        <div className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>التحكم</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">حالة المراجعة</span>
                <StatusControl id={listing.id} status={listing.status} />
              </div>
              <div className="flex flex-wrap gap-2">
                <ListingStatusBadge status={listing.status} />
                <AvailabilityBadge availability={listing.availability} />
                {listing.is_featured && <Badge>مميز</Badge>}
              </div>
              <hr className="border-border" />
              <FlagSwitch id={listing.id} flag="is_featured" initial={listing.is_featured} label="إعلان مميز" />
              <FlagSwitch id={listing.id} flag="is_boosted" initial={listing.is_boosted} label="إعلان مُروَّج" />
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>البائع</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3 text-sm">
              <Link
                href={`/dashboard/users/${listing.seller?.id ?? ""}`}
                className="flex items-center gap-3 hover:text-primary"
              >
                <div className="flex size-10 items-center justify-center rounded-full bg-muted font-bold">
                  {sellerName.charAt(0)}
                </div>
                <div>
                  <p className="font-medium">{sellerName}</p>
                  <p dir="ltr" className="text-muted-foreground">{listing.seller?.phone ?? "—"}</p>
                </div>
              </Link>
              {listing.seller?.is_suspended && <Badge variant="destructive">حساب موقوف</Badge>}
              <div className="flex items-center gap-4 text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Eye className="size-4" /> {listing.views_count}
                </span>
                <span className="flex items-center gap-1">
                  <Heart className="size-4" /> {favoritesCount}
                </span>
              </div>
              <div className="space-y-1 text-xs text-muted-foreground">
                <p>أُنشئ: {formatDateTime(listing.created_at)}</p>
                <p>آخر تحديث: {formatDateTime(listing.updated_at)}</p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>إجراءات</CardTitle>
            </CardHeader>
            <CardContent className="grid gap-2">
              <ActionDialog
                action={setListingStatus}
                title="تعليق الإعلان"
                description="سيتم رفض الإعلان وإخفاؤه عن العامة."
                confirmLabel="تعليق"
                triggerLabel="تعليق الإعلان"
                triggerVariant="outline"
                hidden={{ id: listing.id, status: "rejected" }}
                fields={[
                  { name: "reason", label: "سبب التعليق (اختياري)", type: "textarea", placeholder: "السبب..." },
                ]}
              />
              {listing.seller && (
                <ActionDialog
                  action={warnSeller}
                  title="تحذير البائع"
                  description="سيتم إرسال إشعار تحذير للبائع."
                  confirmLabel="إرسال"
                  triggerLabel="إرسال تحذير للبائع"
                  triggerVariant="outline"
                  hidden={{ listingId: listing.id, sellerId: listing.seller.id }}
                  fields={[
                    { name: "reason", label: "نص التحذير", type: "textarea", required: true },
                  ]}
                />
              )}
              <ActionDialog
                action={deleteListing}
                title="حذف الإعلان"
                description="سيتم نقل الإعلان إلى المحذوفات."
                confirmLabel="حذف الإعلان"
                confirmVariant="destructive"
                triggerLabel="حذف الإعلان"
                triggerVariant="destructive"
                hidden={{ id: listing.id }}
              />
            </CardContent>
          </Card>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>البلاغات ({reports.length})</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {reports.length === 0 && (
            <p className="text-sm text-muted-foreground">لا توجد بلاغات على هذا الإعلان</p>
          )}
          {reports.map((report) => (
            <div
              key={report.id}
              className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-border p-3"
            >
              <div className="space-y-1">
                <p className="text-sm font-medium">{report.reason}</p>
                <p className="text-xs text-muted-foreground">
                  {report.reporter?.full_name || report.reporter?.display_name || "—"} ·{" "}
                  {formatDateTime(report.created_at)}
                </p>
              </div>
              <div className="flex items-center gap-2">
                <ReportStatusBadge status={report.status} />
                {report.status === "pending" && <ResolveReportButton reportId={report.id} />}
              </div>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}

function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-muted-foreground">{label}</p>
      <p className="font-medium text-foreground">{value}</p>
    </div>
  );
}
