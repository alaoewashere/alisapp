import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";

import {
  ModerationManager,
  type ModerationUserRow,
} from "./moderation-manager";

export const dynamic = "force-dynamic";

export default async function ModerationPage() {
  await requireAdmin();
  const supabase = createAdminClient();

  const { data, error } = await supabase
    .from("profiles")
    .select(
      "id, full_name, display_name, phone, moderation_violation_count, ban_count, is_banned, banned_until, ban_reason, last_moderation_violation_at",
    )
    .or(
      "moderation_violation_count.gt.0,ban_count.gt.0,is_banned.eq.true",
    )
    .order("last_moderation_violation_at", {
      ascending: false,
      nullsFirst: false,
    });

  if (error) {
    return (
      <p className="text-destructive">فشل تحميل القائمة: {error.message}</p>
    );
  }

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-bold">إدارة المخالفات</h1>
        <p className="text-sm text-muted-foreground">
          عرض المخالفين وحظر/إلغاء حظر الدردشة والنشر — منفصل عن تصفح التطبيق
          وتسجيل الدخول.
        </p>
      </div>
      <ModerationManager users={(data ?? []) as ModerationUserRow[]} />
    </div>
  );
}
