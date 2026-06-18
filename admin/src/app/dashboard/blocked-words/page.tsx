import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { BlockedWordsManager } from "./blocked-words-manager";

export const dynamic = "force-dynamic";

export default async function BlockedWordsPage() {
  await requireAdmin();
  const supabase = createAdminClient();
  const { data, error } = await supabase
    .from("blocked_words")
    .select("id, word, normalized_form, severity, active, created_at")
    .order("created_at", { ascending: false });

  if (error) {
    return (
      <p className="text-destructive">فشل تحميل القائمة: {error.message}</p>
    );
  }

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-bold">كلمات محظورة</h1>
        <p className="text-sm text-muted-foreground">
          إدارة فلتر المحتوى — التغييرات تُطبَّق فوراً دون إعادة بناء التطبيق.
        </p>
      </div>
      <BlockedWordsManager words={data ?? []} />
    </div>
  );
}
