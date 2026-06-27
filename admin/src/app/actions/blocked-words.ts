"use server";

import { revalidatePath } from "next/cache";

import type { BlockedWordRow } from "@/lib/types/database.types";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { actionError, actionOk, type ActionResult } from "@/lib/actions/types";

function normalizeWord(input: string): string {
  let text = input.trim().toLowerCase();
  text = text.replace(/[\u064B-\u065F\u0670]/g, "");
  text = text.replace(/[أإآٱةىؤئ]/g, (ch) => {
    switch (ch) {
      case "أ":
      case "إ":
      case "آ":
      case "ٱ":
        return "ا";
      case "ة":
        return "ه";
      case "ى":
      case "ئ":
        return "ي";
      case "ؤ":
        return "و";
      default:
        return ch;
    }
  });

  let out = "";
  let prev = "";
  let repeat = 0;
  for (const ch of text) {
    if (!/[\p{L}\p{N}]/u.test(ch)) {
      prev = "";
      repeat = 0;
      continue;
    }
    if (ch === prev) {
      repeat += 1;
      if (repeat >= 2) continue;
    } else {
      repeat = 0;
    }
    out += ch;
    prev = ch;
  }
  return out;
}

function parseSeverity(raw: FormDataEntryValue | null): BlockedWordRow["severity"] {
  const value = String(raw ?? "high");
  if (value === "low" || value === "medium" || value === "high") return value;
  return "high";
}

export async function createBlockedWord(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const word = String(formData.get("word") ?? "").trim();
  if (!word) return actionError("الرجاء إدخال كلمة");

  const normalized = normalizeWord(word);
  if (!normalized) return actionError("الكلمة غير صالحة بعد التطبيع");

  const supabase = createAdminClient();
  const { error } = await supabase.from("blocked_words").insert({
    word,
    normalized_form: normalized,
    severity: parseSeverity(formData.get("severity")),
    active: true,
  });

  if (error) return actionError(error.message);
  revalidatePath("/dashboard/blocked-words");
  return actionOk;
}

export async function toggleBlockedWord(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "").trim();
  const active = String(formData.get("active") ?? "") === "true";
  if (!id) return actionError("معرّف غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase
    .from("blocked_words")
    .update({ active })
    .eq("id", id);

  if (error) return actionError(error.message);
  revalidatePath("/dashboard/blocked-words");
  return actionOk;
}

export async function deleteBlockedWord(formData: FormData): Promise<ActionResult> {
  await requireAdmin();
  const id = String(formData.get("id") ?? "").trim();
  if (!id) return actionError("معرّف غير صالح");

  const supabase = createAdminClient();
  const { error } = await supabase.from("blocked_words").delete().eq("id", id);

  if (error) return actionError(error.message);
  revalidatePath("/dashboard/blocked-words");
  return actionOk;
}
