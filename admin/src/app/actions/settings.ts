"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin, requireSuperAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

/** Upserts every `setting:<key>` field present in the form. */
export async function saveSettings(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const updates: { key: string; value: string; updated_at: string }[] = [];
  const now = new Date().toISOString();

  for (const [field, value] of formData.entries()) {
    if (field.startsWith("setting:")) {
      updates.push({ key: field.slice("setting:".length), value: String(value), updated_at: now });
    }
  }
  if (updates.length === 0) return actionError("لا توجد تغييرات");

  const supabase = createAdminClient();
  const { error } = await supabase.from("app_settings").upsert(updates, { onConflict: "key" });
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/settings");
  return actionOk;
}

export async function addAdmin(formData: FormData): Promise<ActionResult> {
  await requireSuperAdmin();
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const role = String(formData.get("role") ?? "admin");
  if (!email) return actionError("الرجاء إدخال البريد الإلكتروني");
  if (!["admin", "super_admin"].includes(role)) return actionError("صلاحية غير صالحة");

  const supabase = createAdminClient();
  // Resolve the auth user by email via the Admin API.
  const { data: list, error: listError } = await supabase.auth.admin.listUsers();
  if (listError) return actionError(listError.message);
  const user = list.users.find((u) => u.email?.toLowerCase() === email);
  if (!user) {
    return actionError("لا يوجد مستخدم بهذا البريد. أنشئ الحساب في Supabase أولاً.");
  }

  const { error } = await supabase
    .from("admin_users")
    .upsert({ id: user.id, email, role: role as "admin" | "super_admin" }, { onConflict: "id" });
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/settings");
  return actionOk;
}

export async function removeAdmin(formData: FormData): Promise<ActionResult> {
  const session = await requireSuperAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("مدير غير صالح");
  if (id === session.userId) return actionError("لا يمكنك إزالة نفسك");

  const supabase = createAdminClient();
  const { error } = await supabase.from("admin_users").delete().eq("id", id);
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/settings");
  return actionOk;
}
