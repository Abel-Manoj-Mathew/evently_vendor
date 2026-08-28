-- Add unique constraint for business_id and phone on customers table
ALTER TABLE public.customers 
ADD CONSTRAINT customers_business_id_phone_key UNIQUE (business_id, phone);
