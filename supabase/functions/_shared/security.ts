// Shared CORS + validation helpers for Supabase edge functions.

export const ALLOWED_ORIGINS = (Deno.env.get('ALLOWED_ORIGINS') ?? '')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean)

export function corsHeaders(origin: string | null): Record<string, string> {
  const headers: Record<string, string> = {
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }

  if (!origin) {
    return headers
  }

  if (ALLOWED_ORIGINS.length === 0 || ALLOWED_ORIGINS.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin
    headers['Vary'] = 'Origin'
  }

  return headers
}

export function jsonResponse(
  body: unknown,
  status: number,
  origin: string | null,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(origin),
      'Content-Type': 'application/json',
    },
  })
}

/** Iraq mobile numbers in E.164 (+9647XXXXXXXX). */
export function normalizeIraqPhone(raw: string): string | null {
  if (!raw || typeof raw !== 'string') return null
  const trimmed = raw.trim().replace(/\s+/g, '')
  let digits = trimmed
  if (digits.startsWith('+')) {
    digits = digits.slice(1)
  } else if (digits.startsWith('00')) {
    digits = digits.slice(2)
  }
  digits = digits.replace(/\D/g, '')

  if (digits.startsWith('964')) {
    const rest = digits.slice(3)
    if (/^7\d{9}$/.test(rest)) return `+964${rest}`
    return null
  }
  if (digits.startsWith('0') && digits.length === 11 && digits[1] === '7') {
    return `+964${digits.slice(1)}`
  }
  if (/^7\d{9}$/.test(digits)) {
    return `+964${digits}`
  }
  return null
}

/** Generic E.164 (+ and 8–15 digits). */
export function normalizeE164Phone(raw: string): string | null {
  if (!raw || typeof raw !== 'string') return null
  const trimmed = raw.trim().replace(/\s+/g, '')
  let digits = trimmed
  if (digits.startsWith('+')) {
    digits = `+${digits.slice(1).replace(/\D/g, '')}`
  } else if (digits.startsWith('00')) {
    digits = `+${digits.slice(2).replace(/\D/g, '')}`
  } else {
    digits = `+${digits.replace(/\D/g, '')}`
  }
  if (!/^\+\d{8,15}$/.test(digits)) return null
  return digits
}

export function clientIp(req: Request): string {
  return (
    req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ??
    req.headers.get('x-real-ip') ??
    'unknown'
  )
}
