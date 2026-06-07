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
