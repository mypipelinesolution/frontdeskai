-- ========================================
-- SAFE MIGRATIONS - Won't conflict with existing tables
-- Run this in Supabase SQL Editor
-- ========================================

-- Only create tables that don't exist yet
-- Skip profiles since it already exists

-- ========================================
-- WORKSPACES TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS workspaces (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  business_name text,
  phone text,
  email text,
  website text,
  subscription_tier text,
  subscription_status text,
  stripe_subscription_id text,
  stripe_customer_id text,
  onboarding_completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add referral column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'workspaces' AND column_name = 'referral_partner_link_slug') THEN
    ALTER TABLE workspaces ADD COLUMN referral_partner_link_slug text;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_workspaces_stripe_subscription ON workspaces(stripe_subscription_id);
CREATE INDEX IF NOT EXISTS idx_workspaces_referral_slug ON workspaces(referral_partner_link_slug) WHERE referral_partner_link_slug IS NOT NULL;

ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own workspaces" ON workspaces;
CREATE POLICY "Users can view their own workspaces" ON workspaces FOR SELECT TO authenticated USING (owner_id = auth.uid());

DROP POLICY IF EXISTS "Users can create workspaces" ON workspaces;
CREATE POLICY "Users can create workspaces" ON workspaces FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Users can update their own workspaces" ON workspaces;
CREATE POLICY "Users can update their own workspaces" ON workspaces FOR UPDATE TO authenticated USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

-- ========================================
-- LEADS TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  email text,
  phone text,
  source text DEFAULT 'web_form',
  status text DEFAULT 'new',
  notes text,
  referral_partner_link_slug text,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leads_workspace_id ON leads(workspace_id);
CREATE INDEX IF NOT EXISTS idx_leads_referral_slug ON leads(referral_partner_link_slug) WHERE referral_partner_link_slug IS NOT NULL;

ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view leads in their workspace" ON leads;
CREATE POLICY "Users can view leads in their workspace" ON leads FOR SELECT TO authenticated 
  USING (EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid()));

DROP POLICY IF EXISTS "Users can create leads in their workspace" ON leads;
CREATE POLICY "Users can create leads in their workspace" ON leads FOR INSERT TO authenticated 
  WITH CHECK (EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid()));

DROP POLICY IF EXISTS "Users can update leads in their workspace" ON leads;
CREATE POLICY "Users can update leads in their workspace" ON leads FOR UPDATE TO authenticated 
  USING (EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid()));

-- ========================================
-- MESSAGES TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  direction text NOT NULL,
  channel text NOT NULL,
  from_number text,
  to_number text,
  body text NOT NULL,
  status text DEFAULT 'sent',
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_workspace_id ON messages(workspace_id);
CREATE INDEX IF NOT EXISTS idx_messages_lead_id ON messages(lead_id);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view messages in their workspace" ON messages;
CREATE POLICY "Users can view messages in their workspace" ON messages FOR SELECT TO authenticated 
  USING (EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = messages.workspace_id AND workspaces.owner_id = auth.uid()));

-- ========================================
-- AUTOMATIONS TABLE
-- ========================================
CREATE TABLE IF NOT EXISTS automations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL,
  trigger text NOT NULL,
  template text NOT NULL,
  enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_automations_workspace_id ON automations(workspace_id);

ALTER TABLE automations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view automations in their workspace" ON automations;
CREATE POLICY "Users can view automations in their workspace" ON automations FOR SELECT TO authenticated 
  USING (EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = automations.workspace_id AND workspaces.owner_id = auth.uid()));

-- ========================================
-- WEBINAR SYSTEM
-- ========================================
CREATE TABLE IF NOT EXISTS webinar_bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  email text NOT NULL,
  full_name text NOT NULL,
  phone text,
  webinar_type text DEFAULT 'live_demo',
  scheduled_for timestamptz,
  status text DEFAULT 'registered',
  attended boolean DEFAULT false,
  referral_slug text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_webinar_bookings_user_id ON webinar_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_webinar_bookings_email ON webinar_bookings(email);

CREATE TABLE IF NOT EXISTS webinar_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES webinar_bookings(id) ON DELETE CASCADE,
  message text NOT NULL,
  response text,
  interaction_type text DEFAULT 'question',
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_webinar_interactions_booking_id ON webinar_interactions(booking_id);

CREATE TABLE IF NOT EXISTS webinar_conversions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES webinar_bookings(id) ON DELETE CASCADE,
  product_name text NOT NULL,
  price_id text NOT NULL,
  amount_cents integer NOT NULL,
  converted boolean DEFAULT false,
  checkout_url text,
  created_at timestamptz DEFAULT now()
);

-- ========================================
-- AUTOMATION SYSTEM
-- ========================================
CREATE TABLE IF NOT EXISTS automation_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  run_at timestamptz DEFAULT now(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  job_type text NOT NULL,
  payload jsonb DEFAULT '{}',
  status text DEFAULT 'pending',
  completed_at timestamptz,
  error text
);

CREATE INDEX IF NOT EXISTS idx_automation_jobs_status ON automation_jobs(status);
CREATE INDEX IF NOT EXISTS idx_automation_jobs_run_at ON automation_jobs(run_at);

CREATE TABLE IF NOT EXISTS checkout_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE SET NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  stripe_session_id text UNIQUE,
  price_id text NOT NULL,
  amount_cents integer NOT NULL,
  status text DEFAULT 'pending',
  referral_partner_link_slug text,
  completed_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_checkout_sessions_stripe_id ON checkout_sessions(stripe_session_id);
CREATE INDEX IF NOT EXISTS idx_checkout_sessions_referral ON checkout_sessions(referral_partner_link_slug) WHERE referral_partner_link_slug IS NOT NULL;

-- ========================================
-- REFERRAL TRACKING
-- ========================================
CREATE TABLE IF NOT EXISTS outbox_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE SET NULL,
  event_type text NOT NULL,
  payload jsonb DEFAULT '{}',
  status text DEFAULT 'pending',
  sent_at timestamptz,
  error text,
  attempts int DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_outbox_events_status ON outbox_events(status);

-- ========================================
-- BOT RESPONSE LIBRARY
-- ========================================
CREATE TABLE IF NOT EXISTS bot_response_library (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  industry text NOT NULL,
  category text NOT NULL,
  question_pattern text NOT NULL,
  response_template text NOT NULL,
  tone text DEFAULT 'professional',
  use_case text,
  tags text[] DEFAULT '{}',
  priority int DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_bot_responses_industry ON bot_response_library(industry);
CREATE INDEX IF NOT EXISTS idx_bot_responses_category ON bot_response_library(category);

-- ========================================
-- Create workspaces for existing users with subscriptions
-- ========================================
INSERT INTO workspaces (owner_id, business_name, stripe_subscription_id, stripe_customer_id, subscription_status)
SELECT 
  id as owner_id,
  COALESCE(company_name, full_name, email) as business_name,
  stripe_subscription_id,
  stripe_customer_id,
  COALESCE(subscription_status, 'trialing') as subscription_status
FROM profiles
WHERE stripe_subscription_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM workspaces WHERE workspaces.owner_id = profiles.id)
ON CONFLICT DO NOTHING;
