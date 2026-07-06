
import { createClient } from 'npm:@supabase/supabase-js@2'

import { corsHeaders, jsonResponse } from '../_shared/security.ts'

// Opt-in for local/dev only. Production must approve via admin or validate store receipts.
const AUTO_APPROVE = Deno.env.get('PURCHASE_AUTO_APPROVE') === 'true'

Deno.serve(async (req) => {
  const origin = req.headers.get('Origin')

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders(origin) })
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
    const body = await req.json()
    const listingId = body?.listing_id as string | undefined
    const packageType = body?.package_type as string | undefined
    const price = body?.price as number | undefined
    const userName = (body?.user_name as string | undefined) ?? ''
    const userPhone = body?.user_phone as string | undefined
    const userEmail = body?.user_email as string | undefined
    const paymentReference = body?.payment_reference as string | undefined

    if (!listingId || !packageType || price == null) {
      return jsonResponse({ error: 'invalid_request' }, 400, origin)
    }
    if (!['pro', 'premium', 'standard'].includes(packageType)) {
      return jsonResponse({ error: 'invalid_package_type' }, 400, origin)
    }

    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    const { data: listing, error: listingError } = await admin
      .from('listings')
      .select('id, user_id')
      .eq('id', listingId)
      .maybeSingle()

    if (listingError || !listing) {
      return jsonResponse({ error: 'listing_not_found' }, 404, origin)
    }
    if (listing.user_id !== userData.user.id) {
      return jsonResponse({ error: 'not_listing_owner' }, 403, origin)
    }

    const { data: pending, error: pendingError } = await admin
      .from('pending_purchases')
      .insert({
        user_id: userData.user.id,
        listing_id: listingId,
        package_type: packageType,
        price,
        user_name: userName,
        user_phone: userPhone,
        user_email: userEmail,
        payment_reference: paymentReference ?? null,
        status: 'pending',
      })
      .select('id')
      .single()

    if (pendingError || !pending) {
      console.error('pending_purchases insert failed', pendingError?.message)
      return jsonResponse({ error: 'pending_insert_failed' }, 500, origin)
    }

    if (AUTO_APPROVE) {
      const { data: purchaseId, error: approveError } = await admin.rpc(
        'approve_pending_purchase',
        { p_pending_id: pending.id },
      )

      if (approveError) {
        console.error('auto approve failed', approveError.message)
        return jsonResponse(
          { status: 'pending', pending_id: pending.id, error: 'auto_approve_failed' },
          202,
          origin,
        )
      }

      return jsonResponse(
        { status: 'approved', pending_id: pending.id, purchase_id: purchaseId },
        200,
        origin,
      )
    }

    return jsonResponse({ status: 'pending', pending_id: pending.id }, 202, origin)
  } catch (err) {
    const message = err instanceof Error ? err.message : 'unknown_error'
    console.error('verify-purchase error', message)
    return jsonResponse({ error: message }, 500, origin)
  }
})
