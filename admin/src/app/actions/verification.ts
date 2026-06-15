"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

function revalidateVerification() {
  revalidatePath("/dashboard/verification");
  revalidatePath("/dashboard/users");
  revalidatePath("/dashboard");
}

export async function approveVerificationRequest(
  formData: FormData,
): Promise<ActionResult> {
  const session = await requireAdmin();
  const requestId = String(formData.get("requestId") ?? "");
  const userId = String(formData.get("userId") ?? "");
  if (!requestId || !userId) return actionError("طلب غير صالح");

  const supabase = createAdminClient();
  const now = new Date().toISOString();

  const { error: reqError } = await supabase
    .from("verification_requests")
    .update({
      status: "verified",
      reviewed_by: session.userId,
      reviewed_at: now,
      rejection_reason: null,
    })
    .eq("id", requestId);

  if (reqError) return actionError(reqError.message);

  const { error: profileError } = await supabase
    .from("profiles")
    .update({
      verification_status: "verified",
      verification_reviewed_at: now,
      is_verified: true,
      rejection_reason: null,
    })
    .eq("id", userId);

  if (profileError) return actionError(profileError.message);

  revalidateVerification();
  return actionOk;
}

export async function rejectVerificationRequest(
  formData: FormData,
): Promise<ActionResult> {
  const session = await requireAdmin();
  const requestId = String(formData.get("requestId") ?? "");
  const userId = String(formData.get("userId") ?? "");
  const reason = String(formData.get("reason") ?? "").trim();
  if (!requestId || !userId) return actionError("طلب غير صالح");
  if (!reason) return actionError("الرجاء كتابة سبب الرفض");

  const supabase = createAdminClient();
  const now = new Date().toISOString();

  const { error: reqError } = await supabase
    .from("verification_requests")
    .update({
      status: "rejected",
      reviewed_by: session.userId,
      reviewed_at: now,
      rejection_reason: reason,
    })
    .eq("id", requestId);

  if (reqError) return actionError(reqError.message);

  const { error: profileError } = await supabase
    .from("profiles")
    .update({
      verification_status: "rejected",
      verification_reviewed_at: now,
      is_verified: false,
      rejection_reason: reason,
    })
    .eq("id", userId);

  if (profileError) return actionError(profileError.message);

  revalidateVerification();
  return actionOk;
}

export async function signedVerificationDocUrl(
  storagePath: string,
): Promise<string | null> {
  await requireAdmin();
  if (!storagePath) return null;

  const supabase = createAdminClient();
  const { data, error } = await supabase.storage
    .from("verification-docs")
    .createSignedUrl(storagePath, 3600);

  if (error || !data?.signedUrl) return null;
  return data.signedUrl;
}
