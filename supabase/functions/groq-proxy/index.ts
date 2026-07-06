
import { createClient } from 'npm:@supabase/supabase-js@2'

import { corsHeaders, jsonResponse } from '../_shared/security.ts'

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions'
const DEFAULT_MODEL = 'llama-3.3-70b-versatile'
const TIMEOUT_MS = 25_000

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
  const groqKey = Deno.env.get('GROQ_API_KEY')

  if (!supabaseUrl || !anonKey) {
    return jsonResponse({ error: 'supabase_not_configured' }, 500, origin)
  }
  if (!groqKey) {
    return jsonResponse({ error: 'groq_not_configured' }, 500, origin)
  }

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError || !userData.user) {
    return jsonResponse({ error: 'unauthorized' }, 401, origin)
  }

  try {
    const body = await req.json()
    const messages = body?.messages
    if (!Array.isArray(messages) || messages.length === 0) {
      return jsonResponse({ error: 'invalid_messages' }, 400, origin)
    }

    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), TIMEOUT_MS)

    // response_format is forwarded only when the caller asks for it (e.g. the
    // price estimator wants json_object); translation omits it for plain text.
    const payload: Record<string, unknown> = {
      model: body.model ?? DEFAULT_MODEL,
      temperature: body.temperature ?? 0.2,
      messages,
    }
    if (body.response_format) payload.response_format = body.response_format
    if (body.max_tokens) payload.max_tokens = body.max_tokens

    const groqResponse = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${groqKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    }).finally(() => clearTimeout(timer))

    const groqData = await groqResponse.json()
    return jsonResponse(groqData, groqResponse.status, origin)
  } catch (err) {
    const message = err instanceof Error ? err.message : 'unknown_error'
    console.error('groq-proxy error', message)
    return jsonResponse({ error: message }, 500, origin)
  }
})
