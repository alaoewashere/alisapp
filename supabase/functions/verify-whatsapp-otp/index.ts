import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

function syntheticEmailForPhone(normalizedPhone: string): string {
  const phoneDigits = normalizedPhone.replace(/\D/g, '')
  return `phone+${phoneDigits}@auth.sello.local`
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { phone, code } = await req.json()
    if (!phone || !code) {
      return new Response(JSON.stringify({ error: 'phone and code are required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID')
    const authToken = Deno.env.get('TWILIO_AUTH_TOKEN')
    const serviceSid = Deno.env.get('TWILIO_VERIFY_SERVICE_SID')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!accountSid || !authToken || !serviceSid) {
      return new Response(
        JSON.stringify({ error: 'Twilio credentials not configured' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    if (!supabaseUrl || !serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: 'Supabase credentials not configured' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      )
    }

    const normalizedPhone = phone.startsWith('+') ? phone : `+${phone}`

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
      return new Response(JSON.stringify({ status: twilioData.status ?? 'pending' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    const syntheticEmail = syntheticEmailForPhone(normalizedPhone)

    const { data: listData } = await supabaseAdmin.auth.admin.listUsers({
      page: 1,
      perPage: 1000,
    })
    const existing = listData?.users?.find((u) => u.phone === normalizedPhone)

    if (!existing) {
      const { error: createError } = await supabaseAdmin.auth.admin.createUser({
        phone: normalizedPhone,
        email: syntheticEmail,
        phone_confirm: true,
        email_confirm: true,
      })
      if (createError && !createError.message.toLowerCase().includes('already')) {
        throw createError
      }
    } else if (!existing.email) {
      await supabaseAdmin.auth.admin.updateUserById(existing.id, {
        email: syntheticEmail,
        email_confirm: true,
      })
    }

    const emailForLink = existing?.email ?? syntheticEmail
    const { data: linkData, error: linkError } =
      await supabaseAdmin.auth.admin.generateLink({
        type: 'magiclink',
        email: emailForLink,
      })

    if (linkError) {
      throw linkError
    }

    const tokenHash = linkData.properties?.hashed_token
    if (!tokenHash) {
      throw new Error('Failed to mint session token')
    }

    return new Response(
      JSON.stringify({ status: 'approved', token_hash: tokenHash }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    )
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error'
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
