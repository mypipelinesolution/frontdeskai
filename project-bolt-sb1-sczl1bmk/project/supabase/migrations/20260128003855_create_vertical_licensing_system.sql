/*
  # Vertical Licensing System

  1. Purpose
    - Enable white-label vertical AI companies (CleanDesk AI, VetDesk AI, etc.)
    - Support multiple branded instances from single core platform
    - Track licensing revenue and manage vertical licenses
    - Industry-specific bot configurations and branding

  2. New Tables
    - `vertical_templates` - Pre-configured industry verticals
    - `vertical_licenses` - Active licenses sold to partners/clients
    - `vertical_configurations` - Custom settings per license
    - `vertical_revenue` - Revenue tracking per vertical

  3. Features
    - Industry presets (cleaning, veterinary, real estate, pet services, etc.)
    - Custom branding (logo, colors, domain)
    - Bot activation templates per industry
    - Pricing tiers per vertical
    - Revenue and usage analytics

  4. Security
    - RLS enabled on all tables
    - Admin-only access to create/manage verticals
    - License owners can only view their own data
*/

-- Vertical Templates table (industry presets)
CREATE TABLE IF NOT EXISTS vertical_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  industry text NOT NULL,
  description text,
  tagline text,
  target_customers text[],
  base_price_monthly integer DEFAULT 9900,
  enabled boolean DEFAULT true,
  branding jsonb DEFAULT '{}'::jsonb,
  bot_preset jsonb DEFAULT '{}'::jsonb,
  ai_context_template text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE vertical_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Anyone can view enabled templates"
  ON vertical_templates
  FOR SELECT
  TO authenticated
  USING (enabled = true);

-- Vertical Licenses table (sold instances)
CREATE TABLE IF NOT EXISTS vertical_licenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  license_key text UNIQUE NOT NULL,
  vertical_template_id uuid REFERENCES vertical_templates(id),
  licensee_id uuid REFERENCES profiles(id),
  business_name text NOT NULL,
  custom_domain text,
  subdomain text UNIQUE,
  status text DEFAULT 'active',
  pricing_tier text DEFAULT 'standard',
  monthly_price integer DEFAULT 9900,
  mrr_contribution integer DEFAULT 0,
  activated_at timestamptz,
  expires_at timestamptz,
  total_workspaces integer DEFAULT 0,
  total_revenue integer DEFAULT 0,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE vertical_licenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own license"
  ON vertical_licenses
  FOR SELECT
  TO authenticated
  USING (licensee_id = auth.uid());

-- Vertical Configurations table (custom branding per license)
CREATE TABLE IF NOT EXISTS vertical_configurations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  license_id uuid REFERENCES vertical_licenses(id) ON DELETE CASCADE,
  logo_url text,
  primary_color text DEFAULT '#2563eb',
  secondary_color text DEFAULT '#1e40af',
  custom_css text,
  welcome_message text,
  support_email text,
  support_phone text,
  features_enabled jsonb DEFAULT '{}'::jsonb,
  bot_customizations jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(license_id)
);

ALTER TABLE vertical_configurations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Licensee can manage own configuration"
  ON vertical_configurations
  FOR ALL
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses
      WHERE licensee_id = auth.uid()
    )
  );

-- Vertical Revenue table (track revenue per vertical)
CREATE TABLE IF NOT EXISTS vertical_revenue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  license_id uuid REFERENCES vertical_licenses(id),
  revenue_type text NOT NULL,
  amount integer NOT NULL,
  currency text DEFAULT 'usd',
  period_start timestamptz NOT NULL,
  period_end timestamptz NOT NULL,
  workspace_count integer DEFAULT 0,
  customer_count integer DEFAULT 0,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE vertical_revenue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own revenue"
  ON vertical_revenue
  FOR SELECT
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses
      WHERE licensee_id = auth.uid()
    )
  );

-- Insert starter vertical templates
INSERT INTO vertical_templates (name, slug, industry, description, tagline, target_customers, base_price_monthly, ai_context_template) VALUES
(
  'CleanDesk AI Pro',
  'cleandesk',
  'Cleaning Services',
  'Complete AI front desk system for cleaning companies. Handles booking, scheduling, and customer communications 24/7.',
  'Your 24/7 AI-Powered Cleaning Business Manager',
  ARRAY['residential cleaning', 'commercial cleaning', 'maid services', 'janitorial services'],
  14900,
  'You are an AI assistant for {business_name}, a professional cleaning service. Help customers book cleaning appointments, answer questions about services (residential, commercial, deep cleaning, move-in/out), provide pricing estimates, and handle scheduling. Be friendly, detail-oriented, and emphasize reliability and quality.'
),
(
  'VetDesk AI',
  'vetdesk',
  'Veterinary Services',
  '24/7 AI receptionist for veterinary clinics. Appointment scheduling, emergency triage, and pet owner support.',
  'Always Here For Your Furry Friends',
  ARRAY['veterinary clinics', 'animal hospitals', 'pet care centers', 'mobile vets'],
  17900,
  'You are an AI assistant for {business_name}, a veterinary clinic. Help pet owners schedule appointments, answer questions about services (wellness exams, vaccinations, surgery, emergency care), provide guidance on when to bring pets in, and show empathy for concerned pet owners. Be compassionate, professional, and knowledgeable about pet health.'
),
(
  'HomeDesk AI',
  'homedesk',
  'Real Estate',
  'AI-powered lead capture and qualification for realtors. 24/7 property inquiries, showing scheduling, and buyer/seller support.',
  'Your Always-On Real Estate Assistant',
  ARRAY['realtors', 'real estate agents', 'brokerages', 'property managers'],
  12900,
  'You are an AI assistant for {business_name}, a real estate professional. Help potential buyers and sellers with property inquiries, schedule showings, qualify leads (budget, timeline, location preferences), answer questions about the buying/selling process, and provide market insights. Be professional, knowledgeable, and focus on building trust.'
),
(
  'PawsDesk AI',
  'pawsdesk',
  'Pet Services',
  'Complete AI system for dog grooming, pet sitting, doggy daycare, and training services.',
  'Tail-Wagging Service, 24/7',
  ARRAY['dog grooming', 'pet sitting', 'doggy daycare', 'dog training', 'pet boarding'],
  13900,
  'You are an AI assistant for {business_name}, a pet service provider. Help pet owners book grooming appointments, arrange pet sitting or daycare, inquire about training programs, and answer questions about services and pricing. Be friendly, enthusiastic about pets, and detail-oriented about pet care requirements.'
),
(
  'LegalDesk AI',
  'legaldesk',
  'Legal Services',
  'AI front desk for law firms. Client intake, consultation scheduling, and case inquiry management.',
  'Professional Legal Support, Always Available',
  ARRAY['law firms', 'attorneys', 'legal practices', 'legal consultants'],
  19900,
  'You are an AI assistant for {business_name}, a law firm. Help potential clients schedule consultations, collect initial case information, answer general questions about practice areas and legal processes (while being clear you cannot provide legal advice), and handle appointment scheduling. Be professional, confidential, and empathetic to client concerns.'
),
(
  'FitDesk AI',
  'fitdesk',
  'Fitness & Wellness',
  'AI system for gyms, personal trainers, yoga studios, and wellness centers.',
  'Your Fitness Journey Starts Here',
  ARRAY['gyms', 'personal trainers', 'yoga studios', 'pilates studios', 'wellness centers'],
  11900,
  'You are an AI assistant for {business_name}, a fitness and wellness provider. Help potential members inquire about memberships, class schedules, personal training, and facility amenities. Schedule tours, trial classes, and training sessions. Be motivating, health-focused, and enthusiastic about helping people reach their fitness goals.'
),
(
  'ConstructDesk AI',
  'constructdesk',
  'Construction & Contracting',
  'AI front desk for contractors, builders, and construction companies. Project inquiries and estimate requests.',
  'Building Success, 24/7',
  ARRAY['general contractors', 'home builders', 'remodelers', 'construction companies'],
  16900,
  'You are an AI assistant for {business_name}, a construction and contracting company. Help potential clients inquire about services (new construction, remodeling, repairs), collect project details for estimates, schedule site visits and consultations, and answer questions about timelines and processes. Be professional, detail-oriented, and focus on quality and reliability.'
),
(
  'BeautyDesk AI',
  'beautydesk',
  'Beauty & Spa',
  'Complete AI system for salons, spas, barbershops, and beauty professionals.',
  'Beautiful Appointments, Effortlessly Booked',
  ARRAY['hair salons', 'day spas', 'barbershops', 'nail salons', 'beauty professionals'],
  10900,
  'You are an AI assistant for {business_name}, a beauty and spa service provider. Help clients book appointments for various services (haircuts, coloring, spa treatments, nails, etc.), answer questions about services and pricing, handle rescheduling, and provide service recommendations. Be friendly, style-focused, and make clients feel pampered and valued.'
)
ON CONFLICT (slug) DO NOTHING;

-- Function to generate unique license key
CREATE OR REPLACE FUNCTION generate_license_key()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_key text;
  v_exists boolean;
BEGIN
  LOOP
    v_key := upper(substring(md5(random()::text) from 1 for 8) || '-' || substring(md5(random()::text) from 1 for 8));
    
    SELECT EXISTS (
      SELECT 1 FROM vertical_licenses WHERE license_key = v_key
    ) INTO v_exists;
    
    EXIT WHEN NOT v_exists;
  END LOOP;
  
  RETURN v_key;
END;
$$;

-- Function to create new vertical license
CREATE OR REPLACE FUNCTION create_vertical_license(
  p_template_id uuid,
  p_licensee_id uuid,
  p_business_name text,
  p_subdomain text,
  p_pricing_tier text DEFAULT 'standard'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_license_id uuid;
  v_license_key text;
  v_template RECORD;
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Only admins can create licenses';
  END IF;

  -- Get template details
  SELECT * INTO v_template
  FROM vertical_templates
  WHERE id = p_template_id AND enabled = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Template not found or disabled';
  END IF;

  -- Generate license key
  v_license_key := generate_license_key();

  -- Create license
  INSERT INTO vertical_licenses (
    license_key,
    vertical_template_id,
    licensee_id,
    business_name,
    subdomain,
    status,
    pricing_tier,
    monthly_price,
    mrr_contribution,
    activated_at
  ) VALUES (
    v_license_key,
    p_template_id,
    p_licensee_id,
    p_business_name,
    p_subdomain,
    'active',
    p_pricing_tier,
    v_template.base_price_monthly,
    v_template.base_price_monthly,
    now()
  ) RETURNING id INTO v_license_id;

  -- Create default configuration
  INSERT INTO vertical_configurations (
    license_id,
    welcome_message,
    features_enabled,
    bot_customizations
  ) VALUES (
    v_license_id,
    v_template.tagline,
    v_template.branding,
    v_template.bot_preset
  );

  RETURN v_license_id;
END;
$$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_licensee ON vertical_licenses(licensee_id);
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_status ON vertical_licenses(status);
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_subdomain ON vertical_licenses(subdomain);
CREATE INDEX IF NOT EXISTS idx_vertical_revenue_license ON vertical_revenue(license_id);
CREATE INDEX IF NOT EXISTS idx_vertical_revenue_period ON vertical_revenue(period_start, period_end);
