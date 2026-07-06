import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { markSupportThreadRead } from "@/app/actions/support";
import type { SupportMessageRow } from "@/lib/types/database.types";
import { formatDateTime } from "@/lib/utils/format-date";
import { cn } from "@/lib/utils/cn";
import { SupportReplyForm } from "./reply-form";

export const dynamic = "force-dynamic";

export default async function SupportThreadPage({
  params,
}: {
  params: { user_id: string };
}) {
  await requireAdmin();
  const supabase = createAdminClient();

  const [{ data: profile }, { data: messagesData }] = await Promise.all([
    supabase
      .from("profiles")
      .select("id, display_name, full_name, phone")
      .eq("id", params.user_id)
      .maybeSingle(),
    supabase
      .from("support_messages")
      .select("*")
      .eq("user_id", params.user_id)
      .order("created_at", { ascending: true }),
  ]);

  if (!profile) notFound();
  const messages = (messagesData ?? []) as SupportMessageRow[];
  const userName = profile.full_name || profile.display_name || "مستخدم";

  // Mark unread user messages as seen just by opening the thread.
  const markReadForm = new FormData();
  markReadForm.set("userId", params.user_id);
  await markSupportThreadRead(markReadForm);

  return (
    <div className="space-y-4">
      <Button asChild variant="ghost" size="sm">
        <Link href="/dashboard/support-messages">
          <ArrowRight className="size-4" /> العودة إلى رسائل الدعم
        </Link>
      </Button>

      <Card>
        <CardHeader>
          <CardTitle>{userName}</CardTitle>
          {profile.phone && (
            <p dir="ltr" className="text-sm text-muted-foreground">
              {profile.phone}
            </p>
          )}
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="max-h-[60vh] space-y-3 overflow-y-auto rounded-lg border border-border p-4">
            {messages.length === 0 && (
              <p className="text-sm text-muted-foreground">لا توجد رسائل بعد</p>
            )}
            {messages.map((m) => (
              <div
                key={m.id}
                className={cn(
                  "flex",
                  m.sender_role === "admin" ? "justify-start" : "justify-end",
                )}
              >
                <div
                  className={cn(
                    "max-w-[75%] rounded-2xl px-4 py-2 text-sm",
                    m.sender_role === "admin"
                      ? "bg-primary text-primary-foreground"
                      : "bg-muted text-foreground",
                  )}
                >
                  <p className="whitespace-pre-wrap">{m.body}</p>
                  <p
                    className={cn(
                      "mt-1 text-[10px] opacity-70",
                      m.sender_role === "admin" ? "text-primary-foreground" : "text-muted-foreground",
                    )}
                  >
                    {formatDateTime(m.created_at)}
                  </p>
                </div>
              </div>
            ))}
          </div>

          <SupportReplyForm userId={params.user_id} />
        </CardContent>
      </Card>
    </div>
  );
}
