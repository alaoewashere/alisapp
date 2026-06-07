import { Badge, type BadgeProps } from "@/components/ui/badge";
import type {
  ListingAvailability,
  ListingStatus,
  ReportStatus,
} from "@/lib/types/database.types";

const listingStatusMap: Record<ListingStatus, { label: string; variant: BadgeProps["variant"] }> = {
  approved: { label: "مقبول", variant: "success" },
  pending: { label: "قيد المراجعة", variant: "warning" },
  rejected: { label: "مرفوض", variant: "destructive" },
};

const availabilityMap: Record<
  ListingAvailability,
  { label: string; variant: BadgeProps["variant"] }
> = {
  active: { label: "نشط", variant: "success" },
  sold: { label: "مباع", variant: "secondary" },
  deleted: { label: "محذوف", variant: "destructive" },
};

const reportStatusMap: Record<ReportStatus, { label: string; variant: BadgeProps["variant"] }> = {
  pending: { label: "قيد الانتظار", variant: "warning" },
  resolved: { label: "تم الحل", variant: "success" },
  dismissed: { label: "مرفوض", variant: "muted" },
};

export function ListingStatusBadge({ status }: { status: ListingStatus }) {
  const config = listingStatusMap[status];
  return <Badge variant={config.variant}>{config.label}</Badge>;
}

export function AvailabilityBadge({ availability }: { availability: ListingAvailability }) {
  const config = availabilityMap[availability];
  return <Badge variant={config.variant}>{config.label}</Badge>;
}

export function ReportStatusBadge({ status }: { status: ReportStatus }) {
  const config = reportStatusMap[status];
  return <Badge variant={config.variant}>{config.label}</Badge>;
}

export function UserStatusBadge({ suspended }: { suspended: boolean }) {
  return suspended ? (
    <Badge variant="destructive">موقوف</Badge>
  ) : (
    <Badge variant="success">نشط</Badge>
  );
}
