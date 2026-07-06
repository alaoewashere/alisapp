import Link from "next/link";
import { MessageCircle } from "lucide-react";

import { Card, CardContent } from "@/components/ui/card";
import { requireAdmin } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { SUPPORT_MESSAGE_SELECT } from "@/lib/data/selects";
import type { SupportMessageWithUser } from "@/lib/data/types";
import { formatDateTime } from "@/lib/utils/format-date";

export const dynamic = "force-dynamic";

interface ThreadSummary {
  userId: string;
  userName: string;
  userPhone: string | null;
  lastMessage: string;
  lastMessageAt: string;
  unreadCount: number;
}

export default async function SupportMessagesPage() {
  await requireAdmin();
  const supabase = createAdminClient();

  // Support message volume is low — fetch everything and group by user here
  // rather than adding a dedicated "threads" table for now.
  const { data } = await supabase
    .from("support_messages")
    .select(SUPPORT_MESSAGE_SELECT)
    .order("created_at", { ascending: false });

  const messages = (data ?? []) as unknown as SupportMessageWithUser[];

  const threads = new Map<string, ThreadSummary>();
  for (const m of messages) {
    const existing = threads.get(m.user_id);
    if (!existing) {
      threads.set(m.user_id, {
        userId: m.user_id,
        userName: m.user?.full_name || m.user?.display_name || "مستخدم",
        userPhone: m.user?.phone ?? null,
        lastMessage: m.body,
        lastMessageAt: m.created_at,
        unreadCount: m.sender_role === "user" && !m.is_read ? 1 : 0,
      });
    } else if (m.sender_role === "user" && !m.is_read) {
      existing.unreadCount += 1;
    }
  }

  const sortedThreads = [...threads.values()].sort(
    (a, b) => new Date(b.lastMessageAt).getTime() - new Date(a.lastMessageAt).getTime(),
  );

  return (
    <div className="space-y-4">
      <Card>
        <CardContent className="p-0">
          {sortedThreads.length === 0 ? (
            <p className="p-6 text-sm text-muted-foreground">لا توجد رسائل دعم بعد</p>
          ) : (
            <div className="divide-y divide-border">
              {sortedThreads.map((thread) => (
                <Link
                  key={thread.userId}
                  href={`/dashboard/support-messages/${thread.userId}`}
                  className="flex items-center justify-between gap-3 p-4 hover:bg-muted/50"
                >
                  <div className="flex items-center gap-3">
                    <div className="flex size-10 items-center justify-center rounded-full bg-muted">
                      <MessageCircle className="size-5 text-muted-foreground" />
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{thread.userName}</p>
                      <p className="line-clamp-1 max-w-md text-sm text-muted-foreground">
                        {thread.lastMessage}
                      </p>
                    </div>
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <span className="text-xs text-muted-foreground">
                      {formatDateTime(thread.lastMessageAt)}
                    </span>
                    {thread.unreadCount > 0 && (
                      <span className="flex h-5 min-w-5 items-center justify-center rounded-full bg-destructive px-1.5 text-xs font-bold text-white">
                        {thread.unreadCount}
                      </span>
                    )}
                  </div>
                </Link>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
