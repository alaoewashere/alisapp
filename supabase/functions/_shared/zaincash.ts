// Server-side ZainCash helpers. The client secret lives ONLY here (in env),
// never in the mobile app.
//
// ZainCash moved this merchant onto their Payment Gateway API v2, which is a
// different integration entirely from the classic v1 API (HMAC-signed JWT
// request, form-urlencoded body, `/transaction/init` directly on
// test.zaincash.iq): v2 uses OAuth2 client_credentials for auth and a JSON
// REST body at `/api/v2/payment-gateway/transaction/init`. Discovered via
// docs.zaincash.iq (v2 developer guide) after the v1-shaped request 404'd
// against the `pg-api.zaincash.iq` host ZainCash assigned this merchant.

export interface ZainCashConfig {
  clientId: string
  clientSecret: string
  isTest: boolean
  serviceType: string
  lang: string
  successUrl: string // ZainCash redirects here on success (our callback fn)
  failureUrl: string // ZainCash redirects here on failure (our callback fn)
  returnUrl: string // where the callback bounces the WebView so the app closes it
  baseUrlOverride?: string // set when ZainCash assigns a merchant-specific gateway host
}

export function loadZainCashConfig(): ZainCashConfig {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const callbackUrl =
    Deno.env.get('ZAINCASH_CALLBACK_URL') ??
    `${supabaseUrl}/functions/v1/zaincash-callback`
  return {
    clientId: Deno.env.get('ZAINCASH_CLIENT_ID') ?? '',
    clientSecret: Deno.env.get('ZAINCASH_CLIENT_SECRET') ?? '',
    isTest: (Deno.env.get('ZAINCASH_IS_TEST') ?? 'true') !== 'false',
    serviceType: Deno.env.get('ZAINCASH_SERVICE_TYPE') ?? 'SOUQAK',
    lang: Deno.env.get('ZAINCASH_LANG') ?? 'ar',
    // Both point at our own callback fn by default — it inspects the signed
    // JWT's own status field, so one handler covers success and failure.
    successUrl: Deno.env.get('ZAINCASH_SUCCESS_URL') ?? callbackUrl,
    failureUrl: Deno.env.get('ZAINCASH_FAILURE_URL') ?? callbackUrl,
    returnUrl:
      Deno.env.get('ZAINCASH_RETURN_URL') ??
      'https://sello.app/zaincash/return',
    baseUrlOverride: Deno.env.get('ZAINCASH_BASE_URL') || undefined,
  }
}

export function baseUrl(cfg: ZainCashConfig): string {
  if (cfg.baseUrlOverride) return cfg.baseUrlOverride
  return cfg.isTest
    ? 'https://pg-api-uat.zaincash.iq'
    : 'https://pg-api.zaincash.iq'
}

// --- base64url ------------------------------------------------------------
// Only needed to verify (not sign) the JWT ZainCash attaches to the redirect
// back to `successUrl`/`failureUrl` — v2 no longer requires us to sign a JWT
// for the init request itself (that's replaced by the OAuth2 bearer token).

function b64urlDecode(input: string): Uint8Array {
  const padded = input.replace(/-/g, '+').replace(/_/g, '/')
  const bin = atob(padded + '='.repeat((4 - (padded.length % 4)) % 4))
  const out = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i)
  return out
}

async function hmacKey(secret: string): Promise<CryptoKey> {
  return await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify'],
  )
}

// --- JWT (HS256) --------------------------------------------------------

export async function verifyJwt(
  token: string,
  secret: string,
): Promise<Record<string, unknown> | null> {
  const parts = token.split('.')
  if (parts.length !== 3) return null
  const key = await hmacKey(secret)
  const valid = await crypto.subtle.verify(
    'HMAC',
    key,
    b64urlDecode(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  )
  if (!valid) return null
  return JSON.parse(new TextDecoder().decode(b64urlDecode(parts[1])))
}

// --- gateway calls ------------------------------------------------------

interface TokenResult {
  ok: boolean
  accessToken?: string
  error?: string
}

// v2 auth: OAuth2 client_credentials grant. No caching across invocations —
// edge functions are short-lived/stateless, and token volume here is low
// enough that fetching a fresh one per checkout isn't worth the complexity.
async function getAccessToken(cfg: ZainCashConfig): Promise<TokenResult> {
  const res = await fetch(`${baseUrl(cfg)}/oauth2/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: cfg.clientId,
      client_secret: cfg.clientSecret,
    }),
  })

  const rawBody = await res.text()
  let data: Record<string, unknown> = {}
  try {
    data = JSON.parse(rawBody)
  } catch {
    // logged below
  }

  if (res.ok && typeof data.access_token === 'string') {
    return { ok: true, accessToken: data.access_token }
  }
  console.error(
    `zaincash /oauth2/token -> HTTP ${res.status} url=${baseUrl(cfg)}/oauth2/token body=${rawBody.slice(0, 500)}`,
  )
  return { ok: false, error: 'token_failed' }
}

export interface InitResult {
  ok: boolean
  transactionId?: string
  redirectUrl?: string
  error?: string
}

export async function initTransaction(
  cfg: ZainCashConfig,
  params: { amount: number; orderId: string; serviceType?: string },
): Promise<InitResult> {
  const token = await getAccessToken(cfg)
  if (!token.ok || !token.accessToken) {
    return { ok: false, error: token.error ?? 'token_failed' }
  }

  const res = await fetch(
    `${baseUrl(cfg)}/api/v2/payment-gateway/transaction/init`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token.accessToken}`,
      },
      body: JSON.stringify({
        language: cfg.lang,
        // Must be a standard 36-char UUID (ZainCash rejects our own
        // `sello-<id>-<uuid>` order id format here) — orderId below carries
        // our own reference instead, which the gateway accepts as any string.
        externalReferenceId: crypto.randomUUID(),
        orderId: params.orderId,
        serviceType: params.serviceType ?? cfg.serviceType,
        amount: { value: String(params.amount), currency: 'IQD' },
        redirectUrls: {
          successUrl: cfg.successUrl,
          failureUrl: cfg.failureUrl,
        },
      }),
    },
  )

  const rawBody = await res.text()
  let data: Record<string, unknown> = {}
  try {
    data = JSON.parse(rawBody)
  } catch {
    // Non-JSON response (e.g. an HTML error page from a proxy/gateway) —
    // rawBody is still logged below so the real cause is visible.
  }

  const redirectUrl =
    typeof data.redirectUrl === 'string' ? data.redirectUrl : undefined
  const details = data.transactionDetails as
    | Record<string, unknown>
    | undefined
  const transactionId =
    details && typeof details.transactionId === 'string'
      ? details.transactionId
      : undefined

  if (res.ok && redirectUrl && transactionId) {
    return { ok: true, transactionId, redirectUrl }
  }

  // Log full detail server-side; the client only ever sees the short `message`.
  console.error(
    `zaincash /transaction/init -> HTTP ${res.status} url=${baseUrl(cfg)}/api/v2/payment-gateway/transaction/init body=${rawBody.slice(0, 500)}`,
  )
  const message =
    typeof data.message === 'string'
      ? data.message
      : typeof data.error === 'string'
      ? data.error
      : 'init_failed'
  return { ok: false, error: message }
}
