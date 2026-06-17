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

async function updateListingRow(
  id: string,
  patch: Partial<ListingRow>,
  expectedStatus?: ListingStatus,
): Promise<ActionResult> {
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("listings")
    .update(patch)
    .eq("id", id)
    .select("id, status")
    .maybeSingle();

  if (error) return actionError(error.message);
  if (!data) return actionError("لم يتم العثور على الإعلان");

  if (expectedStatus && data.status !== expectedStatus) {
    return actionError(
      `تعذّر تحديث حالة الإعلان (الحالة الحالية: ${data.status}). تحقق من صلاحيات المشرف واتصال Supabase.`,
    );
  }

  return actionOk;
}

export async function setListingStatus(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  const reason = String(formData.get("reason") ?? "").trim();

  if (!id || !STATUS_VALUES.includes(status as ListingStatus)) {
    return actionError("بيانات غير صالحة");
  }

  const listingStatus = status as ListingStatus;
  const result = await updateListingRow(
    id,
    {
      status: listingStatus,
      rejection_reason: listingStatus === "rejected" ? reason || null : null,
      reviewed_at: new Date().toISOString(),
    },
    listingStatus,
  );

  if (!result.ok) return result;
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

export async function setListingPackage(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "");
  const packageTier = String(formData.get("package") ?? "");
  if (!id || !["standard", "pro", "premium"].includes(packageTier)) {
    return actionError("بيانات غير صالحة");
  }

  const supabase = createAdminClient();
  const { data: listing, error: fetchError } = await supabase
    .from("listings")
    .select("metadata")
    .eq("id", id)
    .maybeSingle();

  if (fetchError) return actionError(fetchError.message);
  if (!listing) return actionError("لم يتم العثور على الإعلان");

  const metadata =
    listing.metadata && typeof listing.metadata === "object" && !Array.isArray(listing.metadata)
      ? { ...(listing.metadata as Record<string, unknown>) }
      : {};

  metadata.listing_package = packageTier;

  const patch: Partial<ListingRow> = {
    metadata,
    is_featured: packageTier === "premium",
    is_boosted: packageTier === "pro",
    is_verified_seller: packageTier === "pro" || packageTier === "premium",
  };

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
    title: "تحذير من إدارة Sello",
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

  const { data, error } = await supabase
    .from("listings")
    .update(patch)
    .in("id", ids)
    .select("id, status");

  if (error) return actionError(error.message);

  if (op === "approve") {
    const notApproved = (data ?? []).filter((row) => row.status !== "approved");
    if (notApproved.length > 0) {
      return actionError(
        `تعذّر قبول ${notApproved.length} إعلان — لم يتم تحديث الحالة في قاعدة البيانات.`,
      );
    }
  }

  revalidateListings();
  return actionOk;
}
