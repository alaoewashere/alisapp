"use server";

import { revalidatePath } from "next/cache";

import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";
import type { ListingRow, ListingStatus } from "@/lib/types/database.types";

function revalidateListings(id?: string) {
  revalidatePath("/dashboard/listings");
  revalidatePath("/dashboard");
  if (id) revalidatePath(`/dashboard/listings/${id}`);
}

const STATUS_VALUES: ListingStatus[] = ["pending", "approved", "rejected"];

export async function setListingStatus(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  const reason = String(formData.get("reason") ?? "").trim();

  if (!id || !STATUS_VALUES.includes(status as ListingStatus)) {
    return actionError("بيانات غير صالحة");
  }

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("listings")
    .update({
      status: status as ListingStatus,
      rejection_reason: status === "rejected" ? reason || null : null,
      reviewed_at: new Date().toISOString(),
    })
    .eq("id", id);

  if (error) return actionError(error.message);
  revalidateListings(id);
  return actionOk;
}

export async function setListingAvailability(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const availability = String(formData.get("availability") ?? "");
  if (!id || !["active", "sold", "deleted"].includes(availability)) {
    return actionError("بيانات غير صالحة");
  }

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("listings")
    .update({ availability: availability as "active" | "sold" | "deleted" })
    .eq("id", id);

  if (error) return actionError(error.message);
  revalidateListings(id);
  return actionOk;
}

export async function deleteListing(formData: FormData): Promise<ActionResult> {
  // Soft delete (availability = deleted) — reversible, matches the mobile app.
  const fd = new FormData();
  fd.set("id", String(formData.get("id") ?? ""));
  fd.set("availability", "deleted");
  return setListingAvailability(fd);
}

export async function setListingFlag(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const flag = String(formData.get("flag") ?? "");
  const value = String(formData.get("value") ?? "") === "true";
  if (!id || !["is_featured", "is_boosted"].includes(flag)) {
    return actionError("بيانات غير صالحة");
  }

  const supabase = createAdminClient();
  const patch: Partial<ListingRow> =
    flag === "is_featured" ? { is_featured: value } : { is_boosted: value };
  const { error } = await supabase.from("listings").update(patch).eq("id", id);

  if (error) return actionError(error.message);
  revalidateListings(id);
  return actionOk;
}

export async function warnSeller(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const listingId = String(formData.get("listingId") ?? "");
  const sellerId = String(formData.get("sellerId") ?? "");
  const reason = String(formData.get("reason") ?? "").trim();
  if (!sellerId || !reason) return actionError("الرجاء كتابة سبب التحذير");

  const supabase = createAdminClient();
  const { error } = await supabase.from("notifications").insert({
    user_id: sellerId,
    listing_id: listingId || null,
    type: "warning",
    title: "تحذير من إدارة سوق العراق",
    body: reason,
  });

  if (error) return actionError(error.message);
  revalidateListings(listingId);
  return actionOk;
}

/** Bulk operations from the listings table selection. */
export async function bulkListingAction(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const ids = String(formData.get("ids") ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  const op = String(formData.get("op") ?? "");
  if (ids.length === 0) return actionError("لم يتم تحديد أي إعلان");

  const supabase = createAdminClient();
  const patch: Partial<ListingRow> = {};

  if (op === "delete") patch.availability = "deleted";
  else if (op === "feature") patch.is_featured = true;
  else if (op === "unfeature") patch.is_featured = false;
  else if (op === "approve") {
    patch.status = "approved";
    patch.reviewed_at = new Date().toISOString();
  } else {
    return actionError("عملية غير معروفة");
  }

  const { error } = await supabase.from("listings").update(patch).in("id", ids);
  if (error) return actionError(error.message);
  revalidateListings();
  return actionOk;
}
