-- Admins approving/rejecting a listing in the admin dashboard never actually
-- notified the seller — the rejection reason was stored on the listing but
-- no notification row was ever created, so users had no idea why (or that)
-- their listing was rejected. This adds that notification automatically.
CREATE OR REPLACE FUNCTION public.notify_listing_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_title TEXT;
BEGIN
  IF NEW.status IS NOT DISTINCT FROM OLD.status THEN
    RETURN NEW;
  END IF;

  v_title := COALESCE(NEW.title_ar, NEW.title, '');

  IF NEW.status = 'rejected' THEN
    INSERT INTO public.notifications (user_id, listing_id, type, title, body)
    VALUES (
      NEW.user_id,
      NEW.id,
      'listing_rejected',
      'تم رفض إعلانك',
      'تم رفض إعلانك: ' || v_title || '. السبب: ' ||
        COALESCE(NULLIF(NEW.rejection_reason, ''), 'يرجى مراجعة تفاصيل الإعلان')
    );
  ELSIF NEW.status = 'approved' THEN
    INSERT INTO public.notifications (user_id, listing_id, type, title, body)
    VALUES (
      NEW.user_id,
      NEW.id,
      'listing_approved',
      'تمت الموافقة على إعلانك',
      'تمت الموافقة على إعلانك: ' || v_title
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_status_notify ON public.listings;
CREATE TRIGGER on_listing_status_notify
  AFTER UPDATE ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.notify_listing_status_change();
