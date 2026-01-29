/*
  # FrontDesk AI Pro - Complete SaaS Schema
  
  1. New Tables
    - profiles (customer accounts)
    - workspaces (business workspaces)
    - leads (captured leads)
    - messages (SMS/email log)
    - automations (templates and sequences)
    - orders (Stripe subscriptions)
    - family_reps (internal reps)
    - internal_payouts (commission tracking)
    - locallink_outbox (partner sync queue)
  
  2. Security
    - Enable RLS on all tables
    - Customers can only access their workspace
    - Admins can access everything
*/

-- Drop old tables
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS visitor_logs CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS visitors CASCADE;

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  role text DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'family_rep')),
  referral_slug text,
  referred_by text,
  stripe_customer_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Workspaces table
CREATE TABLE IF NOT EXISTS workspaces (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  business_name text NOT NULL,
  phone text,
  email text,
  website text,
  subscription_tier text DEFAULT 'starter' CHECK (subscription_tier IN ('starter', 'core', 'pro')),
  subscription_status text DEFAULT 'active' CHECK (subscription_status IN ('active', 'cancelled', 'past_due', 'trialing')),
  stripe_subscription_id text,
  onboarding_completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Leads table
CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  email text,
  phone text,
  source text DEFAULT 'web_form' CHECK (source IN ('web_form', 'missed_call', 'chat', 'manual')),
  status text DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'booked', 'closed', 'lost')),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  direction text NOT NULL CHECK (direction IN ('inbound', 'outbound')),
  channel text NOT NULL CHECK (channel IN ('sms', 'email')),
  from_number text,
  to_number text,
  body text NOT NULL,
  status text DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'failed')),
  created_at timestamptz DEFAULT now()
);

-- Automations table
CREATE TABLE IF NOT EXISTS automations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL CHECK (type IN ('instant_reply', 'missed_call', 'booking', 'review', 'reactivation', 'estimate', 'faq')),
  trigger text NOT NULL,
  template text NOT NULL,
  enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  workspace_id uuid REFERENCES workspaces(id) ON DELETE SET NULL,
  stripe_subscription_id text,
  stripe_customer_id text,
  plan text NOT NULL CHECK (plan IN ('starter', 'core', 'pro')),
  amount integer NOT NULL,
  status text DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'past_due')),
  current_period_end timestamptz,
  referred_by text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Family reps table
CREATE TABLE IF NOT EXISTS family_reps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  referral_slug text UNIQUE NOT NULL,
  commission_rate numeric DEFAULT 0.80,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Internal payouts table
CREATE TABLE IF NOT EXISTS internal_payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_rep_id uuid REFERENCES family_reps(id) ON DELETE CASCADE,
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  amount_due numeric NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
  paid_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Local-Link outbox table
CREATE TABLE IF NOT EXISTS locallink_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  referral_slug text NOT NULL,
  amount numeric NOT NULL,
  sync_status text DEFAULT 'pending' CHECK (sync_status IN ('pending', 'sent', 'failed')),
  sync_attempts integer DEFAULT 0,
  last_sync_attempt timestamptz,
  synced_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_leads_workspace_id ON leads(workspace_id);
CREATE INDEX IF NOT EXISTS idx_messages_workspace_id ON messages(workspace_id);
CREATE INDEX IF NOT EXISTS idx_automations_workspace_id ON automations(workspace_id);
CREATE INDEX IF NOT EXISTS idx_orders_profile_id ON orders(profile_id);
CREATE INDEX IF NOT EXISTS idx_orders_referred_by ON orders(referred_by);
CREATE INDEX IF NOT EXISTS idx_family_reps_referral_slug ON family_reps(referral_slug);
CREATE INDEX IF NOT EXISTS idx_locallink_outbox_sync_status ON locallink_outbox(sync_status);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE automations ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_reps ENABLE ROW LEVEL SECURITY;
ALTER TABLE internal_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE locallink_outbox ENABLE ROW LEVEL SECURITY;

-- Profiles RLS policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Workspaces RLS policies
CREATE POLICY "Users can view their own workspaces"
  ON workspaces FOR SELECT
  TO authenticated
  USING (owner_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Users can create workspaces"
  ON workspaces FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Users can update their own workspaces"
  ON workspaces FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- Leads RLS policies
CREATE POLICY "Users can view leads in their workspace"
  ON leads FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can create leads in their workspace"
  ON leads FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid())
  );

CREATE POLICY "Users can update leads in their workspace"
  ON leads FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = leads.workspace_id AND workspaces.owner_id = auth.uid())
  );

-- Messages RLS policies
CREATE POLICY "Users can view messages in their workspace"
  ON messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = messages.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can create messages in their workspace"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = messages.workspace_id AND workspaces.owner_id = auth.uid())
  );

-- Automations RLS policies
CREATE POLICY "Users can view automations in their workspace"
  ON automations FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = automations.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can create automations in their workspace"
  ON automations FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = automations.workspace_id AND workspaces.owner_id = auth.uid())
  );

CREATE POLICY "Users can update automations in their workspace"
  ON automations FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = automations.workspace_id AND workspaces.owner_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = automations.workspace_id AND workspaces.owner_id = auth.uid())
  );

-- Orders RLS policies
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can view all orders"
  ON orders FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Family reps RLS policies
CREATE POLICY "Family reps can view their own data"
  ON family_reps FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage family reps"
  ON family_reps FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Internal payouts RLS policies
CREATE POLICY "Family reps can view their payouts"
  ON internal_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM family_reps WHERE family_reps.id = internal_payouts.family_rep_id AND family_reps.profile_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can manage payouts"
  ON internal_payouts FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Local-Link outbox RLS policies
CREATE POLICY "Admins can view outbox"
  ON locallink_outbox FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage outbox"
  ON locallink_outbox FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
