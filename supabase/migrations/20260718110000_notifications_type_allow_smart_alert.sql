-- The notifications.type CHECK constraint never included 'smart_alert' (or
-- 'new_listing', which the Flutter notification model at
-- lib/features/notifications/models/app_notification.dart already treats as
-- valid). Without this, the INSERT added in
-- 20260718100000_fix_smart_alerts_notify.sql throws a check-constraint
-- violation inside the AFTER trigger — which aborts the entire enclosing
-- transaction, meaning an admin's listing approval itself would fail/rollback
-- the moment any smart alert matched it.
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check
  CHECK (type = ANY (ARRAY[
    'info'::text,
    'warning'::text,
    'listing_approved'::text,
    'listing_rejected'::text,
    'rating_request'::text,
    'smart_alert'::text,
    'new_listing'::text
  ]));
