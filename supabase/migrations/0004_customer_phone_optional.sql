-- Customer phone numbers are optional and may be shared (product decision,
-- Phase 1). Duplicate phone numbers produce a warning in the app instead of
-- a database rejection.
--
-- Reverses the NOT NULL from 0001 and the unique constraint from 0002.
-- Does not depend on the untracked 0003 (pgsodium), which must NOT be applied.

ALTER TABLE public.customers
  DROP CONSTRAINT IF EXISTS customers_business_id_phone_key;

ALTER TABLE public.customers
  ALTER COLUMN phone DROP NOT NULL;

-- Keeps duplicate-phone lookups per business fast without enforcing
-- uniqueness.
CREATE INDEX IF NOT EXISTS customers_business_id_phone_idx
  ON public.customers (business_id, phone);
