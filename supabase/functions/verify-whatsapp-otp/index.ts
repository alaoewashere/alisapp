
import { createClient } from 'npm:@supabase/supabase-js@2'

import {
  clientIp,
  corsHeaders,
  jsonResponse,
  normalizeE164Phone,
  normalizeIraqPhone,
} from '../_shared/security.ts'
import { checkOtpThrottle } from '../_shared/otp_throttle.ts'

function syntheticEmailForPhone(normalizedPhone: string): string {
  const phoneDigits = normalizedPhone.replace(/\D/g, '')
  return `phone+${phoneDigits}@auth.sello.local`
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

async function findUserByPhone(
  admin: ReturnType<typeof createClient>,
  phone: string,
) {
  const { data, error } = await admin.rpc('get_auth_user_id_by_phone', {
    p_phone: phone,
  })
  if (error) {
    console.warn('get_auth_user_id_by_phone failed', error.message)
    return null
  }
  return data as string | null
}

async function mintSessionTokenHash(
  admin: ReturnType<typeof createClient>,
  userId: string,
  normalizedPhone: string,
): Promise<string | null> {
  const syntheticEmail = syntheticEmailForPhone(normalizedPhone)
  const { data: userData, error: userError } =
    await admin.auth.admin.getUserById(userId)

  if (userError) {
    console.error('getUserById failed', userError.message)
    return null
  }

  const emailForLink = userData?.user?.email ?? syntheticEmail
  const { data: linkData, error: linkError } =
    await admin.auth.admin.generateLink({
      type: 'magiclink',
      email: emailForLink,
    })

  if (linkError) {
    console.error('generateLink failed', linkError.message)
    return null
  }

  return linkData.properties?.hashed_token ?? null
}

async function verifyStoredPhoneOtp(
  admin: ReturnType<typeof createClient>,
  userId: string,
  normalizedPhone: string,
  code: string,
): Promise<{ ok: true } | { ok: false; status: string }> {
  const otp = String(code).trim()

  const { data: row, error: fetchError } = await admin
    .from('phone_verifications')
    .select('id, otp, expires_at, used')
    .eq('user_id', userId)
    .eq('phone', normalizedPhone)
    .eq('used', false)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (fetchError) {
    console.error('phone_verifications fetch failed', fetchError.message)
    return { ok: false, status: 'error' }
  }

  if (!row) {
    return { ok: false, status: 'expired' }
  }

  if (new Date(row.expires_at).getTime() < Date.now()) {
    return { ok: false, status: 'expired' }
  }

  if (row.otp !== otp) {
    return { ok: false, status: 'invalid' }
  }

  const { error: markUsedError } = await admin
    .from('phone_verifications')
    .update({ used: true })
    .eq('id', row.id)

  if (markUsedError) {
    console.error('mark used failed', markUsedError.message)
    return { ok: false, status: 'error' }
  }

  return { ok: true }
}

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin')

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) })
  }

  try {
    const body = await req.json()
    const { phone, code, purpose = 'auth' } = body

    const normalizedPhone = usesE164Normalization(purpose)
      ? normalizeE164Phone(phone)
      : normalizeIraqPhone(phone) ?? normalizeE164Phone(phone)

    if (!normalizedPhone || !code) {
      return jsonResponse({ error: 'invalid_request' }, 400, origin)
    }

    const throttle = await checkOtpThrottle(
      normalizedPhone,
      'verify',
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
    if (!supabaseUrl || !serviceRoleKey) {
      return jsonResponse({ error: 'supabase_not_configured' }, 500, origin)
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    if (purpose === 'profile') {
      const userId = await getUserIdFromRequest(req)
      if (!userId) {
        return jsonResponse({ error: 'unauthorized' }, 401, origin)
      }

      const verified = await verifyStoredPhoneOtp(
        supabaseAdmin,
        userId,
        normalizedPhone,
        code,
      )

      if (!verified.ok) {
        return jsonResponse(
          { error: verified.status, status: verified.status },
          400,
          origin,
        )
      }

      const { error: profileError } = await supabaseAdmin
        .from('profiles')
        .update({
          phone: normalizedPhone,
          phone_verified: true,
          updated_at: new Date().toISOString(),
        })
        .eq('id', userId)

      if (profileError) {
        console.error('profile phone update failed', profileError.message)
        return jsonResponse({ error: 'profile_update_failed' }, 500, origin)
      }

      return jsonResponse({ status: 'approved' }, 200, origin)
    }

    if (purpose === 'password_reset') {
      const userId = await findUserByPhone(supabaseAdmin, normalizedPhone)
      if (!userId) {
        return jsonResponse({ error: 'not_registered' }, 404, origin)
      }

      const verified = await verifyStoredPhoneOtp(
        supabaseAdmin,
        userId,
        normalizedPhone,
        code,
      )

      if (!verified.ok) {
        return jsonResponse(
          { error: verified.status, status: verified.status },
          400,
          origin,
        )
      }

      const tokenHash = await mintSessionTokenHash(
        supabaseAdmin,
        userId,
        normalizedPhone,
      )

      if (!tokenHash) {
        return jsonResponse({ error: 'failed_to_mint_session' }, 500, origin)
      }

      return jsonResponse(
        { status: 'approved', token_hash: tokenHash },
        200,
        origin,
      )
    }

    const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID')
    const authToken = Deno.env.get('TWILIO_AUTH_TOKEN')
    const serviceSid = Deno.env.get('TWILIO_VERIFY_SERVICE_SID')

    if (!accountSid || !authToken || !serviceSid) {
      return jsonResponse({ error: 'twilio_not_configured' }, 500, origin)
    }

    const twilioResponse = await fetch(
      `https://verify.twilio.com/v2/Services/${serviceSid}/VerificationChecks`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Basic ' + btoa(`${accountSid}:${authToken}`),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: `whatsapp:${normalizedPhone}`,
          Code: String(code),
        }),
      },
    )

    const twilioData = await twilioResponse.json()

    if (twilioData.status !== 'approved') {
      return jsonResponse({ status: twilioData.status ?? 'pending' }, 400, origin)
    }

    const syntheticEmail = syntheticEmailForPhone(normalizedPhone)
    let existingUserId = await findUserByPhone(supabaseAdmin, normalizedPhone)

    if (!existingUserId) {
      const { data: created, error: createError } =
        await supabaseAdmin.auth.admin.createUser({
          phone: normalizedPhone,
          email: syntheticEmail,
          phone_confirm: true,
          email_confirm: true,
        })
      if (createError && !createError.message.toLowerCase().includes('already')) {
        throw createError
      }
      existingUserId = created?.user?.id ?? null
      if (!existingUserId) {
        existingUserId = await findUserByPhone(supabaseAdmin, normalizedPhone)
      }
    }

    const tokenHash = await mintSessionTokenHash(
      supabaseAdmin,
      existingUserId!,
      normalizedPhone,
    )

    if (!tokenHash) {
      throw new Error('failed_to_mint_session')
    }

    return jsonResponse({ status: 'approved', token_hash: tokenHash }, 200, origin)
  } catch (err) {
    const message = err instanceof Error ? err.message : 'unknown_error'
    console.error('verify-whatsapp-otp error', message)
    return jsonResponse({ error: message }, 500, origin)
  }
})
