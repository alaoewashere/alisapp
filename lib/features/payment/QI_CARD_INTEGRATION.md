# Qi Card payment gateway — integration plan

Status: **NOT built.** Blocked on a Qi merchant account (no public sandbox/docs).
This file is the playbook to execute the moment credentials exist.

The ZainCash integration in this folder is the reference architecture — Qi Card
follows the **same secure pattern**, just a different provider adapter.

---

## 1. The blocker (read first)

- Qi Card's "accept payments from anywhere in the world" = **customers** can pay
  from any country. It does **NOT** mean the merchant can register from anywhere.
- Merchant onboarding requires an **Iraqi business entity** + Iraqi settlement
  account. Same wall as ZainCash. No remote, no-entity signup.
- API reference + sandbox credentials are gated behind the developer portal and
  only issued **after** the merchant contract. There is no public test sandbox,
  which is why this can't be built/verified in advance (ZainCash had public test
  creds; Qi does not).

## 2. Accounts / resources to obtain

| What | Where |
|------|-------|
| Merchant gateway account | https://qi.iq/en/merchants/online-payment-gateway |
| Developer portal (docs + keys) | https://developers-gate.qi.iq/  /  https://docs.pay.qi.iq/ |
| Want: terminal/merchant id, API key/secret, sandbox base URL, webhook secret | from onboarding |

NOT needed: Jeni / Miswak — those are Qi's hosted-storefront + delivery products,
irrelevant to this app. We only want the **API payment gateway**.

## 3. Flow (what to build)

Qi enforces **3D Secure** on every card payment, so it's a redirect/WebView flow —
identical shape to the ZainCash WebView we already have.

```
App ── "pay amount X for order Y" ──▶ Supabase Edge Fn `qicard-init`
                                       • auth user
                                       • call Qi create-payment (server-side, key in env)
                                       • store order: pending  (reuse zaincash_orders or a card_orders table)
App ◀── checkout/redirect URL ─────────┘
App ── open checkout URL in WebView ──▶ customer enters card + passes 3DS on Qi's page
Qi  ── webhook ──▶ Supabase Edge Fn `qicard-callback`
                   • verify signature/secret
                   • mark order paid/failed
App ── re-read order status from DB (source of truth) ──▶ show result
```

Key rules (same as ZainCash):
- **Secret/API key lives ONLY server-side** (edge function env), never in the app.
- The app NEVER decides "paid" — it reads the DB status the webhook wrote.
- `qicard-callback` is **public** (`verify_jwt = false`) — Qi calls it, not a user.
- Prefer Qi's official **Flutter SDK** if it cleanly handles 3DS; otherwise the
  server-redirect + WebView flow above.

## 4. Concrete build steps (≈1–2h with credentials)

1. Get sandbox creds + the real API reference from the Qi portal.
2. `supabase/functions/_shared/qicard.ts` — config from env + sign/verify + the
   create-payment and verify-status calls (mirror `_shared/zaincash.ts`).
3. `supabase/functions/qicard-init/index.ts` (auth) and
   `qicard-callback/index.ts` (public) — mirror the two zaincash functions.
4. Register both in `supabase/config.toml` (`qicard-init` verify_jwt=true,
   `qicard-callback` verify_jwt=false).
5. Orders: reuse `public.zaincash_orders` with a `provider` column, OR add a
   parallel `card_orders` table. Decide based on Qi's id/field shape.
6. App: a `QiCardService` (calls `qicard-init`, reads status) + reuse the WebView
   checkout screen pattern. Set env `*_RETURN_URL` so the WebView can intercept.
7. In `settings_screen.dart`, flip the **بطاقة كي (Qi Card)** `_PaymentMethodTile`
   from `enabled: false` to active and point `onTap` at the Qi checkout.
8. Set server secrets: `supabase secrets set QICARD_API_KEY=... QICARD_MERCHANT_ID=... QICARD_IS_TEST=false ...`
9. Test the full 3DS flow against sandbox before going live.

## 5. Settlement reminder

Money from Qi settles into the **Iraqi bank account** on the merchant profile, in
IQD. Getting it to an owner abroad is a separate remittance step — the gateway
does not pay out to foreign accounts.
