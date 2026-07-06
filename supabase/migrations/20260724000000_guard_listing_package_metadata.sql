-- Block client-side paid package escalation via metadata / auto-approve bypass.

CREATE OR REPLACE FUNCTION public.guard_listing_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  -- Set by approve_pending_purchase (service role) when applying a verified purchase.
  IF current_setting('sello.trusted_package_update', true) = '1' THEN
    IF TG_OP = 'UPDATE' THEN
      NEW.status := OLD.status;
      NEW.views_count := OLD.views_count;
      NEW.contact_count := OLD.contact_count;
      NEW.reference_no := OLD.reference_no;
      NEW.user_id := OLD.user_id;
      NEW.created_at := OLD.created_at;
      NEW.reviewed_at := OLD.reviewed_at;
      NEW.rejection_reason := OLD.rejection_reason;
      RETURN NEW;
    END IF;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.status := 'pending';
    NEW.is_featured := FALSE;
    NEW.is_boosted := FALSE;
    NEW.is_verified_seller := FALSE;
    NEW.views_count := 0;
    NEW.contact_count := 0;
    NEW.reviewed_at := NULL;
    NEW.rejection_reason := NULL;
    NEW.metadata := jsonb_set(
      COALESCE(NEW.metadata, '{}'::jsonb),
      '{listing_package}',
      '"standard"'::jsonb,
      true
    );
    RETURN NEW;
  END IF;

  NEW.status := OLD.status;
  NEW.is_featured := OLD.is_featured;
  NEW.is_boosted := OLD.is_boosted;
  NEW.is_verified_seller := OLD.is_verified_seller;
  NEW.views_count := OLD.views_count;
  NEW.contact_count := OLD.contact_count;
  NEW.reference_no := OLD.reference_no;
  NEW.user_id := OLD.user_id;
  NEW.created_at := OLD.created_at;
  NEW.reviewed_at := OLD.reviewed_at;
  NEW.rejection_reason := OLD.rejection_reason;

  -- Non-admins cannot upgrade listing_package through metadata edits.
  NEW.metadata := jsonb_set(
    COALESCE(NEW.metadata, OLD.metadata, '{}'::jsonb),
    '{listing_package}',
    COALESCE(OLD.metadata->'listing_package', '"standard"'::jsonb),
    true
  );

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.approve_pending_purchase(p_pending_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pending public.pending_purchases%ROWTYPE;
  v_purchase_id UUID;
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'admin_required';
  END IF;

  SELECT * INTO v_pending
  FROM public.pending_purchases
  WHERE id = p_pending_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'pending_purchase_not_found';
  END IF;

  IF v_pending.status <> 'pending' THEN
    RAISE EXCEPTION 'pending_purchase_not_pending';
  END IF;

  INSERT INTO public.listing_purchases (
    user_id,
    listing_id,
    package_type,
    price,
    user_name,
    user_phone,
    user_email
  )
  VALUES (
    v_pending.user_id,
    v_pending.listing_id,
    v_pending.package_type,
    v_pending.price,
    v_pending.user_name,
    v_pending.user_phone,
    v_pending.user_email
  )
  RETURNING id INTO v_purchase_id;

  PERFORM set_config('sello.trusted_package_update', '1', true);

  UPDATE public.listings
  SET
    metadata = jsonb_set(
      COALESCE(metadata, '{}'::jsonb),
      '{listing_package}',
      to_jsonb(v_pending.package_type::text),
      true
    ),
    is_featured = (v_pending.package_type = 'premium'),
    is_boosted = (v_pending.package_type = 'pro'),
    is_verified_seller = (v_pending.package_type <> 'standard'),
    expires_at = now() + interval '30 days',
    updated_at = now()
  WHERE id = v_pending.listing_id
    AND user_id = v_pending.user_id;

  IF v_pending.package_type IN ('pro', 'premium') THEN
    INSERT INTO public.boosts (listing_id, user_id, type, expires_at, amount_paid)
    VALUES (
      v_pending.listing_id,
      v_pending.user_id,
      CASE
        WHEN v_pending.package_type = 'premium' THEN 'featured'::public.boost_type
        ELSE 'boosted'::public.boost_type
      END,
      now() + interval '30 days',
      v_pending.price::bigint
    );
  END IF;

  UPDATE public.pending_purchases
  SET status = 'approved',
      reviewed_at = now(),
      reviewed_by = auth.uid()
  WHERE id = p_pending_id;

  RETURN v_purchase_id;
END;
$$;
