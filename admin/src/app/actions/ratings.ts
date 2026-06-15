"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

function revalidateRatings() {
  revalidatePath("/dashboard/ratings");
  revalidatePath("/dashboard");
}

export async function hideRating(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  if (!id) return actionError("معرّف التقييم مطلوب");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("ratings")
    .update({ hidden: true })
    .eq("id", id);

  if (error) return actionError(error.message);
  revalidateRatings();
  return actionOk;
}
