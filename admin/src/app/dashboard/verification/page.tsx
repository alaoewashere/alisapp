import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import {
  VerificationQueueTable,
  type VerificationQueueRow,
} from "@/components/tables/verification-table";
import { signedVerificationDocUrl } from "@/app/actions/verification";
import { formatDateTime } from "@/lib/utils/format-date";

const DOC_LABELS: Record<string, string> = {
  national_id: "الهوية الوطنية",
  drivers_license: "رخصة القيادة",
  passport: "جواز السفر",
};

export default async function VerificationPage() {
  await requireAdmin();
  const supabase = createAdminClient();

  const { data: requests, error } = await supabase
    .from("verification_requests")
    .select(
      `
      id,
      user_id,
      document_type,
      front_image_url,
      back_image_url,
      submitted_at,
      profiles!verification_requests_user_id_fkey(full_name, display_name)
    `,
    )
    .eq("status", "pending")
    .order("submitted_at", { ascending: true });

  if (error) {
    return (
      <div className="p-6 text-red-600">
        تعذّر تحميل طلبات التوثيق: {error.message}
      </div>
    );
  }

  const rows: VerificationQueueRow[] = await Promise.all(
    (requests ?? []).map(async (row) => {
      const profile = row.profiles as
        | { full_name: string | null; display_name: string }
        | null;
      const userName =
        profile?.full_name?.trim() ||
        profile?.display_name?.trim() ||
        "مستخدم";
      const frontPath = row.front_image_url as string;
      const backPath = row.back_image_url as string | null;
      const frontThumbUrl = await signedVerificationDocUrl(frontPath);
      const backThumbUrl = backPath
        ? await signedVerificationDocUrl(backPath)
        : null;

      return {
        id: row.id as string,
        userId: row.user_id as string,
        userName,
        documentType: row.document_type as string,
        documentLabel:
          DOC_LABELS[row.document_type as string] ?? row.document_type,
        submittedAtLabel: formatDateTime(row.submitted_at as string),
        frontThumbUrl,
        backThumbUrl,
      };
    }),
  );

  return (
    <div className="space-y-6 p-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">التوثيق</h1>
        <p className="text-sm text-muted-foreground">
          مراجعة طلبات توثيق البائعين ({rows.length} قيد الانتظار)
        </p>
      </div>
      <VerificationQueueTable rows={rows} />
    </div>
  );
}
