/*
  # Create Enterprise White-Label System

  1. New Tables
    - `enterprise_leads`
      - Captures initial registrations
      - Tracks partner attribution
      - Status progression
    
    - `enterprise_access_tokens`
      - Magic link tokens for replay vault
      - Time-limited access (7 days)
      - One-time or limited use
    
    - `enterprise_applications`
      - Full application submissions
      - Qualification data
      - Approval workflow
    
    - `enterprise_orders`
      - Contract and payment tracking
      - Stripe integration
      - Partner commission metadata

  2. Security
    - Enable RLS on all tables
    - Public access for token verification
    - Authenticated access for admin

  3. Indexes
    - Token lookup optimization
    - Partner attribution tracking
    - Email-based lookups
*/

-- Create enterprise leads table
CREATE TABLE IF NOT EXISTS enterprise_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  partner_slug text,
  source text DEFAULT 'enterprise',
  utm_source text,
  utm_campaign text,
  utm_medium text,
  name text NOT NULL,
  email text NOT NULL,
  phone text,
  company text,
  size_clients int,
  current_crm text,
  monthly_revenue_range text,
  status text DEFAULT 'registered',
  metadata jsonb DEFAULT '{}'::jsonb
);

-- Create enterprise access tokens table
CREATE TABLE IF NOT EXISTS enterprise_access_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  lead_id uuid REFERENCES enterprise_leads(id) ON DELETE CASCADE,
  email text NOT NULL,
  token text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  last_accessed_at timestamptz,
  access_count int DEFAULT 0
);

-- Create enterprise applications table
CREATE TABLE IF NOT EXISTS enterprise_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  lead_id uuid REFERENCES enterprise_leads(id) ON DELETE CASCADE,
  partner_slug text,
  company_name text NOT NULL,
  contact_name text NOT NULL,
  contact_email text NOT NULL,
  contact_phone text,
  num_locations int,
  num_clients int,
  current_systems text,
  monthly_ad_spend text,
  growth_goals text,
  tier_interest text,
  answers jsonb DEFAULT '{}'::jsonb,
  status text DEFAULT 'submitted',
  reviewed_by uuid,
  reviewed_at timestamptz,
  notes text
);

-- Create enterprise orders table
CREATE TABLE IF NOT EXISTS enterprise_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  lead_id uuid REFERENCES enterprise_leads(id) ON DELETE CASCADE,
  application_id uuid REFERENCES enterprise_applications(id) ON DELETE SET NULL,
  partner_slug text,
  tier text NOT NULL,
  setup_fee_cents int NOT NULL,
  monthly_fee_cents int NOT NULL,
  per_unit_fee_cents int DEFAULT 0,
  stripe_customer_id text,
  stripe_subscription_id text,
  stripe_session_id text,
  contract_signed_at timestamptz,
  contract_document_url text,
  status text DEFAULT 'pending',
  activated_at timestamptz,
  metadata jsonb DEFAULT '{}'::jsonb
);

-- Create enterprise webinar tracking table
CREATE TABLE IF NOT EXISTS enterprise_webinar_views (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  lead_id uuid REFERENCES enterprise_leads(id) ON DELETE CASCADE,
  token_id uuid REFERENCES enterprise_access_tokens(id) ON DELETE CASCADE,
  webinar_type text DEFAULT 'main_demo',
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  watch_duration_seconds int DEFAULT 0,
  completion_percentage int DEFAULT 0,
  cta_clicks jsonb DEFAULT '[]'::jsonb
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_enterprise_leads_email
  ON enterprise_leads(email);

CREATE INDEX IF NOT EXISTS idx_enterprise_leads_partner
  ON enterprise_leads(partner_slug)
  WHERE partner_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_enterprise_leads_status
  ON enterprise_leads(status);

CREATE INDEX IF NOT EXISTS idx_enterprise_tokens_token
  ON enterprise_access_tokens(token);

CREATE INDEX IF NOT EXISTS idx_enterprise_tokens_email
  ON enterprise_access_tokens(email);

CREATE INDEX IF NOT EXISTS idx_enterprise_tokens_expiry
  ON enterprise_access_tokens(expires_at)
  WHERE used_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_enterprise_applications_lead
  ON enterprise_applications(lead_id);

CREATE INDEX IF NOT EXISTS idx_enterprise_applications_status
  ON enterprise_applications(status);

CREATE INDEX IF NOT EXISTS idx_enterprise_orders_lead
  ON enterprise_orders(lead_id);

CREATE INDEX IF NOT EXISTS idx_enterprise_orders_partner
  ON enterprise_orders(partner_slug)
  WHERE partner_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_enterprise_orders_stripe_session
  ON enterprise_orders(stripe_session_id);

-- Enable RLS
ALTER TABLE enterprise_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE enterprise_access_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE enterprise_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE enterprise_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE enterprise_webinar_views ENABLE ROW LEVEL SECURITY;

-- Policies for enterprise_leads
CREATE POLICY "Public can insert enterprise leads"
  ON enterprise_leads FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Admins can view all enterprise leads"
  ON enterprise_leads FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Policies for enterprise_access_tokens
CREATE POLICY "Public can verify tokens"
  ON enterprise_access_tokens FOR SELECT
  TO anon, authenticated
  USING (
    expires_at > now()
  );

CREATE POLICY "System can create tokens"
  ON enterprise_access_tokens FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "System can update token usage"
  ON enterprise_access_tokens FOR UPDATE
  TO anon, authenticated
  USING (true);

-- Policies for enterprise_applications
CREATE POLICY "Public can submit applications"
  ON enterprise_applications FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Admins can view applications"
  ON enterprise_applications FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update applications"
  ON enterprise_applications FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Policies for enterprise_orders
CREATE POLICY "Admins can manage orders"
  ON enterprise_orders FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Policies for webinar views
CREATE POLICY "Public can track webinar views"
  ON enterprise_webinar_views FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Public can update own webinar views"
  ON enterprise_webinar_views FOR UPDATE
  TO anon, authenticated
  USING (true);

-- Create function to generate secure token
CREATE OR REPLACE FUNCTION generate_enterprise_token()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  token_value text;
BEGIN
  token_value := encode(gen_random_bytes(32), 'base64');
  token_value := replace(token_value, '/', '_');
  token_value := replace(token_value, '+', '-');
  token_value := replace(token_value, '=', '');
  RETURN token_value;
END;
$$;

-- Create function to cleanup expired tokens (run periodically)
CREATE OR REPLACE FUNCTION cleanup_expired_enterprise_tokens()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  DELETE FROM enterprise_access_tokens
  WHERE expires_at < now() - INTERVAL '30 days';
END;
$$;
