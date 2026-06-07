import { SettingsForm } from "@/app/dashboard/settings/settings-form";
import { AdminManagement } from "@/app/dashboard/settings/admin-management";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import type { AdminUserRow, AppSettingRow } from "@/lib/types/database.types";

export const dynamic = "force-dynamic";

export default async function SettingsPage() {
  const session = await requireAdmin();
  const supabase = createAdminClient();
  const isSuperAdmin = session.admin.role === "super_admin";

  const [settingsRes, adminsRes] = await Promise.all([
    supabase.from("app_settings").select("key, value"),
    isSuperAdmin
      ? supabase.from("admin_users").select("*").order("created_at")
      : Promise.resolve({ data: [] as AdminUserRow[] }),
  ]);

  const values: Record<string, string> = {};
  for (const row of (settingsRes.data ?? []) as Pick<AppSettingRow, "key" | "value">[]) {
    values[row.key] = row.value;
  }
  const admins = (adminsRes.data ?? []) as AdminUserRow[];

  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-2">
        <SettingsForm
          title="إعدادات التطبيق"
          fields={[
            { key: "app_name", label: "اسم التطبيق" },
            { key: "support_email", label: "بريد الدعم", type: "email" },
            { key: "max_images_per_listing", label: "الحد الأقصى للصور بالإعلان", type: "number" },
            { key: "max_listing_duration_days", label: "مدة الإعلان (أيام)", type: "number" },
          ]}
          values={values}
        />

        <SettingsForm
          title="الإعلانات المميزة"
          fields={[
            { key: "max_featured_listings", label: "الحد الأقصى للإعلانات المميزة", type: "number" },
            { key: "featured_listing_price_iqd", label: "سعر الإعلان المميز (د.ع)", type: "number" },
          ]}
          values={values}
        />
      </div>

      <SettingsForm
        title="قوالب الإشعارات"
        description="استخدم المتغيرات مثل {code} و {title} و {reason} داخل النص."
        fields={[
          { key: "tpl_otp", label: "رمز التحقق (OTP)", type: "textarea" },
          { key: "tpl_new_message", label: "رسالة جديدة", type: "textarea" },
          { key: "tpl_listing_approved", label: "تمت الموافقة على الإعلان", type: "textarea" },
          { key: "tpl_listing_rejected", label: "تم رفض الإعلان", type: "textarea" },
          { key: "tpl_account_warning", label: "تحذير الحساب", type: "textarea" },
        ]}
        values={values}
      />

      {isSuperAdmin && <AdminManagement admins={admins} currentUserId={session.userId} />}
    </div>
  );
}
