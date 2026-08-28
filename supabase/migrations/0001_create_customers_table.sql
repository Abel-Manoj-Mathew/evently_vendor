-- Create customers table
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Row Level Security (RLS) Policies
CREATE POLICY "Users can view their business customers" 
ON public.customers FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = customers.business_id 
        AND b.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can insert business customers" 
ON public.customers FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = customers.business_id 
        AND b.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can update their business customers" 
ON public.customers FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = customers.business_id 
        AND b.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can delete their business customers" 
ON public.customers FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = customers.business_id 
        AND b.owner_id = auth.uid()
    )
);
