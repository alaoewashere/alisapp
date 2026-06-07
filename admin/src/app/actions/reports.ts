"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";
import type { ReportStatus } from "@/lib/types/database.types";

function revalidateReports() {
  revalidatePath("/dashboard/reports");
  revalidatePath("/dashboard");
}

async function updateReportStatus(
  reportId: string,
  status: ReportStatus,
  adminId: string,
  note?: string,
): Promise<ActionResult> {
  const supabase = createAdminClient();
  const { error } = await supabase
    .from("reports")
    .update({
      status,
      resolved_at: status === "pending" ? null : new Date().toISOString(),
      resolved_by: status === "pending" ? null : adminId,
      admin_note: note ?? null,
    })
    .eq("id", reportId);
  if (error) return actionError(error.message);
  revalidateReports();
  return actionOk;
}

export async function resolveReport(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("بلاغ غير صالح");
  return updateReportStatus(id, "resolved", session.userId, String(formData.get("note") ?? "") || undefined);
}

export async function dismissReport(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("بلاغ غير صالح");
  return updateReportStatus(id, "dismissed", session.userId);
}

/** Delete the reported listing (soft) and mark the report resolved. */
export async function deleteListingFromReport(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const listingId = String(formData.get("listingId") ?? "");
  if (!id || !listingId) return actionError("بيانات غير صالحة");

  const supabase = createAdminClient();
  const { error: delError } = await supabase
    .from("listings")
    .update({ availability: "deleted" })
    .eq("id", listingId);
  if (delError) return actionError(delError.message);

  revalidatePath(`/dashboard/listings/${listingId}`);
  return updateReportStatus(id, "resolved", session.userId, "تم حذف الإعلان");
}

/** Suspend the reported listing's owner and resolve the report. */
export async function suspendSellerFromReport(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const sellerId = String(formData.get("sellerId") ?? "");
  const reason = String(formData.get("reason") ?? "").trim() || "مخالفة شروط الاستخدام";
  if (!id || !sellerId) return actionError("بيانات غير صالحة");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("profiles")
    .update({
      is_suspended: true,
      suspended_reason: reason,
      suspended_at: new Date().toISOString(),
    })
    .eq("id", sellerId);
  if (error) return actionError(error.message);

  revalidatePath("/dashboard/users");
  return updateReportStatus(id, "resolved", session.userId, "تم تعليق حساب البائع");
}

export async function bulkReportAction(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const ids = String(formData.get("ids") ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  const op = String(formData.get("op") ?? "");
  if (ids.length === 0) return actionError("لم يتم تحديد أي بلاغ");
  const status: ReportStatus = op === "dismiss" ? "dismissed" : "resolved";

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("reports")
    .update({
      status,
      resolved_at: new Date().toISOString(),
      resolved_by: session.userId,
    })
    .in("id", ids);
  if (error) return actionError(error.message);
  revalidateReports();
  return actionOk;
}
