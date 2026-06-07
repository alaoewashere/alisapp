"use client";

import { Ban, Check, Trash2, X } from "lucide-react";

import { ActionDialog } from "@/components/ui/action-dialog";
import {
  deleteListingFromReport,
  dismissReport,
  resolveReport,
  suspendSellerFromReport,
} from "@/app/actions/reports";
import { warnSeller } from "@/app/actions/listings";

export function ResolveReportButton({ reportId }: { reportId: string }) {
  return (
    <ActionDialog
      action={resolveReport}
      title="حل البلاغ"
      description="سيتم وضع علامة على البلاغ كمحلول."
      confirmLabel="تأكيد الحل"
      triggerLabel={
        <>
          <Check className="size-4" /> حل
        </>
      }
      triggerVariant="outline"
      triggerSize="sm"
      hidden={{ id: reportId }}
    />
  );
}

export function DismissReportButton({ reportId }: { reportId: string }) {
  return (
    <ActionDialog
      action={dismissReport}
      title="تجاهل البلاغ"
      description="سيتم تجاهل هذا البلاغ دون اتخاذ إجراء."
      confirmLabel="تجاهل"
      triggerLabel={
        <>
          <X className="size-4" /> تجاهل
        </>
      }
      triggerVariant="ghost"
      triggerSize="sm"
      hidden={{ id: reportId }}
    />
  );
}

export function DeleteListingFromReportButton({
  reportId,
  listingId,
}: {
  reportId: string;
  listingId: string;
}) {
  return (
    <ActionDialog
      action={deleteListingFromReport}
      title="حذف الإعلان"
      description="سيتم حذف الإعلان وحل البلاغ. يمكن استعادة الإعلان لاحقًا."
      confirmLabel="حذف الإعلان"
      confirmVariant="destructive"
      triggerLabel={
        <>
          <Trash2 className="size-4" /> حذف الإعلان
        </>
      }
      triggerVariant="destructive"
      triggerSize="sm"
      hidden={{ id: reportId, listingId }}
    />
  );
}

export function WarnSellerButton({
  listingId,
  sellerId,
}: {
  listingId: string;
  sellerId: string;
}) {
  return (
    <ActionDialog
      action={warnSeller}
      title="تحذير البائع"
      description="سيتم إرسال إشعار تحذير إلى البائع."
      confirmLabel="إرسال التحذير"
      triggerLabel="تحذير البائع"
      triggerVariant="outline"
      triggerSize="sm"
      hidden={{ listingId, sellerId }}
      fields={[
        {
          name: "reason",
          label: "سبب التحذير",
          type: "textarea",
          placeholder: "اكتب رسالة التحذير...",
          required: true,
        },
      ]}
    />
  );
}

export function SuspendSellerFromReportButton({
  reportId,
  sellerId,
}: {
  reportId: string;
  sellerId: string;
}) {
  return (
    <ActionDialog
      action={suspendSellerFromReport}
      title="تعليق حساب البائع"
      description="سيتم تعليق حساب البائع وحل البلاغ."
      confirmLabel="تعليق الحساب"
      confirmVariant="destructive"
      triggerLabel={
        <>
          <Ban className="size-4" /> تعليق الحساب
        </>
      }
      triggerVariant="destructive"
      triggerSize="sm"
      hidden={{ id: reportId, sellerId }}
      fields={[
        {
          name: "reason",
          label: "سبب التعليق",
          type: "textarea",
          placeholder: "سبب تعليق الحساب...",
        },
      ]}
    />
  );
}
