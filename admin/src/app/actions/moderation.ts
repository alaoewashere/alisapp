"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

type BanDuration = "1d" | "7d" | "30d" | "custom" | "permanent";

function computeBannedUntil(
  duration: BanDuration,
  customDays?: number,
): string | null {
  if (duration === "permanent") return null;

  const until = new Date();
  const days =
    duration === "1d"
      ? 1
      : duration === "7d"
        ? 7
        : duration === "30d"
          ? 30
          : Math.max(1, customDays ?? 1);
  until.setDate(until.getDate() + days);
  return until.toISOString();
}

export async function banUserPosting(formData: FormData): Promise<ActionResult> {
  const session = await requireAdmin();
  const userId = String(formData.get("userId") ?? "").trim();
  const duration = String(formData.get("duration") ?? "") as BanDuration;
  const customDays = Number(formData.get("customDays") ?? "0");

  if (!userId) return actionError("معرّف المستخدم غير صالح");
  if (!["1d", "7d", "30d", "custom", "permanent"].includes(duration)) {
    return actionError("مدة الحظر غير صالحة");
  }
  if (duration === "custom" && (!customDays || customDays < 1)) {
    return actionError("أدخل عدد أيام صالحاً");
  }

  const supabase = createAdminClient();
  const { data: profile, error: fetchError } = await supabase
    .from("profiles")
    .select("ban_count")
    .eq("id", userId)
    .maybeSingle();

  if (fetchError) return actionError(fetchError.message);
  if (!profile) return actionError("المستخدم غير موجود");

  const bannedUntil = computeBannedUntil(duration, customDays);
  const banCount = ((profile as { ban_count?: number }).ban_count ?? 0) + 1;

  const { error } = await supabase
    .from("profiles")
    .update({
      is_banned: true,
      banned_until: bannedUntil,
      ban_reason: "admin_manual",
      banned_by: session.userId,
      ban_count: banCount,
    })
    .eq("id", userId);

  if (error) return actionError(error.message);
  revalidatePath("/dashboard/moderation");
  return actionOk;
}

export async function unbanUserPosting(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const userId = String(formData.get("userId") ?? "").trim();
  if (!userId) return actionError("معرّف المستخدم غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("profiles")
    .update({
      is_banned: false,
      banned_until: null,
    })
    .eq("id", userId);

  if (error) return actionError(error.message);
  revalidatePath("/dashboard/moderation");
  return actionOk;
}
