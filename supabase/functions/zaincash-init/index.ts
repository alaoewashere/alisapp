// Creates a ZainCash transaction for the authenticated user.
// The secret never leaves the server; the app only receives a transaction id
// and the hosted pay URL.

import { createClient } from 'npm:@supabase/supabase-js@2'

import { corsHeaders, jsonResponse } from '../_shared/security.ts'
import { initTransaction, loadZainCashConfig } from '../_shared/zaincash.ts'

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin')

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) })
  }
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'method_not_allowed' }, 405, origin)
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader?.startsWith('Bearer ')) {
    return jsonResponse({ error: 'unauthorized' }, 401, origin)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return jsonResponse({ error: 'server_misconfigured' }, 500, origin)
  }

  const supabaseUser = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  })
  const { data: userData, error: userError } = await supabaseUser.auth.getUser()
  if (userError || !userData.user) {
    return jsonResponse({ error: 'unauthorized' }, 401, origin)
  }

  try {
    const body = await req.json().catch(() => ({}))
    const amount = Number(body?.amount)
    const listingId = (body?.listing_id as string | undefined) ?? null
    const serviceType = (body?.service_type as string | undefined) ?? undefined

    if (!Number.isFinite(amount) || amount < 250) {
      return jsonResponse({ error: 'invalid_amount' }, 400, origin)
    }

    const cfg = loadZainCashConfig()
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    // Stable, unique reference for this order.
    const orderId = `sello-${userData.user.id.slice(0, 8)}-${crypto.randomUUID()}`

    const init = await initTransaction(cfg, {
      amount,
      orderId,
      serviceType,
    })
    if (!init.ok || !init.transactionId) {
      console.error('zaincash init failed', init.error)
      return jsonResponse({ error: 'gateway_error', detail: init.error }, 502, origin)
    }

    const { error: insertError } = await admin.from('zaincash_orders').insert({
      user_id: userData.user.id,
      order_id: orderId,
      listing_id: listingId,
      amount,
      service_type: serviceType ?? cfg.serviceType,
      transaction_id: init.transactionId,
      status: 'pending',
    })
    if (insertError) {
      console.error('zaincash_orders insert failed', insertError.message)
      return jsonResponse({ error: 'order_insert_failed' }, 500, origin)
    }

    return jsonResponse(
      {
        order_id: orderId,
        transaction_id: init.transactionId,
        pay_url: init.redirectUrl,
        return_url: cfg.returnUrl,
      },
      200,
      origin,
    )
  } catch (err) {
    const message = err instanceof Error ? err.message : 'unknown_error'
    console.error('zaincash-init error', message)
    return jsonResponse({ error: message }, 500, origin)
  }
})
