"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

function slugify(input: string): string {
  return (
    input
      .trim()
      .toLowerCase()
      .replace(/[^\p{L}\p{N}]+/gu, "_")
      .replace(/^_+|_+$/g, "") || `cat_${Date.now()}`
  );
}

export async function createCategory(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const nameAr = String(formData.get("name_ar") ?? "").trim();
  const parentRaw = String(formData.get("parent_id") ?? "").trim();
  const icon = String(formData.get("icon") ?? "").trim() || "category";
  if (!nameAr) return actionError("الرجاء إدخال اسم الفئة");
  const parentId = parentRaw ? Number(parentRaw) : null;

  const supabase = createAdminClient();
  const orderQuery = supabase
    .from("categories")
    .select("display_order")
    .order("display_order", { ascending: false })
    .limit(1);
  const { data: maxRow } = await (parentId == null
    ? orderQuery.is("parent_id", null)
    : orderQuery.eq("parent_id", parentId)
  ).maybeSingle();

  const { error } = await supabase.from("categories").insert({
    name_ar: nameAr,
    slug: slugify(nameAr),
    icon,
    parent_id: parentId,
    display_order: (maxRow?.display_order ?? 0) + 1,
  });
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/categories");
  return actionOk;
}

export async function updateCategory(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = Number(formData.get("id"));
  const nameAr = String(formData.get("name_ar") ?? "").trim();
  const icon = String(formData.get("icon") ?? "").trim();
  if (!id || !nameAr) return actionError("بيانات غير صالحة");

  const supabase = createAdminClient();
  const patch: { name_ar: string; icon?: string } = { name_ar: nameAr };
  if (icon) patch.icon = icon;
  const { error } = await supabase.from("categories").update(patch).eq("id", id);
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/categories");
  return actionOk;
}

export async function deleteCategory(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = Number(formData.get("id"));
  if (!id) return actionError("فئة غير صالحة");

  const supabase = createAdminClient();
  const { count } = await supabase
    .from("listings")
    .select("id", { count: "exact", head: true })
    .eq("category_id", id);
  if ((count ?? 0) > 0) {
    return actionError("لا يمكن حذف فئة تحتوي على إعلانات");
  }

  const { count: childCount } = await supabase
    .from("categories")
    .select("id", { count: "exact", head: true })
    .eq("parent_id", id);
  if ((childCount ?? 0) > 0) {
    return actionError("لا يمكن حذف فئة تحتوي على فئات فرعية");
  }

  const { error } = await supabase.from("categories").delete().eq("id", id);
  if (error) return actionError(error.message);
  revalidatePath("/dashboard/categories");
  return actionOk;
}

/** Persists a new ordering for a set of sibling categories. */
export async function reorderCategories(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const ids = String(formData.get("ids") ?? "")
    .split(",")
    .map((s) => Number(s.trim()))
    .filter((n) => Number.isFinite(n) && n > 0);
  if (ids.length === 0) return actionError("ترتيب غير صالح");

  const supabase = createAdminClient();
  for (let i = 0; i < ids.length; i++) {
    const { error } = await supabase
      .from("categories")
      .update({ display_order: i + 1 })
      .eq("id", ids[i]);
    if (error) return actionError(error.message);
  }
  revalidatePath("/dashboard/categories");
  return actionOk;
}
