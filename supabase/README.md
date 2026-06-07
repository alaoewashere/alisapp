# Supabase Setup — سوق العراق (Souq IQ)

## 1. Create Project

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard) → **New Project**
2. Choose region closest to Iraq (e.g. `eu-central-1`)
3. Save your **Project URL** and **anon public key**

## 2. Run Migration

**Option A — SQL Editor:** Run each file in `migrations/` in order (000000 → 000005).

**Option B — Supabase CLI:**
```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

## 3. Storage Bucket

Already created by migration `20260530000001_storage.sql` when you run `supabase db push`.

If setting up manually: **Storage** → **New bucket** → Name `listing-images`, Public **Yes**, then run `20260530000001_storage.sql`.

**Option A — SQL Editor:** Run each file in `migrations/` in order (000000 → 000004).

## 4. Enable Phone OTP Auth

1. **Authentication** → **Providers** → **Phone** → Enable
2. **Configure an SMS provider** (required — without this, OTP requests succeed but no SMS is sent):
   - **Twilio** (recommended): Account SID, Auth Token, Message Service SID (`MG...`)
   - Or **MessageBird**, **Vonage**, **TextLocal**
   - Twilio must support sending to Iraq (+964)
3. **Twilio sender pool** (fixes *"Messaging Service contains no phone numbers"*):
   1. [Twilio Console](https://console.twilio.com/) → **Messaging** → **Services** → your service (e.g. `souqiq-otp`)
   2. Open the **Sender Pool** tab → **Add Senders** → select your Twilio phone number → **Add**
   3. Save, then in **Supabase** → **Authentication** → **Providers** → **Phone** confirm:
      - Provider = **Twilio**
      - Message Service SID starts with `MG...`
      - The number shows as active in Twilio
4. **For development without real SMS** — add a **Test phone number** in the Phone provider settings:
   - Format: your full E.164 number → fixed 6-digit OTP (e.g. `+9647901234567` → `123456`)
   - Use that OTP in the app; no SMS is sent for test numbers
5. Iraqi numbers use E.164: `+9647XXXXXXXXX` (local part: `7901234567`, no leading `0`)
6. Check **Authentication** → **Logs** if SMS fails (500 errors usually mean bad provider credentials)
7. Run migration `20260530000004_avatars_storage.sql` for profile photo uploads

## 5. Extended Schema

Run migration `20260530000003_schema_extensions.sql` for:
- `governorates`, `reports`, `boosts` tables
- Extended columns on existing tables (avatar, geo, boosts, bilingual fields)
- Additional indexes + Realtime on `conversations`

## 6. Admin Moderation

Admins approve listings in **Table Editor** → `listings`:
- Set `status` = `approved` or `rejected`
- Optionally set `rejection_reason` and `reviewed_at` = `now()`

## 7. Run the App

**Option A — `.env` file (recommended for local dev):**

Copy `.env.example` to `.env` and paste your keys from **Project Settings → API**:

```
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Then run:

```bash
flutter run
```

**Option B — dart-define (CI / release builds):**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

> `.env` is gitignored. Never commit real keys.
