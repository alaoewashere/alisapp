"use client";

import { BadgeCheck, Ban, RotateCcw, Trash2 } from "lucide-react";

import { ActionDialog } from "@/components/ui/action-dialog";
import {
  deleteUser,
  setUserVerified,
  suspendUser,
  unsuspendUser,
} from "@/app/actions/users";

export function VerifyButton({ id, verified }: { id: string; verified: boolean }) {
  return (
    <ActionDialog
      action={setUserVerified}
      title={verified ? "إلغاء التوثيق" : "توثيق الحساب"}
      description={verified ? "سيتم إزالة شارة التوثيق." : "سيتم منح المستخدم شارة موثّق."}
      confirmLabel={verified ? "إلغاء التوثيق" : "توثيق"}
      triggerLabel={
        <>
          <BadgeCheck className="size-4" /> {verified ? "إلغاء التوثيق" : "توثيق"}
        </>
      }
      triggerVariant="outline"
      triggerSize="sm"
      hidden={{ id, value: String(!verified) }}
    />
  );
}

export function SuspendUserButton({ id }: { id: string }) {
  return (
    <ActionDialog
      action={suspendUser}
      title="تعليق الحساب"
      description="لن يتمكن المستخدم من استخدام التطبيق."
      confirmLabel="تعليق"
      confirmVariant="destructive"
      triggerLabel={
        <>
          <Ban className="size-4" /> تعليق
        </>
      }
      triggerVariant="outline"
      triggerSize="sm"
      hidden={{ id }}
      fields={[{ name: "reason", label: "سبب التعليق", type: "textarea", required: true }]}
    />
  );
}

export function UnsuspendUserButton({ id }: { id: string }) {
  return (
    <ActionDialog
      action={unsuspendUser}
      title="رفع التعليق"
      description="سيعود المستخدم لاستخدام التطبيق."
      confirmLabel="رفع التعليق"
      triggerLabel={
        <>
          <RotateCcw className="size-4" /> رفع التعليق
        </>
      }
      triggerVariant="outline"
      triggerSize="sm"
      hidden={{ id }}
    />
  );
}

export function DeleteUserButton({ id }: { id: string }) {
  return (
    <ActionDialog
      action={deleteUser}
      title="حذف الحساب"
      description="سيتم حذف الحساب (حذف ناعم) وإخفاؤه من التطبيق."
      confirmLabel="حذف الحساب"
      confirmVariant="destructive"
      triggerLabel={
        <>
          <Trash2 className="size-4" /> حذف
        </>
      }
      triggerVariant="destructive"
      triggerSize="sm"
      hidden={{ id }}
    />
  );
}
