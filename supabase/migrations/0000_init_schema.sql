-- Create public schema tables

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Businesses Table
CREATE TABLE IF NOT EXISTS public.businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Business Categories (Master List)
CREATE TABLE IF NOT EXISTS public.business_catagories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Business Category Selections (Junction Table)
CREATE TABLE IF NOT EXISTS public.business_category_selections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
    name TEXT NOT NULL REFERENCES public.business_catagories(name) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_catagories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_category_selections ENABLE ROW LEVEL SECURITY;

-- Row Level Security (RLS) Policies

-- Profiles: Users can view and edit their own profiles
CREATE POLICY "Users can view their own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Businesses: Users can view and manage their own businesses
CREATE POLICY "Users can view their own businesses" 
ON public.businesses FOR SELECT 
USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own businesses" 
ON public.businesses FOR INSERT 
WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own businesses" 
ON public.businesses FOR UPDATE 
USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own businesses" 
ON public.businesses FOR DELETE 
USING (auth.uid() = owner_id);

-- Master Categories: Anyone can view, only admins (or no one via app) can modify
CREATE POLICY "Allow public read access to categories" 
ON public.business_catagories FOR SELECT 
USING (true);

-- Business Category Selections: Users can manage selections for their own businesses
CREATE POLICY "Users can view their business categories" 
ON public.business_category_selections FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = business_category_selections.business_id 
        AND b.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can insert their business categories" 
ON public.business_category_selections FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = business_category_selections.business_id 
        AND b.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can delete their business categories" 
ON public.business_category_selections FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.businesses b 
        WHERE b.id = business_category_selections.business_id 
        AND b.owner_id = auth.uid()
    )
);

-- Insert Initial Categories
INSERT INTO public.business_catagories (name) VALUES 
  ('Photographer'),
  ('Videographer'),
  ('Caterer'),
  ('Decorator'),
  ('DJ'),
  ('Makeup Artist'),
  ('Venue Provider'),
  ('Event Planner'),
  ('Sound & Lighting'),
  ('Mehendi Artist'),
  ('Florist'),
  ('Baker')
ON CONFLICT (name) DO NOTHING;
