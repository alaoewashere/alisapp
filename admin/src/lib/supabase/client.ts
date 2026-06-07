import { createBrowserClient } from "@supabase/ssr";

import type { Database } from "@/lib/types/database.types";

/**
 * Browser Supabase client (anon key only). Used by client components for the
 * authenticated admin's own session — e.g. login. Never holds the service key.
 */
export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
