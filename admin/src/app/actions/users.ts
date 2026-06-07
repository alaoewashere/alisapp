"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

function revalidateUsers(id?: string) {
  revalidatePath("/dashboard/users");
  revalidatePath("/dashboard");
  if (id) revalidatePath(`/dashboard/users/${id}`);
}

export async function setUserVerified(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const value = String(formData.get("value") ?? "") === "true";
  if (!id) return actionError("مستخدم غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase.from("profiles").update({ is_verified: value }).eq("id", id);
  if (error) return actionError(error.message);
  revalidateUsers(id);
  return actionOk;
}

export async function suspendUser(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const reason = String(formData.get("reason") ?? "").trim();
  if (!id) return actionError("مستخدم غير صالح");
  if (!reason) return actionError("الرجاء كتابة سبب التعليق");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("profiles")
    .update({
      is_suspended: true,
      suspended_reason: reason,
      suspended_at: new Date().toISOString(),
    })
    .eq("id", id);
  if (error) return actionError(error.message);
  revalidateUsers(id);
  return actionOk;
}

export async function unsuspendUser(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("مستخدم غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("profiles")
    .update({ is_suspended: false, suspended_reason: null, suspended_at: null })
    .eq("id", id);
  if (error) return actionError(error.message);
  revalidateUsers(id);
  return actionOk;
}

/** Soft-delete a user account (hides from public, mirrors app delete). */
export async function deleteUser(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("مستخدم غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase.from("profiles").update({ is_deleted: true }).eq("id", id);
  if (error) return actionError(error.message);
  revalidateUsers(id);
  return actionOk;
}
