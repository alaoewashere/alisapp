"use client";

import * as React from "react";
import { Ban, Loader2, ShieldOff } from "lucide-react";

import { banUserPosting, unbanUserPosting } from "@/app/actions/moderation";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Modal } from "@/components/ui/modal";
import {
  formatBaghdadDateTime,
  isPostingBanActive,
} from "@/lib/utils/format-datetime";

export interface ModerationUserRow {
  id: string;
  full_name: string | null;
  display_name: string;
  phone: string | null;
  moderation_violation_count: number;
  ban_count: number;
  is_banned: boolean;
  banned_until: string | null;
  ban_reason: string | null;
  last_moderation_violation_at: string | null;
}

function banStatusLabel(row: ModerationUserRow): string {
  if (!isPostingBanActive(row.is_banned, row.banned_until)) return "غير محظور";
  if (row.banned_until === null) return "محظور دائم";
  return `محظور حتى ${formatBaghdadDateTime(row.banned_until)}`;
}

function formatDate(value: string | null): string {
  return formatBaghdadDateTime(value);
}

export function ModerationManager({ users }: { users: ModerationUserRow[] }) {
  const [pending, start] = React.useTransition();
  const [error, setError] = React.useState<string | null>(null);
  const [banTarget, setBanTarget] = React.useState<ModerationUserRow | null>(
    null,
  );
  const [duration, setDuration] = React.useState<
    "1d" | "7d" | "30d" | "custom" | "permanent"
  >("7d");
  const [customDays, setCustomDays] = React.useState("3");

  function run(action: () => Promise<{ ok: boolean; error?: string }>) {
    setError(null);
    start(async () => {
      const result = await action();
      if (!result.ok) setError(result.error ?? "حدث خطأ");
    });
  }

  function submitBan() {
    if (!banTarget) return;
    const fd = new FormData();
    fd.set("userId", banTarget.id);
    fd.set("duration", duration);
    if (duration === "custom") fd.set("customDays", customDays);
    run(async () => {
      const result = await banUserPosting(fd);
      if (result.ok) setBanTarget(null);
      return result;
    });
  }

  function submitUnban(userId: string) {
    const fd = new FormData();
    fd.set("userId", userId);
    run(() => unbanUserPosting(fd));
  }

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="text-base">
            المخالفون ({users.length})
          </CardTitle>
        </CardHeader>
        <CardContent className="overflow-x-auto p-0">
          <table className="w-full min-w-[720px] text-sm">
            <thead>
              <tr className="border-b border-border text-muted-foreground">
                <th className="px-4 py-3 text-right font-medium">المستخدم</th>
                <th className="px-4 py-3 text-right font-medium">المخالفات</th>
                <th className="px-4 py-3 text-right font-medium">مرات الحظر</th>
                <th className="px-4 py-3 text-right font-medium">الحالة</th>
                <th className="px-4 py-3 text-right font-medium">آخر مخالفة</th>
                <th className="px-4 py-3 text-right font-medium">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {users.length === 0 ? (
                <tr>
                  <td
                    colSpan={6}
                    className="px-4 py-8 text-center text-muted-foreground"
                  >
                    لا يوجد مخالفون حالياً
                  </td>
                </tr>
              ) : (
                users.map((row) => {
                  const active = isPostingBanActive(
                    row.is_banned,
                    row.banned_until,
                  );
                  const name =
                    row.full_name?.trim() || row.display_name?.trim() || "—";
                  return (
                    <tr key={row.id} className="border-b border-border/60">
                      <td className="px-4 py-3">
                        <div className="font-medium">{name}</div>
                        <div className="text-xs text-muted-foreground" dir="ltr">
                          {row.phone ?? "—"}
                        </div>
                      </td>
                      <td className="px-4 py-3">{row.moderation_violation_count}</td>
                      <td className="px-4 py-3">{row.ban_count}</td>
                      <td className="px-4 py-3">
                        <Badge variant={active ? "destructive" : "secondary"}>
                          {banStatusLabel(row)}
                        </Badge>
                        {row.ban_reason && (
                          <div className="mt-1 text-xs text-muted-foreground">
                            {row.ban_reason}
                          </div>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        {formatDate(row.last_moderation_violation_at)}
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex flex-wrap gap-2">
                          <Button
                            size="sm"
                            variant="outline"
                            disabled={pending}
                            onClick={() => {
                              setBanTarget(row);
                              setDuration("7d");
                              setError(null);
                            }}
                          >
                            <Ban className="size-4" />
                            حظر
                          </Button>
                          {active && (
                            <Button
                              size="sm"
                              variant="secondary"
                              disabled={pending}
                              onClick={() => submitUnban(row.id)}
                            >
                              {pending ? (
                                <Loader2 className="size-4 animate-spin" />
                              ) : (
                                <ShieldOff className="size-4" />
                              )}
                              إلغاء الحظر
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </CardContent>
      </Card>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Modal
        open={banTarget != null}
        onClose={() => setBanTarget(null)}
        title="حظر المستخدم"
        description={`${banTarget?.full_name ?? banTarget?.display_name ?? ""} — اختر مدة الحظر من الدردشة والنشر`}
      >
        <div className="space-y-4">
          <div className="flex flex-wrap gap-2">
            {(
              [
                ["1d", "يوم واحد"],
                ["7d", "7 أيام"],
                ["30d", "30 يوماً"],
                ["custom", "مخصص"],
                ["permanent", "حظر دائم"],
              ] as const
            ).map(([value, label]) => (
              <Button
                key={value}
                type="button"
                size="sm"
                variant={duration === value ? "default" : "outline"}
                onClick={() => setDuration(value)}
              >
                {label}
              </Button>
            ))}
          </div>
          {duration === "custom" && (
            <Input
              type="number"
              min={1}
              value={customDays}
              onChange={(e) => setCustomDays(e.target.value)}
              placeholder="عدد الأيام"
              dir="ltr"
            />
          )}
          <div className="flex justify-start gap-2">
            <Button onClick={submitBan} disabled={pending}>
              {pending ? <Loader2 className="size-4 animate-spin" /> : null}
              تأكيد الحظر
            </Button>
            <Button variant="outline" onClick={() => setBanTarget(null)}>
              إلغاء
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
