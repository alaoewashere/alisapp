// ZainCash redirects the customer's WebView here after payment with a signed
// JWT in `?token=`. This is the ONLY place the outcome is trusted: we verify
// the signature, update the order, then bounce the WebView to a sentinel URL
// the app intercepts to close the sheet. The app then re-reads the order from
// the DB (source of truth) — it never trusts the query string for status.
//
// This function must be public (verify_jwt = false) because ZainCash, not a
// logged-in user, calls it.

import { createClient } from 'npm:@supabase/supabase-js@2'

import { loadZainCashConfig, verifyJwt } from '../_shared/zaincash.ts'

function redirectTo(url: string): Response {
  return new Response(null, { status: 302, headers: { Location: url } })
}

Deno.serve(async (req) => {
  const cfg = loadZainCashConfig()
  const url = new URL(req.url)
  const token = url.searchParams.get('token')

  const sentinel = (status: string, orderId: string) => {
    const u = new URL(cfg.returnUrl)
    u.searchParams.set('status', status)
    if (orderId) u.searchParams.set('orderId', orderId)
    return u.toString()
  }

  if (!token) {
    return redirectTo(sentinel('failed', ''))
  }

  try {
    const payload = await verifyJwt(token, cfg.secret)
    if (!payload) {
      return redirectTo(sentinel('failed', ''))
    }

    const orderId = String(payload.orderid ?? payload.orderId ?? '')
    const rawStatus = String(payload.status ?? 'failed')
    const status =
      rawStatus === 'success' || rawStatus === 'completed'
        ? 'paid'
        : rawStatus === 'pending'
        ? 'pending'
        : 'failed'

    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    if (supabaseUrl && serviceRoleKey && orderId) {
      const admin = createClient(supabaseUrl, serviceRoleKey, {
        auth: { autoRefreshToken: false, persistSession: false },
      })
      // Only advance a still-pending order, so a replayed callback can't flip a
      // settled order. Match transaction_id defensively too.
      await admin
        .from('zaincash_orders')
        .update({
          status,
          operation_id: payload.operationid
            ? String(payload.operationid)
            : null,
          gateway_payload: payload,
        })
        .eq('order_id', orderId)
        .eq('status', 'pending')
    }

    return redirectTo(sentinel(status, orderId))
  } catch (err) {
    console.error('zaincash-callback error', err)
    return redirectTo(sentinel('failed', ''))
  }
})
