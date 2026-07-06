// Server-side ZainCash helpers. The secret lives ONLY here (in env), never in
// the mobile app. Signs the JWT, calls the gateway, verifies redirect tokens.

export interface ZainCashConfig {
  merchantId: string
  msisdn: string
  secret: string
  isTest: boolean
  serviceType: string
  lang: string
  redirectUrl: string // ZainCash redirects the WebView here (our callback fn)
  returnUrl: string // where the callback bounces the WebView so the app closes it
}

// Defaults are ZainCash's PUBLIC sandbox credentials — safe for testing, they
// never move real money. Override every value with env vars in production.
export function loadZainCashConfig(): ZainCashConfig {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  return {
    merchantId:
      Deno.env.get('ZAINCASH_MERCHANT_ID') ?? '5ffacf6612b5777c6d44266f',
    msisdn: Deno.env.get('ZAINCASH_MSISDN') ?? '9647835077893',
    secret:
      Deno.env.get('ZAINCASH_SECRET') ??
      '$2y$10$hBbAZo2GfSSvyqAyV2SaqOfYewgYpfR1O19gIh4SqyGWdmySZYPuS',
    isTest: (Deno.env.get('ZAINCASH_IS_TEST') ?? 'true') !== 'false',
    serviceType: Deno.env.get('ZAINCASH_SERVICE_TYPE') ?? 'Sello Marketplace',
    lang: Deno.env.get('ZAINCASH_LANG') ?? 'ar',
    redirectUrl:
      Deno.env.get('ZAINCASH_REDIRECT_URL') ??
      `${supabaseUrl}/functions/v1/zaincash-callback`,
    returnUrl:
      Deno.env.get('ZAINCASH_RETURN_URL') ??
      'https://sello.app/zaincash/return',
  }
}

export function baseUrl(cfg: ZainCashConfig): string {
  return cfg.isTest ? 'https://test.zaincash.iq' : 'https://api.zaincash.iq'
}

export function payUrl(cfg: ZainCashConfig, transactionId: string): string {
  return `${baseUrl(cfg)}/transaction/pay?id=${transactionId}`
}

// --- base64url ----------------------------------------------------------

function b64urlEncode(bytes: Uint8Array): string {
  let bin = ''
  for (const b of bytes) bin += String.fromCharCode(b)
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

function b64urlEncodeString(s: string): string {
  return b64urlEncode(new TextEncoder().encode(s))
}

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

export async function signJwt(
  payload: Record<string, unknown>,
  secret: string,
): Promise<string> {
  const header = b64urlEncodeString(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
  const body = b64urlEncodeString(JSON.stringify(payload))
  const data = `${header}.${body}`
  const key = await hmacKey(secret)
  const sig = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(data),
  )
  return `${data}.${b64urlEncode(new Uint8Array(sig))}`
}

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

export interface InitResult {
  ok: boolean
  transactionId?: string
  error?: string
}

export async function initTransaction(
  cfg: ZainCashConfig,
  params: { amount: number; orderId: string; serviceType?: string },
): Promise<InitResult> {
  const now = Math.floor(Date.now() / 1000)
  const token = await signJwt(
    {
      amount: params.amount,
      serviceType: params.serviceType ?? cfg.serviceType,
      msisdn: cfg.msisdn,
      orderId: params.orderId,
      redirectUrl: cfg.redirectUrl,
      iat: now,
      exp: now + 60 * 60 * 4,
    },
    cfg.secret,
  )

  const res = await fetch(`${baseUrl(cfg)}/transaction/init`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      token,
      merchantId: cfg.merchantId,
      lang: cfg.lang,
    }),
  })

  const data = await res.json().catch(() => ({}))
  if (res.ok && data?.id) {
    return { ok: true, transactionId: String(data.id) }
  }
  const err = data?.err
  const message =
    err && typeof err === 'object'
      ? String(err.msg ?? err.name ?? JSON.stringify(err))
      : String(err ?? 'init_failed')
  return { ok: false, error: message }
}
