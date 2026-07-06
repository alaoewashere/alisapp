"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

/** Admin reply to a user's support thread. */
export async function sendSupportReply(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const userId = String(formData.get("userId") ?? "");
  const body = String(formData.get("body") ?? "").trim();
  if (!userId) return actionError("محادثة غير صالحة");
  if (!body) return actionError("لا يمكن إرسال رسالة فارغة");

  const supabase = createAdminClient();
  const { error } = await supabase.from("support_messages").insert({
    user_id: userId,
    sender_role: "admin",
    body,
  });
  if (error) return actionError(error.message);

  // Replying implicitly means the admin has seen the user's messages.
  await supabase
    .from("support_messages")
    .update({ is_read: true })
    .eq("user_id", userId)
    .eq("sender_role", "user")
    .eq("is_read", false);

  revalidatePath(`/dashboard/support-messages/${userId}`);
  revalidatePath("/dashboard/support-messages");
  revalidatePath("/dashboard");
  return actionOk;
}

/** Marks a user's messages as read without replying (e.g. just opening the thread). */
export async function markSupportThreadRead(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const userId = String(formData.get("userId") ?? "");
  if (!userId) return actionError("محادثة غير صالحة");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("support_messages")
    .update({ is_read: true })
    .eq("user_id", userId)
    .eq("sender_role", "user")
    .eq("is_read", false);
  if (error) return actionError(error.message);

  revalidatePath("/dashboard/support-messages");
  revalidatePath("/dashboard");
  return actionOk;
}
