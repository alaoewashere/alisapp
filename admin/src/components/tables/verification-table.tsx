"use client";

import { useState } from "react";
import Image from "next/image";
import { Check } from "lucide-react";

import {
  approveVerificationRequest,
  rejectVerificationRequest,
} from "@/app/actions/verification";
import { ActionDialog } from "@/components/ui/action-dialog";
import { Modal } from "@/components/ui/modal";
import { SubmitButton } from "@/components/ui/submit-button";

export type VerificationQueueRow = {
  id: string;
  userId: string;
  userName: string;
  documentType: string;
  documentLabel: string;
  submittedAtLabel: string;
  frontThumbUrl: string | null;
  backThumbUrl: string | null;
};

function DocumentThumbnail({
  url,
  label,
  onOpen,
}: {
  url: string;
  label: string;
  onOpen: (url: string, label: string) => void;
}) {
  return (
    <button
      type="button"
      onClick={() => onOpen(url, label)}
      className="overflow-hidden rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
      title={label}
    >
      <Image
        src={url}
        alt={label}
        width={48}
        height={48}
        className="size-12 rounded-lg object-cover"
        unoptimized
      />
    </button>
  );
}

export function VerificationQueueTable({ rows }: { rows: VerificationQueueRow[] }) {
  const [preview, setPreview] = useState<{ url: string; label: string } | null>(
    null,
  );

  if (rows.length === 0) {
    return (
      <p className="rounded-lg border border-border bg-card p-8 text-center text-muted-foreground">
        لا توجد طلبات توثيق قيد المراجعة
      </p>
    );
  }

  return (
    <>
      <div className="overflow-hidden rounded-lg border border-border bg-card">
        <table className="w-full text-sm">
          <thead className="border-b border-border bg-muted/40 text-muted-foreground">
            <tr>
              <th className="px-4 py-3 text-right font-medium">المستخدم</th>
              <th className="px-4 py-3 text-right font-medium">نوع الوثيقة</th>
              <th className="px-4 py-3 text-right font-medium">تاريخ الإرسال</th>
              <th className="px-4 py-3 text-right font-medium">الوثائق</th>
              <th className="px-4 py-3 text-right font-medium">إجراء</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-b border-border last:border-0">
                <td className="px-4 py-3 font-medium text-foreground">{row.userName}</td>
                <td className="px-4 py-3 text-muted-foreground">{row.documentLabel}</td>
                <td className="px-4 py-3 text-muted-foreground" dir="ltr">
                  {row.submittedAtLabel}
                </td>
                <td className="px-4 py-3">
                  {row.frontThumbUrl || row.backThumbUrl ? (
                    <div className="flex items-center gap-2">
                      {row.frontThumbUrl && (
                        <DocumentThumbnail
                          url={row.frontThumbUrl}
                          label="الوجه الأمامي"
                          onOpen={(url, label) => setPreview({ url, label })}
                        />
                      )}
                      {row.backThumbUrl && (
                        <DocumentThumbnail
                          url={row.backThumbUrl}
                          label="الوجه الخلفي"
                          onOpen={(url, label) => setPreview({ url, label })}
                        />
                      )}
                    </div>
                  ) : (
                    <span className="text-muted-foreground">—</span>
                  )}
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-wrap gap-2">
                    <form action={approveVerificationRequest}>
                      <input type="hidden" name="requestId" value={row.id} />
                      <input type="hidden" name="userId" value={row.userId} />
                      <SubmitButton
                        size="sm"
                        className="bg-emerald-600 hover:bg-emerald-700"
                      >
                        <Check className="size-4" />
                        قبول
                      </SubmitButton>
                    </form>
                    <ActionDialog
                      action={rejectVerificationRequest}
                      title="رفض طلب التوثيق"
                      description="اكتب سبب الرفض — سيظهر للمستخدم."
                      confirmLabel="رفض الطلب"
                      confirmVariant="destructive"
                      triggerLabel="رفض"
                      triggerVariant="destructive"
                      triggerSize="sm"
                      hidden={{
                        requestId: row.id,
                        userId: row.userId,
                      }}
                      fields={[
                        {
                          name: "reason",
                          label: "سبب الرفض",
                          type: "textarea",
                          required: true,
                          placeholder: "سبب الرفض...",
                        },
                      ]}
                    />
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal
        open={preview !== null}
        onClose={() => setPreview(null)}
        title={preview?.label}
        className="max-w-4xl"
      >
        {preview && (
          <div className="flex justify-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={preview.url}
              alt={preview.label}
              className="max-h-[80vh] w-full rounded-lg object-contain"
            />
          </div>
        )}
      </Modal>
    </>
  );
}
