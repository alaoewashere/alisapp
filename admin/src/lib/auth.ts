import "server-only";

import { redirect } from "next/navigation";

import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { AdminUserRow } from "@/lib/types/database.types";

export interface AdminSession {
  userId: string;
  email: string;
  admin: AdminUserRow;
}

/**
 * Resolves the current admin from the session cookie. Returns null when there
 * is no session or the user is not in admin_users.
 */
export async function getAdminSession(): Promise<AdminSession | null> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data } = await supabase
    .from("admin_users")
    .select("*")
    .eq("id", user.id)
    .maybeSingle();

  const admin = data as AdminUserRow | null;
  if (!admin) return null;

  return { userId: user.id, email: user.email ?? admin.email, admin };
}

/** Guards a Server Component / action; redirects to /login when not an admin. */
export async function requireAdmin(): Promise<AdminSession> {
  const session = await getAdminSession();
  if (!session) redirect("/login");
  return session;
}

/** Guards super-admin-only actions. */
export async function requireSuperAdmin(): Promise<AdminSession> {
  const session = await requireAdmin();
  if (session.admin.role !== "super_admin") {
    throw new Error("صلاحية المدير الأعلى مطلوبة");
  }
  return session;
}

/** Convenience: service-role client for the current (already-verified) admin. */
export function adminDb() {
  return createAdminClient();
}
