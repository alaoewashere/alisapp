import "server-only";

import { createAdminClient } from "@/lib/supabase/admin";

/** Count of reports still awaiting moderation — drives the sidebar badge. */
export async function getPendingReportsCount(): Promise<number> {
  const supabase = createAdminClient();
  const { count } = await supabase
    .from("reports")
    .select("id", { count: "exact", head: true })
    .eq("status", "pending");
  return count ?? 0;
}

/** Count of unread user support messages — drives the sidebar badge. */
export async function getUnreadSupportMessagesCount(): Promise<number> {
  const supabase = createAdminClient();
  const { count } = await supabase
    .from("support_messages")
    .select("id", { count: "exact", head: true })
    .eq("sender_role", "user")
    .eq("is_read", false);
  return count ?? 0;
}
