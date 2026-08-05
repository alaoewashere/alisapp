-- Notify admin's phone via ntfy.sh: new listing pending, new report, new
-- seller verification request. Topic must be a hard-to-guess string (ntfy
-- topics are public by default — anyone who knows it can read/post). Set:
--   INSERT INTO public.app_settings (key, value) VALUES ('ntfy_topic', 'souqak-mod-<random>')
--   ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
-- then subscribe in the ntfy app to that same topic.
-- (ALTER DATABASE ... SET is blocked on managed Postgres — no superuser —
-- so the topic lives in app_settings, not a GUC.)

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Shared sender — trigger functions below just build title/body/click.
CREATE OR REPLACE FUNCTION public.notify_ntfy(
  p_title TEXT,
  p_body TEXT,
  p_click TEXT DEFAULT NULL,
  p_tags TEXT DEFAULT 'bell'
) RETURNS VOID AS $$
DECLARE
  topic TEXT := (SELECT value FROM public.app_settings WHERE key = 'ntfy_topic');
  headers JSONB;
BEGIN
  IF topic IS NULL OR btrim(topic) = '' THEN
    RETURN;
  END IF;

  headers := jsonb_build_object(
    'Title', p_title,
    'Priority', 'high',
    'Tags', p_tags
  );
  IF p_click IS NOT NULL THEN
    headers := headers || jsonb_build_object('Click', p_click);
  END IF;

  PERFORM net.http_post(
    url := 'https://ntfy.sh/' || topic,
    headers := headers,
    body := to_jsonb(p_body)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ---------------------------------------------------------------------------
-- New listing pending moderation
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.notify_ntfy_new_listing()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.notify_ntfy(
    'إعلان جديد بانتظار الموافقة',
    coalesce(NEW.title_ar, NEW.title, 'إعلان جديد'),
    NULL
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_listing_pending_notify_ntfy ON public.listings;
CREATE TRIGGER on_listing_pending_notify_ntfy
  AFTER INSERT ON public.listings
  FOR EACH ROW
  WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION public.notify_ntfy_new_listing();

-- ---------------------------------------------------------------------------
-- New user report
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.notify_ntfy_new_report()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.notify_ntfy(
    'بلاغ جديد',
    NEW.reason,
    NULL,
    'warning'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_report_notify_ntfy ON public.reports;
CREATE TRIGGER on_report_notify_ntfy
  AFTER INSERT ON public.reports
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_ntfy_new_report();

-- ---------------------------------------------------------------------------
-- New seller verification request
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.notify_ntfy_new_verification()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.notify_ntfy(
    'طلب توثيق بائع جديد',
    NEW.document_type,
    NULL,
    'id'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_verification_notify_ntfy ON public.verification_requests;
CREATE TRIGGER on_verification_notify_ntfy
  AFTER INSERT ON public.verification_requests
  FOR EACH ROW
  WHEN (NEW.status = 'pending')
  EXECUTE FUNCTION public.notify_ntfy_new_verification();
