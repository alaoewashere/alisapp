import "server-only";

import { createClient as createSupabaseClient } from "@supabase/supabase-js";

import type { Database } from "@/lib/types/database.types";

/**
 * Service-role Supabase client. Bypasses RLS — use ONLY in Server Components,
 * Route Handlers and Server Actions for admin reads/writes. The `server-only`
 * import guarantees this module can never be bundled into client code.
 */
export function createAdminClient() {
  return createSupabaseClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: { autoRefreshToken: false, persistSession: false },
    },
  );
}
