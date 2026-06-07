# سوق العراق — لوحة التحكم (Souq IQ Admin)

Admin dashboard for the Souq IQ marketplace. Next.js 14 (App Router) + TypeScript +
Tailwind CSS + Supabase. Connects to the **same Supabase project** as the Flutter app.

## Stack

| Layer | Tool |
|---|---|
| Framework | Next.js 14 (App Router, `src/`) |
| Language | TypeScript (strict) |
| UI | Tailwind CSS + shadcn-style components |
| Data/Auth | Supabase (`@supabase/ssr`) |
| Tables | TanStack Table v8 |
| Charts | Recharts |
| Icons | lucide-react |
| Dates | date-fns (Arabic locale) |

## Prerequisites

- Node.js 18.18+ (or 20+)
- The admin DB migration applied: `supabase/migrations/20260601000000_admin_dashboard.sql`
  (creates `admin_users`, `app_settings`, `notifications` and adds moderation columns).

## Setup

```bash
cd admin
npm install
cp .env.local.example .env.local   # fill the three values
npm run dev                          # http://localhost:3000
```

### Environment variables (`.env.local`)

| Key | Scope | Notes |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | public | Same project URL as the app |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | public | Anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | **server only** | Project Settings → API → service_role. Never prefix with `NEXT_PUBLIC`. |

The service-role key is only ever used inside Server Components / Server Actions
(`src/lib/supabase/admin.ts`, guarded with `import "server-only"`). Browser code uses
the anon key only.

## Creating the first admin

Admin accounts are **not** self-service. Create an auth user, then add them to
`admin_users`:

1. Supabase → Authentication → Add user (email + password).
2. Run in the SQL editor:

```sql
INSERT INTO public.admin_users (id, email, role)
SELECT id, email, 'super_admin' FROM auth.users WHERE email = 'you@example.com'
ON CONFLICT (id) DO UPDATE SET role = 'super_admin';
```

`super_admin` users can manage other admins from **Settings**.

## How auth works

- `src/middleware.ts` refreshes the session and guards every `/dashboard/*` route.
  Non-admins are redirected to `/login`; signed-in admins on `/login` go to `/dashboard`.
- `requireAdmin()` re-verifies on the server for each page/action.

## Structure

```
src/
├── app/
│   ├── login/                  # email/password sign-in
│   ├── dashboard/              # overview, listings, users, reports, categories, analytics, settings
│   └── actions/                # server actions (mutations) — service role
├── components/{layout,tables,charts,ui}
├── lib/{supabase,types,utils,constants,data,actions}
└── middleware.ts
```

## Deploy (Vercel)

1. Import the repo, set **Root Directory** to `admin`.
2. Add the three env vars (service role as a *secret*).
3. Deploy. `vercel.json` pins the Next.js build.
4. Point `admin.souqiq.com` at the Vercel project.

## Notes

- All admin reads/writes run server-side; tables are paginated, sortable and
  filterable via URL search params (server-side pagination, 25/page).
- Destructive actions use a confirmation dialog.
- "Delete" for listings/users is a soft delete (reversible), matching the app.
- Admin UI uses Western numerals; the rest of the UI is Arabic RTL.
