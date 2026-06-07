"use client";

import * as React from "react";
import { Loader2, ShieldCheck, Trash2, UserPlus } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { ActionDialog } from "@/components/ui/action-dialog";
import { addAdmin, removeAdmin } from "@/app/actions/settings";
import type { AdminUserRow } from "@/lib/types/database.types";

interface AdminManagementProps {
  admins: AdminUserRow[];
  currentUserId: string;
}

export function AdminManagement({ admins, currentUserId }: AdminManagementProps) {
  const [email, setEmail] = React.useState("");
  const [role, setRole] = React.useState("admin");
  const [error, setError] = React.useState<string | null>(null);
  const [pending, start] = React.useTransition();

  function onAdd(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    start(async () => {
      const fd = new FormData();
      fd.set("email", email);
      fd.set("role", role);
      const res = await addAdmin(fd);
      if (res && res.ok === false) setError(res.error);
      else setEmail("");
    });
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>إدارة المشرفين</CardTitle>
        <p className="text-sm text-muted-foreground">للمدير الأعلى فقط — أنشئ حساب المستخدم في Supabase أولاً.</p>
      </CardHeader>
      <CardContent className="space-y-4">
        <form onSubmit={onAdd} className="flex flex-wrap items-end gap-2">
          <div className="flex-1 space-y-1.5">
            <label className="text-sm font-medium">البريد الإلكتروني</label>
            <Input
              type="email"
              dir="ltr"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@souqiq.com"
              required
            />
          </div>
          <Select value={role} onChange={(e) => setRole(e.target.value)} className="w-40">
            <option value="admin">مدير</option>
            <option value="super_admin">مدير أعلى</option>
          </Select>
          <Button type="submit" disabled={pending}>
            {pending ? <Loader2 className="size-4 animate-spin" /> : <UserPlus className="size-4" />}
            إضافة
          </Button>
        </form>
        {error && <p className="text-sm text-destructive">{error}</p>}

        <div className="divide-y divide-border rounded-lg border border-border">
          {admins.map((admin) => (
            <div key={admin.id} className="flex items-center justify-between gap-2 p-3">
              <div className="flex items-center gap-2">
                <ShieldCheck className="size-4 text-primary" />
                <span dir="ltr" className="text-sm font-medium">{admin.email}</span>
                <Badge variant={admin.role === "super_admin" ? "default" : "secondary"}>
                  {admin.role === "super_admin" ? "مدير أعلى" : "مدير"}
                </Badge>
              </div>
              {admin.id !== currentUserId && (
                <ActionDialog
                  action={removeAdmin}
                  title="إزالة المشرف"
                  description={`إزالة صلاحيات الإدارة عن ${admin.email}؟`}
                  confirmLabel="إزالة"
                  confirmVariant="destructive"
                  triggerLabel={<Trash2 className="size-4" />}
                  triggerVariant="ghost"
                  triggerSize="icon"
                  triggerClassName="size-8 text-destructive"
                  hidden={{ id: admin.id }}
                />
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
