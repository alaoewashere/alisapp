import { cookies } from "next/headers";
import { createServerClient, type CookieOptions } from "@supabase/ssr";

import type { Database } from "@/lib/types/database.types";

type CookieToSet = { name: string; value: string; options?: CookieOptions };

/**
 * Server Supabase client bound to the request cookies (anon key). Represents
 * the logged-in admin's session. Use for auth/session checks in Server
 * Components, Route Handlers and Server Actions.
 */
export function createClient() {
  const cookieStore = cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: CookieToSet[]) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Called from a Server Component — cookie writes are handled by
            // middleware on the next request. Safe to ignore here.
          }
        },
      },
    },
  );
}
