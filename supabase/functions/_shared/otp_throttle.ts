import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SEND_LIMIT = Number(Deno.env.get('OTP_SEND_LIMIT_PER_HOUR') ?? '5')
const VERIFY_LIMIT = Number(Deno.env.get('OTP_VERIFY_LIMIT_PER_HOUR') ?? '10')
const WINDOW_MS = 60 * 60 * 1000

export async function checkOtpThrottle(
  phone: string,
  action: 'send' | 'verify',
  ip: string,
): Promise<{ allowed: boolean; reason?: string }> {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!supabaseUrl || !serviceRoleKey) {
    return { allowed: false, reason: 'server_misconfigured' }
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const since = new Date(Date.now() - WINDOW_MS).toISOString()
  const limit = action === 'send' ? SEND_LIMIT : VERIFY_LIMIT

  const { count: phoneCount, error: phoneError } = await admin
    .from('otp_throttle')
    .select('id', { count: 'exact', head: true })
    .eq('phone', phone)
    .eq('action', action)
    .gte('created_at', since)

  if (phoneError) {
    console.error('otp_throttle phone check failed', phoneError.message)
    return { allowed: false, reason: 'throttle_check_failed' }
  }

  if ((phoneCount ?? 0) >= limit) {
    return { allowed: false, reason: 'rate_limited_phone' }
  }

  if (ip && ip !== 'unknown') {
    const { count: ipCount, error: ipError } = await admin
      .from('otp_throttle')
      .select('id', { count: 'exact', head: true })
      .eq('ip_address', ip)
      .eq('action', action)
      .gte('created_at', since)

    if (ipError) {
      console.error('otp_throttle ip check failed', ipError.message)
      return { allowed: false, reason: 'throttle_check_failed' }
    }

    if ((ipCount ?? 0) >= limit * 3) {
      return { allowed: false, reason: 'rate_limited_ip' }
    }
  }

  const { error: insertError } = await admin.from('otp_throttle').insert({
    phone,
    ip_address: ip,
    action,
  })

  if (insertError) {
    console.error('otp_throttle insert failed', insertError.message)
    return { allowed: false, reason: 'throttle_record_failed' }
  }

  return { allowed: true }
}
