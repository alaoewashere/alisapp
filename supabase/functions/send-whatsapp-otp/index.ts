import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

import {
  clientIp,
  corsHeaders,
  jsonResponse,
  normalizeE164Phone,
  normalizeIraqPhone,
} from '../_shared/security.ts'
import { checkOtpThrottle } from '../_shared/otp_throttle.ts'

function generateOtp(length: 4 | 6 = 6): string {
  if (length === 4) {
    return String(Math.floor(1000 + Math.random() * 9000))
  }
  return String(Math.floor(100000 + Math.random() * 900000))
}

function usesE164Normalization(purpose: string): boolean {
  return purpose === 'profile' || purpose === 'password_reset'
}

async function getUserIdFromRequest(
  req: Request,
): Promise<string | null> {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) return null

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
  if (!supabaseUrl || !anonKey) return null

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const { data, error } = await client.auth.getUser()
  if (error || !data.user) return null
  return data.user.id
}

async function findUserIdByPhone(
  admin: ReturnType<typeof createClient>,
  phone: string,
): Promise<string | null> {
  const { data, error } = await admin.rpc('get_auth_user_id_by_phone', {
    p_phone: phone,
  })
  if (error) {
    console.warn('get_auth_user_id_by_phone failed', error.message)
    return null
  }
  return data as string | null
}

async function sendDirectOtpWhatsApp(
  normalizedPhone: string,
  otp: string,
): Promise<boolean> {
  const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID')
  const authToken = Deno.env.get('TWILIO_AUTH_TOKEN')
  const from = Deno.env.get('TWILIO_WHATSAPP_FROM')

  if (!accountSid || !authToken) {
    console.error('Twilio credentials missing for direct WhatsApp OTP')
    return false
  }

  if (!from) {
    console.warn(
      `TWILIO_WHATSAPP_FROM not set — dev OTP for ${normalizedPhone}: ${otp}`,
    )
    return true
  }

  const fromAddress = from.startsWith('whatsapp:')
    ? from
    : `whatsapp:${from}`

  const response = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
    {
      method: 'POST',
      headers: {
        Authorization: 'Basic ' + btoa(`${accountSid}:${authToken}`),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        From: fromAddress,
        To: `whatsapp:${normalizedPhone}`,
        Body: `رمز التحقق من سيلو: ${otp}\nصالح لمدة 10 دقائق.`,
      }),
    },
  )

  if (!response.ok) {
    const errBody = await response.text()
    console.error('Twilio WhatsApp message failed', errBody)
    return false
  }

  return true
}

async function storeAndSendPhoneOtp(
  admin: ReturnType<typeof createClient>,
  userId: string,
  normalizedPhone: string,
  otpLength: 4 | 6 = 6,
): Promise<boolean> {
  const otp = generateOtp(otpLength)
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString()

  await admin
    .from('phone_verifications')
    .update({ used: true })
    .eq('user_id', userId)
    .eq('phone', normalizedPhone)
    .eq('used', false)

  const { error: insertError } = await admin
    .from('phone_verifications')
    .insert({
      user_id: userId,
      phone: normalizedPhone,
      otp,
      expires_at: expiresAt,
      used: false,
    })

  if (insertError) {
    console.error('phone_verifications insert failed', insertError.message)
    return false
  }

  return await sendDirectOtpWhatsApp(normalizedPhone, otp)
}

serve(async (req) => {
  const origin = req.headers.get('Origin')

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) })
  }

  try {
    const body = await req.json()
    const { phone, purpose = 'auth' } = body

    const normalizedPhone = usesE164Normalization(purpose)
      ? normalizeE164Phone(phone)
      : normalizeIraqPhone(phone) ?? normalizeE164Phone(phone)

    if (!normalizedPhone) {
      return jsonResponse({ error: 'invalid_phone' }, 400, origin)
    }

    const throttle = await checkOtpThrottle(
      normalizedPhone,
      'send',
      clientIp(req),
    )
    if (!throttle.allowed) {
      return jsonResponse(
        { error: throttle.reason ?? 'rate_limited' },
        429,
        origin,
      )
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (purpose === 'profile' || purpose === 'password_reset') {
      if (!supabaseUrl || !serviceRoleKey) {
        return jsonResponse({ error: 'supabase_not_configured' }, 500, origin)
      }

      const admin = createClient(supabaseUrl, serviceRoleKey, {
        auth: { autoRefreshToken: false, persistSession: false },
      })

      let userId: string | null = null

      if (purpose === 'profile') {
        userId = await getUserIdFromRequest(req)
        if (!userId) {
          return jsonResponse({ error: 'unauthorized' }, 401, origin)
        }
      } else {
        userId = await findUserIdByPhone(admin, normalizedPhone)
        if (!userId) {
          return jsonResponse({ error: 'not_registered' }, 404, origin)
        }
      }

      const sent = await storeAndSendPhoneOtp(
        admin,
        userId,
        normalizedPhone,
        purpose === 'password_reset' ? 4 : 6,
      )
      if (!sent) {
        return jsonResponse({ error: 'send_failed' }, 500, origin)
      }

      return jsonResponse({ ok: true }, 200, origin)
    }

    const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID')
    const authToken = Deno.env.get('TWILIO_AUTH_TOKEN')
    const serviceSid = Deno.env.get('TWILIO_VERIFY_SERVICE_SID')

    if (!accountSid || !authToken || !serviceSid) {
      return jsonResponse({ error: 'twilio_not_configured' }, 500, origin)
    }

    const response = await fetch(
      `https://verify.twilio.com/v2/Services/${serviceSid}/Verifications`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Basic ' + btoa(`${accountSid}:${authToken}`),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: `whatsapp:${normalizedPhone}`,
          Channel: 'whatsapp',
        }),
      },
    )

    const data = await response.json()
    return jsonResponse(data, response.ok ? 200 : response.status, origin)
  } catch (err) {
    const message = err instanceof Error ? err.message : 'unknown_error'
    console.error('send-whatsapp-otp error', message)
    return jsonResponse({ error: message }, 500, origin)
  }
})
