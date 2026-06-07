import type { ListingStatus, ReportStatus } from "@/lib/types/database.types";

export function parseListingStatus(value: string | undefined): ListingStatus | undefined {
  if (value === "pending" || value === "approved" || value === "rejected") return value;
  return undefined;
}

export function parseReportStatus(value: string | undefined): ReportStatus | undefined {
  if (value === "pending" || value === "resolved" || value === "dismissed") return value;
  return undefined;
}
