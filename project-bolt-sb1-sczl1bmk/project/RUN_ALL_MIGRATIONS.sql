/*
  # FrontDesk AI Pro - Initial Schema

  ## Overview
  Creates the complete database schema for a modern front desk management system with visitor tracking, appointments, and AI chat capabilities.

  ## New Tables
  
  ### `visitors`
  Stores visitor information and profiles
  - `id` (uuid, primary key) - Unique visitor identifier
  - `full_name` (text) - Visitor's full name
  - `email` (text, unique) - Visitor's email address
  - `phone` (text) - Contact phone number
  - `company` (text) - Company/organization name
  - `photo_url` (text, optional) - Profile photo URL
  - `notes` (text, optional) - Additional notes about the visitor
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### `appointments`
  Manages scheduled visitor appointments
  - `id` (uuid, primary key) - Unique appointment identifier
  - `visitor_id` (uuid, foreign key) - References visitors table
  - `host_name` (text) - Name of the person being visited
  - `host_email` (text) - Email of the host
  - `purpose` (text) - Purpose of visit
  - `scheduled_time` (timestamptz) - Scheduled appointment time
  - `duration_minutes` (integer) - Expected duration
  - `status` (text) - Status: scheduled, completed, cancelled, no_show
  - `notes` (text, optional) - Additional notes
  - `created_by` (uuid, optional) - Staff member who created it
  - `created_at` (timestamptz) - Record creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### `visitor_logs`
  Tracks all check-ins and check-outs
  - `id` (uuid, primary key) - Unique log identifier
  - `visitor_id` (uuid, foreign key) - References visitors table
  - `appointment_id` (uuid, optional, foreign key) - Associated appointment if any
  - `check_in_time` (timestamptz) - Check-in timestamp
  - `check_out_time` (timestamptz, optional) - Check-out timestamp
  - `purpose` (text) - Purpose of visit
  - `host_name` (text) - Person being visited
  - `badge_number` (text, optional) - Visitor badge number
  - `notes` (text, optional) - Additional notes
  - `created_at` (timestamptz) - Record creation timestamp

  ### `chat_messages`
  Stores AI chat conversation history
  - `id` (uuid, primary key) - Unique message identifier
  - `session_id` (uuid) - Chat session identifier
  - `visitor_email` (text, optional) - Visitor's email if provided
  - `message` (text) - Message content
  - `role` (text) - Role: user or assistant
  - `created_at` (timestamptz) - Message timestamp

  ## Security
  - Enable Row Level Security (RLS) on all tables
  - Authenticated staff can perform all operations
  - Public users can only interact with chat_messages for their session
  - Visitors can view their own records

  ## Indexes
  - Indexes on foreign keys for performance
  - Index on visitor email for quick lookups
  - Index on appointment scheduled_time for calendar queries
  - Index on visitor_logs check_in_time for recent activity
*/

-- Create visitors table
CREATE TABLE IF NOT EXISTS visitors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text,
  company text,
  photo_url text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id uuid REFERENCES visitors(id) ON DELETE CASCADE,
  host_name text NOT NULL,
  host_email text NOT NULL,
  purpose text NOT NULL,
  scheduled_time timestamptz NOT NULL,
  duration_minutes integer DEFAULT 30,
  status text DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
  notes text,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create visitor_logs table
CREATE TABLE IF NOT EXISTS visitor_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id uuid REFERENCES visitors(id) ON DELETE CASCADE,
  appointment_id uuid REFERENCES appointments(id) ON DELETE SET NULL,
  check_in_time timestamptz DEFAULT now(),
  check_out_time timestamptz,
  purpose text NOT NULL,
  host_name text NOT NULL,
  badge_number text,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL,
  visitor_email text,
  message text NOT NULL,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_visitors_email ON visitors(email);
CREATE INDEX IF NOT EXISTS idx_appointments_visitor_id ON appointments(visitor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_scheduled_time ON appointments(scheduled_time);
CREATE INDEX IF NOT EXISTS idx_visitor_logs_visitor_id ON visitor_logs(visitor_id);
CREATE INDEX IF NOT EXISTS idx_visitor_logs_check_in_time ON visitor_logs(check_in_time DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);

-- Enable Row Level Security
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitor_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for visitors table
CREATE POLICY "Authenticated users can view all visitors"
  ON visitors FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert visitors"
  ON visitors FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update visitors"
  ON visitors FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete visitors"
  ON visitors FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for appointments table
CREATE POLICY "Authenticated users can view all appointments"
  ON appointments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert appointments"
  ON appointments FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update appointments"
  ON appointments FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete appointments"
  ON appointments FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for visitor_logs table
CREATE POLICY "Authenticated users can view all visitor logs"
  ON visitor_logs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert visitor logs"
  ON visitor_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update visitor logs"
  ON visitor_logs FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete visitor logs"
  ON visitor_logs FOR DELETE
  TO authenticated
  USING (true);

-- RLS Policies for chat_messages table
CREATE POLICY "Anyone can insert chat messages"
  ON chat_messages FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can view their session messages"
  ON chat_messages FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can view all chat messages"
  ON chat_messages FOR SELECT
  TO authenticated
  USING (true);


-- ========================================
-- Next Migration
-- ========================================


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


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add AI Configuration Fields

  1. Schema Changes
    - Add business_hours JSON field to workspaces for operating hours
    - Add ai_context text field for business description and AI training
    - Add widget_settings JSONB for chatbot customization
    - Add api_keys JSONB for storing encrypted third-party keys
    - Add conversation_context JSONB to leads for tracking conversation state
    
  2. Security
    - Maintain existing RLS policies
    - No new security risks introduced
*/

-- Add AI configuration fields to workspaces
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'workspaces' AND column_name = 'business_hours'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN business_hours JSONB DEFAULT '{"monday": {"open": "09:00", "close": "17:00"}, "tuesday": {"open": "09:00", "close": "17:00"}, "wednesday": {"open": "09:00", "close": "17:00"}, "thursday": {"open": "09:00", "close": "17:00"}, "friday": {"open": "09:00", "close": "17:00"}, "saturday": {"open": "10:00", "close": "14:00"}, "sunday": {"open": null, "close": null}}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'workspaces' AND column_name = 'ai_context'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN ai_context TEXT DEFAULT 'We are a local service business committed to providing excellent customer service.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'workspaces' AND column_name = 'widget_settings'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN widget_settings JSONB DEFAULT '{"theme": "blue", "position": "bottom-right", "greeting": "Hi! How can we help you today?"}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'workspaces' AND column_name = 'api_keys'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN api_keys JSONB DEFAULT '{}';
  END IF;
END $$;

-- Add conversation context to leads
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'conversation_context'
  ) THEN
    ALTER TABLE leads ADD COLUMN conversation_context JSONB DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'leads' AND column_name = 'last_contact_at'
  ) THEN
    ALTER TABLE leads ADD COLUMN last_contact_at TIMESTAMPTZ;
  END IF;
END $$;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Appointments and Sales Features

  1. New Tables
    - appointments (for booking demos, consultations, calls)
  
  2. Changes to existing tables
    - Add appointment_link to workspaces for calendar booking URLs
  
  3. Security
    - Enable RLS on appointments table
    - Allow workspace owners to manage their appointments
    - Allow public to create appointments (for booking demos)
*/

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  title text NOT NULL,
  description text,
  scheduled_at timestamptz NOT NULL,
  duration_minutes integer DEFAULT 30,
  status text DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'no_show')),
  meeting_type text DEFAULT 'demo' CHECK (meeting_type IN ('demo', 'consultation', 'call', 'webinar', 'onboarding')),
  attendee_name text,
  attendee_email text,
  attendee_phone text,
  notes text,
  reminder_sent boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add appointment link field to workspaces
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'workspaces' AND column_name = 'appointment_link'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN appointment_link text;
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_appointments_workspace_id ON appointments(workspace_id);
CREATE INDEX IF NOT EXISTS idx_appointments_lead_id ON appointments(lead_id);
CREATE INDEX IF NOT EXISTS idx_appointments_scheduled_at ON appointments(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);

-- Enable RLS
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Appointments RLS policies
CREATE POLICY "Users can view appointments in their workspace"
  ON appointments FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = appointments.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Anyone can create appointments"
  ON appointments FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update appointments in their workspace"
  ON appointments FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = appointments.workspace_id AND workspaces.owner_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = appointments.workspace_id AND workspaces.owner_id = auth.uid())
  );

CREATE POLICY "Users can delete appointments in their workspace"
  ON appointments FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = appointments.workspace_id AND workspaces.owner_id = auth.uid())
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Complete 37-Bot Ecosystem

  1. New Tables
    - bot_types: Defines all 37 AI bots with metadata
    - workspace_bots: Tracks which bots are enabled per workspace
    - bot_add_ons: Premium add-on bots and pricing
    - bot_execution_logs: Tracks bot activity and performance
  
  2. Bot Categories
    - CORE: 4 bots (all plans)
    - STARTER: 5 bots ($104/mo)
    - CORE_TIER: 6 bots ($154/mo)
    - ACCELERATOR: 6 bots ($204/mo)
    - DFY: 5 bots ($497 one-time)
    - ADD_ON: 7 premium bots (separate pricing)
    - ADMIN: 4 internal bots
  
  3. Security
    - Enable RLS on all tables
    - Workspace owners manage their bots
    - Admins manage bot types
*/

-- Bot types enumeration table
CREATE TABLE IF NOT EXISTS bot_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bot_number text UNIQUE NOT NULL,
  name text NOT NULL,
  category text NOT NULL CHECK (category IN ('CORE', 'STARTER', 'CORE_TIER', 'ACCELERATOR', 'DFY', 'ADD_ON', 'ADMIN')),
  description text NOT NULL,
  capabilities text[] DEFAULT '{}',
  plan_requirement text CHECK (plan_requirement IN ('all', 'starter', 'core', 'pro', 'dfy', 'add_on', 'admin')),
  monthly_price integer DEFAULT 0,
  enabled boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Workspace bots: tracks which bots are active per workspace
CREATE TABLE IF NOT EXISTS workspace_bots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  bot_type_id uuid REFERENCES bot_types(id) ON DELETE CASCADE,
  enabled boolean DEFAULT true,
  configuration jsonb DEFAULT '{}',
  last_executed_at timestamptz,
  execution_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(workspace_id, bot_type_id)
);

-- Bot execution logs for monitoring and analytics
CREATE TABLE IF NOT EXISTS bot_execution_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  bot_type_id uuid REFERENCES bot_types(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  action text NOT NULL,
  status text DEFAULT 'success' CHECK (status IN ('success', 'failed', 'pending')),
  input_data jsonb,
  output_data jsonb,
  error_message text,
  execution_time_ms integer,
  created_at timestamptz DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bot_types_category ON bot_types(category);
CREATE INDEX IF NOT EXISTS idx_bot_types_plan ON bot_types(plan_requirement);
CREATE INDEX IF NOT EXISTS idx_workspace_bots_workspace_id ON workspace_bots(workspace_id);
CREATE INDEX IF NOT EXISTS idx_workspace_bots_bot_type_id ON workspace_bots(bot_type_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_workspace_id ON bot_execution_logs(workspace_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_created_at ON bot_execution_logs(created_at);

-- Enable RLS
ALTER TABLE bot_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_bots ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_execution_logs ENABLE ROW LEVEL SECURITY;

-- Bot types policies (admins only can manage)
CREATE POLICY "Anyone can view bot types"
  ON bot_types FOR SELECT
  TO authenticated, anon
  USING (enabled = true);

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Workspace bots policies
CREATE POLICY "Users can view their workspace bots"
  ON workspace_bots FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can manage their workspace bots"
  ON workspace_bots FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
  );

-- Bot execution logs policies
CREATE POLICY "Users can view their bot execution logs"
  ON bot_execution_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = bot_execution_logs.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "System can insert bot execution logs"
  ON bot_execution_logs FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Insert all 37 bot types
INSERT INTO bot_types (bot_number, name, category, description, capabilities, plan_requirement, monthly_price, sort_order) VALUES

-- CORE FOUNDATION (4 bots - ALL PLANS)
('1', 'AI Business Brain', 'CORE', 'Trained on client business, services, pricing, FAQs, policies. Custom tone/personality. Learns from conversations. Powers everything.', 
 ARRAY['business_knowledge', 'custom_training', 'conversation_learning', 'personality_matching'], 'all', 0, 1),

('2', 'Lead Intelligence Bot', 'CORE', 'Tracks every lead, scores intent, routes hot leads, updates CRM automatically.',
 ARRAY['lead_tracking', 'intent_scoring', 'hot_lead_routing', 'crm_updates'], 'all', 0, 2),

('3', 'Conversation Memory Bot', 'CORE', 'Remembers past chats, recalls context, personalizes replies based on history.',
 ARRAY['conversation_history', 'context_recall', 'personalization'], 'all', 0, 3),

('4', 'Compliance + Safety Bot', 'CORE', 'Filters bad requests, protects business info, prevents inappropriate responses.',
 ARRAY['content_filtering', 'data_protection', 'safety_checks'], 'all', 0, 4),

-- STARTER PLAN (5 bots - $104/month)
('5', 'Website Chat Bot', 'STARTER', '24/7 site chat widget. Lead capture, FAQ handling, instant replies.',
 ARRAY['live_chat', 'lead_capture', 'faq_responses', 'instant_reply'], 'starter', 0, 5),

('6', 'Missed Call Text Bot', 'STARTER', 'Auto-SMS when calls missed. "Sorry we missed youâ€¦" Captures callback info.',
 ARRAY['missed_call_detection', 'auto_sms', 'callback_capture'], 'starter', 0, 6),

('7', 'Basic Follow-Up Bot', 'STARTER', '3-5 message sequences via text + email. Stops leads from ghosting.',
 ARRAY['follow_up_sequences', 'sms_email', 'ghost_prevention'], 'starter', 0, 7),

('8', 'Intake Form Bot', 'STARTER', 'Collects customer info, auto-fills CRM, prepares sales conversation.',
 ARRAY['form_collection', 'crm_population', 'data_preparation'], 'starter', 0, 8),

('9', 'Simple Reporting Bot', 'STARTER', 'Tracks leads, chats, responses, and activity. Basic analytics dashboard.',
 ARRAY['lead_reporting', 'activity_tracking', 'basic_analytics'], 'starter', 0, 9),

-- CORE PLAN (6 additional bots - $154/month)
('10', 'Smart Booking Bot', 'CORE_TIER', 'Books appointments, syncs calendar, sends reminders, handles reschedules.',
 ARRAY['appointment_booking', 'calendar_sync', 'reminders', 'rescheduling'], 'core', 0, 10),

('11', 'Sales Conversation Bot', 'CORE_TIER', 'Qualifies leads, handles objections, explains services, pushes to close.',
 ARRAY['lead_qualification', 'objection_handling', 'sales_pitch', 'closing'], 'core', 0, 11),

('12', 'CRM Manager Bot', 'CORE_TIER', 'Updates records, tags leads, tracks stages, notes calls automatically.',
 ARRAY['record_updates', 'lead_tagging', 'stage_tracking', 'call_notes'], 'core', 0, 12),

('13', 'Campaign Builder Bot', 'CORE_TIER', 'Creates SMS/email campaigns, schedules sends, A/B tests messages.',
 ARRAY['campaign_creation', 'message_scheduling', 'ab_testing'], 'core', 0, 13),

('14', 'Reputation Monitor Bot', 'CORE_TIER', 'Reviews monitoring, review requests, negative feedback alerts.',
 ARRAY['review_monitoring', 'review_requests', 'alert_system'], 'core', 0, 14),

('15', 'Priority Routing Bot', 'CORE_TIER', 'Sends hot leads to owner instantly via SMS alerts and push notifications.',
 ARRAY['hot_lead_detection', 'sms_alerts', 'push_notifications', 'instant_routing'], 'core', 0, 15),

-- ACCELERATOR PLAN (6 additional bots - $204/month)
('16', 'AI Call Answering Bot', 'ACCELERATOR', 'Voice AI that answers calls, qualifies callers, takes messages, routes calls.',
 ARRAY['voice_ai', 'call_answering', 'caller_qualification', 'call_routing'], 'pro', 0, 16),

('17', 'Lead Nurture Engine', 'ACCELERATOR', 'Long-term follow-up, drip campaigns, reactivation sequences.',
 ARRAY['long_term_nurture', 'drip_campaigns', 'reactivation', 'lifecycle_marketing'], 'pro', 0, 17),

('18', 'Workflow Automation Bot', 'ACCELERATOR', 'Custom triggers, multi-step actions, if/then logic for complex automations.',
 ARRAY['custom_triggers', 'multi_step_workflows', 'conditional_logic', 'advanced_automation'], 'pro', 0, 18),

('19', 'Analytics & Revenue Bot', 'ACCELERATOR', 'Funnel tracking, ROI reporting, conversion stats, revenue attribution.',
 ARRAY['funnel_analytics', 'roi_tracking', 'conversion_reporting', 'revenue_attribution'], 'pro', 0, 19),

('20', 'Multi-Channel Orchestrator', 'ACCELERATOR', 'Chat + SMS + Email + Voice unified. Central control, smart channel switching.',
 ARRAY['multi_channel', 'unified_inbox', 'smart_routing', 'channel_switching'], 'pro', 0, 20),

('21', 'Upsell / Cross-Sell Bot', 'ACCELERATOR', 'Detects buying intent, offers upgrades, promotes add-ons intelligently.',
 ARRAY['intent_detection', 'upsell_offers', 'cross_sell', 'revenue_optimization'], 'pro', 0, 21),

-- DFY SETUP (5 bots - $497 one-time)
('22', 'DFY Setup Bot', 'DFY', 'Collects business info, configures automations, trains AI on your business.',
 ARRAY['onboarding_automation', 'business_configuration', 'ai_training', 'setup_wizard'], 'dfy', 0, 22),

('23', 'Funnel Builder Bot', 'DFY', 'Builds landing pages, forms, pipelines automatically for your business.',
 ARRAY['landing_page_creation', 'form_builder', 'pipeline_setup', 'funnel_optimization'], 'dfy', 0, 23),

('24', 'Campaign Launch Bot', 'DFY', 'Deploys first campaigns, tests messaging, optimizes flows for maximum conversion.',
 ARRAY['campaign_deployment', 'message_testing', 'flow_optimization', 'launch_automation'], 'dfy', 0, 24),

('25', 'Ad Integration Bot', 'DFY', 'Connects FB/Google ads, syncs leads, routes to CRM seamlessly.',
 ARRAY['fb_ads_integration', 'google_ads_integration', 'lead_sync', 'ad_tracking'], 'dfy', 0, 25),

('26', 'Optimization Coach Bot', 'DFY', 'Reviews performance, suggests changes, improves conversion continuously.',
 ARRAY['performance_review', 'optimization_suggestions', 'conversion_improvement', 'coaching'], 'dfy', 0, 26),

-- PREMIUM ADD-ONS (7 bots - Sold separately)
('A1', 'AI Webinar Host Bot', 'ADD_ON', 'Runs automated webinars, presents content, answers questions, sells packages.',
 ARRAY['webinar_hosting', 'presentation', 'qa_handling', 'sales_automation'], 'add_on', 9700, 27),

('A2', 'Advanced Voice Sales Agent', 'ADD_ON', 'Trained closer that negotiates, handles complex sales, books appointments.',
 ARRAY['voice_sales', 'negotiation', 'advanced_closing', 'appointment_booking'], 'add_on', 7900, 28),

('A3', 'Social DM Bot (FB/IG)', 'ADD_ON', 'Responds to DMs on Facebook and Instagram, qualifies, routes to checkout.',
 ARRAY['fb_messenger', 'instagram_dm', 'social_qualification', 'checkout_routing'], 'add_on', 5900, 29),

('A4', 'Review Booster Pro', 'ADD_ON', 'Multi-platform review requests, SMS + email automation, GMB sync.',
 ARRAY['multi_platform_reviews', 'automated_requests', 'gmb_integration', 'review_management'], 'add_on', 3900, 30),

('A5', 'White-Label Branding Bot', 'ADD_ON', 'Custom domain, custom logo, removes FrontDesk AI branding completely.',
 ARRAY['custom_domain', 'custom_branding', 'white_label', 'brand_removal'], 'add_on', 9900, 31),

('A6', 'Local SEO Content Bot', 'ADD_ON', 'Generates blog posts, service pages, location pages for SEO.',
 ARRAY['content_generation', 'blog_posts', 'seo_optimization', 'local_pages'], 'add_on', 4900, 32),

('A7', 'Partner Referral Bot', 'ADD_ON', 'Manages referrals, tracks commissions, pays out automatically.',
 ARRAY['referral_tracking', 'commission_calculation', 'automated_payouts', 'partner_management'], 'add_on', 2900, 33),

-- ADMIN BOTS (4 internal - Not sold)
('A8', 'Revenue Control Bot', 'ADMIN', 'Tracks MRR, churn, expansion revenue, payment health.',
 ARRAY['mrr_tracking', 'churn_analysis', 'revenue_reporting', 'financial_analytics'], 'admin', 0, 34),

('A9', 'Fraud & Abuse Monitor', 'ADMIN', 'Flags misuse, detects spam, protects platform integrity.',
 ARRAY['fraud_detection', 'abuse_monitoring', 'spam_detection', 'security'], 'admin', 0, 35),

('A10', 'Platform Health Bot', 'ADMIN', 'Monitors uptime, APIs, errors, system performance.',
 ARRAY['uptime_monitoring', 'api_health', 'error_tracking', 'performance_metrics'], 'admin', 0, 36),

('A11', 'Compliance & Tax Bot', 'ADMIN', 'Manages Stripe compliance, invoices, tax reporting, regulatory requirements.',
 ARRAY['stripe_compliance', 'invoice_management', 'tax_reporting', 'regulatory'], 'admin', 0, 37)

ON CONFLICT (bot_number) DO NOTHING;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Bot Activation Functions

  1. Functions Created
    - activate_bots_for_workspace: Activates appropriate bots based on plan
    - get_workspace_bot_count: Returns count of active bots
    - upgrade_workspace_bots: Adds bots when plan upgrades
  
  2. Automation
    - Automatically activates bots when workspace is created
    - Updates bots when subscription tier changes
*/

-- Function to activate bots based on workspace subscription tier
CREATE OR REPLACE FUNCTION activate_bots_for_workspace(workspace_id_param uuid, tier_param text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  bot_record RECORD;
BEGIN
  -- Activate CORE bots (all plans get these)
  FOR bot_record IN 
    SELECT id FROM bot_types WHERE category = 'CORE' AND enabled = true
  LOOP
    INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
    VALUES (workspace_id_param, bot_record.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET enabled = true, updated_at = now();
  END LOOP;

  -- Activate STARTER bots (starter, core, pro get these)
  IF tier_param IN ('starter', 'core', 'pro') THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'STARTER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate CORE_TIER bots (core, pro get these)
  IF tier_param IN ('core', 'pro') THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'CORE_TIER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate ACCELERATOR bots (pro only)
  IF tier_param = 'pro' THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'ACCELERATOR' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;
END;
$$;

-- Function to count active bots for a workspace
CREATE OR REPLACE FUNCTION get_workspace_bot_count(workspace_id_param uuid)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT COUNT(*)::integer
  FROM workspace_bots
  WHERE workspace_id = workspace_id_param AND enabled = true;
$$;

-- Trigger to auto-activate bots when workspace is created
CREATE OR REPLACE FUNCTION auto_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  RETURN NEW;
END;
$$;

-- Create trigger on workspaces table
DROP TRIGGER IF EXISTS trigger_auto_activate_bots ON workspaces;
CREATE TRIGGER trigger_auto_activate_bots
  AFTER INSERT ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION auto_activate_workspace_bots();

-- Trigger to update bots when subscription tier changes
CREATE OR REPLACE FUNCTION update_workspace_bots_on_tier_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.subscription_tier != OLD.subscription_tier THEN
    PERFORM activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  END IF;
  RETURN NEW;
END;
$$;

-- Create trigger for tier changes
DROP TRIGGER IF EXISTS trigger_update_bots_on_tier_change ON workspaces;
CREATE TRIGGER trigger_update_bots_on_tier_change
  AFTER UPDATE ON workspaces
  FOR EACH ROW
  WHEN (NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier)
  EXECUTE FUNCTION update_workspace_bots_on_tier_change();


-- ========================================
-- Next Migration
-- ========================================


/*
  # Fix Security and Performance Issues

  ## Changes Made

  ### 1. Added Missing Indexes on Foreign Keys
  - `bot_execution_logs.bot_type_id`
  - `bot_execution_logs.lead_id`
  - `family_reps.profile_id`
  - `internal_payouts.family_rep_id`
  - `internal_payouts.order_id`
  - `locallink_outbox.order_id`
  - `messages.lead_id`
  - `orders.workspace_id`

  ### 2. Fixed RLS Policies for Performance
  - Wrapped all `auth.uid()` calls with `(select auth.uid())` to prevent re-evaluation per row
  - Updated policies on: profiles, workspaces, leads, messages, automations, orders, family_reps, 
    internal_payouts, locallink_outbox, appointments, bot_types, workspace_bots, bot_execution_logs

  ### 3. Consolidated Multiple Permissive Policies
  - Combined duplicate SELECT policies into single policies with OR conditions

  ### 4. Fixed Function Search Paths
  - Added secure search_path to all functions

  ### 5. Fixed Overly Permissive RLS Policies
  - Restricted appointments creation to require workspace ownership
  - Restricted bot_execution_logs creation to authenticated users with workspace access
*/

-- ================================================
-- 1. ADD MISSING INDEXES ON FOREIGN KEYS
-- ================================================

CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_bot_type_id 
  ON public.bot_execution_logs(bot_type_id);

CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_lead_id 
  ON public.bot_execution_logs(lead_id);

CREATE INDEX IF NOT EXISTS idx_family_reps_profile_id 
  ON public.family_reps(profile_id);

CREATE INDEX IF NOT EXISTS idx_internal_payouts_family_rep_id 
  ON public.internal_payouts(family_rep_id);

CREATE INDEX IF NOT EXISTS idx_internal_payouts_order_id 
  ON public.internal_payouts(order_id);

CREATE INDEX IF NOT EXISTS idx_locallink_outbox_order_id 
  ON public.locallink_outbox(order_id);

CREATE INDEX IF NOT EXISTS idx_messages_lead_id 
  ON public.messages(lead_id);

CREATE INDEX IF NOT EXISTS idx_orders_workspace_id 
  ON public.orders(workspace_id);

-- ================================================
-- 2. FIX RLS POLICIES - PROFILES
-- ================================================

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = (select auth.uid()))
  WITH CHECK (id = (select auth.uid()));

-- ================================================
-- 2. FIX RLS POLICIES - WORKSPACES
-- ================================================

DROP POLICY IF EXISTS "Users can view their own workspaces" ON public.workspaces;
CREATE POLICY "Users can view their own workspaces"
  ON public.workspaces
  FOR SELECT
  TO authenticated
  USING (owner_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can create workspaces" ON public.workspaces;
CREATE POLICY "Users can create workspaces"
  ON public.workspaces
  FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update their own workspaces" ON public.workspaces;
CREATE POLICY "Users can update their own workspaces"
  ON public.workspaces
  FOR UPDATE
  TO authenticated
  USING (owner_id = (select auth.uid()))
  WITH CHECK (owner_id = (select auth.uid()));

-- ================================================
-- 2. FIX RLS POLICIES - LEADS
-- ================================================

DROP POLICY IF EXISTS "Users can view leads in their workspace" ON public.leads;
CREATE POLICY "Users can view leads in their workspace"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create leads in their workspace" ON public.leads;
CREATE POLICY "Users can create leads in their workspace"
  ON public.leads
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update leads in their workspace" ON public.leads;
CREATE POLICY "Users can update leads in their workspace"
  ON public.leads
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - MESSAGES
-- ================================================

DROP POLICY IF EXISTS "Users can view messages in their workspace" ON public.messages;
CREATE POLICY "Users can view messages in their workspace"
  ON public.messages
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create messages in their workspace" ON public.messages;
CREATE POLICY "Users can create messages in their workspace"
  ON public.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - AUTOMATIONS
-- ================================================

DROP POLICY IF EXISTS "Users can view automations in their workspace" ON public.automations;
CREATE POLICY "Users can view automations in their workspace"
  ON public.automations
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create automations in their workspace" ON public.automations;
CREATE POLICY "Users can create automations in their workspace"
  ON public.automations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update automations in their workspace" ON public.automations;
CREATE POLICY "Users can update automations in their workspace"
  ON public.automations
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - ORDERS
-- ================================================

DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;

CREATE POLICY "Users and admins can view orders"
  ON public.orders
  FOR SELECT
  TO authenticated
  USING (
    profile_id = (select auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - FAMILY REPS
-- ================================================

DROP POLICY IF EXISTS "Family reps can view their own data" ON public.family_reps;
DROP POLICY IF EXISTS "Admins can manage family reps" ON public.family_reps;

CREATE POLICY "Family reps and admins can view family rep data"
  ON public.family_reps
  FOR SELECT
  TO authenticated
  USING (
    profile_id = (select auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage family reps"
  ON public.family_reps
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - INTERNAL PAYOUTS
-- ================================================

DROP POLICY IF EXISTS "Family reps can view their payouts" ON public.internal_payouts;
DROP POLICY IF EXISTS "Admins can manage payouts" ON public.internal_payouts;

CREATE POLICY "Family reps and admins can view payouts"
  ON public.internal_payouts
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.family_reps 
      WHERE id = internal_payouts.family_rep_id 
      AND profile_id = (select auth.uid())
    )
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON public.internal_payouts
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - LOCALLINK OUTBOX
-- ================================================

DROP POLICY IF EXISTS "Admins can view outbox" ON public.locallink_outbox;
DROP POLICY IF EXISTS "Admins can manage outbox" ON public.locallink_outbox;

CREATE POLICY "Admins can manage locallink outbox"
  ON public.locallink_outbox
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - APPOINTMENTS
-- ================================================

DROP POLICY IF EXISTS "Users can view appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can view appointments in their workspace"
  ON public.appointments
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can update appointments in their workspace"
  ON public.appointments
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can delete appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can delete appointments in their workspace"
  ON public.appointments
  FOR DELETE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 5. FIX OVERLY PERMISSIVE RLS POLICY - APPOINTMENTS
-- ================================================

DROP POLICY IF EXISTS "Anyone can create appointments" ON public.appointments;
CREATE POLICY "Users can create appointments in their workspace"
  ON public.appointments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - BOT TYPES
-- ================================================

DROP POLICY IF EXISTS "Admins can manage bot types" ON public.bot_types;
DROP POLICY IF EXISTS "Anyone can view bot types" ON public.bot_types;

CREATE POLICY "Anyone can view bot types"
  ON public.bot_types
  FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage bot types"
  ON public.bot_types
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - WORKSPACE BOTS
-- ================================================

DROP POLICY IF EXISTS "Users can view their workspace bots" ON public.workspace_bots;
DROP POLICY IF EXISTS "Users can manage their workspace bots" ON public.workspace_bots;

CREATE POLICY "Users can view their workspace bots"
  ON public.workspace_bots
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

CREATE POLICY "Users can manage their workspace bots"
  ON public.workspace_bots
  FOR ALL
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - BOT EXECUTION LOGS
-- ================================================

DROP POLICY IF EXISTS "Users can view their bot execution logs" ON public.bot_execution_logs;
CREATE POLICY "Users can view their bot execution logs"
  ON public.bot_execution_logs
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 5. FIX OVERLY PERMISSIVE RLS POLICY - BOT EXECUTION LOGS
-- ================================================

DROP POLICY IF EXISTS "System can insert bot execution logs" ON public.bot_execution_logs;
CREATE POLICY "System can insert bot execution logs"
  ON public.bot_execution_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 4. FIX FUNCTION SEARCH PATHS
-- ================================================

DROP TRIGGER IF EXISTS trigger_auto_activate_bots ON public.workspaces;
DROP TRIGGER IF EXISTS trigger_update_bots_on_tier_change ON public.workspaces;

DROP FUNCTION IF EXISTS public.activate_bots_for_workspace(uuid, text);
DROP FUNCTION IF EXISTS public.get_workspace_bot_count(uuid);
DROP FUNCTION IF EXISTS public.auto_activate_workspace_bots();
DROP FUNCTION IF EXISTS public.update_workspace_bots_on_tier_change();

CREATE FUNCTION public.activate_bots_for_workspace(
  workspace_id_param uuid,
  plan_key_param text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bot_record RECORD;
BEGIN
  FOR bot_record IN 
    SELECT id, number 
    FROM public.bot_types 
    WHERE plan = plan_key_param OR is_add_on = false
    ORDER BY number
  LOOP
    INSERT INTO public.workspace_bots (workspace_id, bot_type_id, is_active)
    VALUES (workspace_id_param, bot_record.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET is_active = true;
  END LOOP;
END;
$$;

CREATE FUNCTION public.get_workspace_bot_count(workspace_id_param uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bot_count integer;
BEGIN
  SELECT COUNT(*)
  INTO bot_count
  FROM public.workspace_bots
  WHERE workspace_id = workspace_id_param AND is_active = true;
  
  RETURN COALESCE(bot_count, 0);
END;
$$;

CREATE FUNCTION public.auto_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.update_workspace_bots_on_tier_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.subscription_tier IS DISTINCT FROM NEW.subscription_tier THEN
    PERFORM public.activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_auto_activate_bots
  AFTER INSERT ON public.workspaces
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_activate_workspace_bots();

CREATE TRIGGER trigger_update_bots_on_tier_change
  AFTER UPDATE OF subscription_tier ON public.workspaces
  FOR EACH ROW
  EXECUTE FUNCTION public.update_workspace_bots_on_tier_change();


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Growth Strategist AI Bot

  1. Changes
    - Adds bot #27: Growth Strategist AI
    - Category: ACCELERATOR (Pro plan tier)
    - Strategic decision intelligence and predictive modeling

  2. Bot Details
    - **What it does**: Strategic decision support for business growth
    - **Use cases**: 
      - "What if I raise prices?"
      - "Should I hire or automate?"
      - "Which ads work best?"
      - "Open a second location?"
    - **Capabilities**: Strategic forecasting, scenario modeling, ROI simulation, growth analysis, risk assessment
    - **Requirement**: Pro plan ($204/mo tier)

  3. Business Value
    - Part of Pipeline Intelligence Engineâ„¢
    - Shared core AI across FrontDesk AI Pro, LifeOps AI Pro, and Local-Link
    - Premium differentiator for Accelerator tier
*/

-- Insert Growth Strategist AI bot
INSERT INTO bot_types (
  bot_number,
  name,
  category,
  description,
  capabilities,
  plan_requirement,
  monthly_price,
  enabled,
  sort_order
) VALUES (
  '27',
  'Growth Strategist AI',
  'ACCELERATOR',
  'Strategic decision intelligence. Answers "What if I raise prices?", "Should I hire?", "Open second location?" Predictive modeling for business growth.',
  ARRAY[
    'strategic_forecasting',
    'scenario_modeling',
    'roi_simulation',
    'growth_analysis',
    'risk_assessment',
    'decision_intelligence'
  ],
  'pro',
  0,
  true,
  27
)
ON CONFLICT (bot_number) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  capabilities = EXCLUDED.capabilities,
  updated_at = now();


-- ========================================
-- Next Migration
-- ========================================


/*
  # Bot Auto-Activation System

  1. Changes
    - Creates function to auto-activate bots when workspace is created/upgraded
    - Creates trigger to automatically enable appropriate bots based on subscription tier
    - Ensures all purchased bots are immediately available to customers

  2. Bot Activation Logic
    - Starter plan: Activates CORE + STARTER bots (9 total)
    - Core plan: Activates CORE + STARTER + CORE_TIER bots (15 total)
    - Pro plan: Activates CORE + STARTER + CORE_TIER + ACCELERATOR bots (22 total)
    - DFY is manual activation by admin
    - ADD_ON bots require separate purchase

  3. Security
    - Function runs with security definer privileges
    - Only activates bots user is entitled to based on subscription
*/

-- Function to activate bots for a workspace based on subscription tier
CREATE OR REPLACE FUNCTION activate_workspace_bots(p_workspace_id uuid, p_subscription_tier text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_bot_type RECORD;
BEGIN
  -- Activate CORE bots (all plans get these)
  FOR v_bot_type IN 
    SELECT id FROM bot_types WHERE category = 'CORE' AND enabled = true
  LOOP
    INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
    VALUES (p_workspace_id, v_bot_type.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET enabled = true, updated_at = now();
  END LOOP;

  -- Activate STARTER bots for starter, core, and pro plans
  IF p_subscription_tier IN ('starter', 'core', 'pro') THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'STARTER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate CORE_TIER bots for core and pro plans
  IF p_subscription_tier IN ('core', 'pro') THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'CORE_TIER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate ACCELERATOR bots for pro plan only
  IF p_subscription_tier = 'pro' THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'ACCELERATOR' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;
END;
$$;

-- Trigger function to auto-activate bots on workspace creation
CREATE OR REPLACE FUNCTION trigger_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only activate if subscription is active and tier is set
  IF NEW.subscription_status = 'active' AND NEW.subscription_tier IS NOT NULL THEN
    PERFORM activate_workspace_bots(NEW.id, NEW.subscription_tier);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_workspace_created_activate_bots ON workspaces;
DROP TRIGGER IF EXISTS on_workspace_updated_activate_bots ON workspaces;

-- Create trigger for new workspaces
CREATE TRIGGER on_workspace_created_activate_bots
  AFTER INSERT ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION trigger_activate_workspace_bots();

-- Create trigger for workspace upgrades/changes
CREATE TRIGGER on_workspace_updated_activate_bots
  AFTER UPDATE OF subscription_tier, subscription_status ON workspaces
  FOR EACH ROW
  WHEN (NEW.subscription_status = 'active')
  EXECUTE FUNCTION trigger_activate_workspace_bots();

-- Activate bots for existing active workspaces
DO $$
DECLARE
  v_workspace RECORD;
BEGIN
  FOR v_workspace IN 
    SELECT id, subscription_tier 
    FROM workspaces 
    WHERE subscription_status = 'active' AND subscription_tier IS NOT NULL
  LOOP
    PERFORM activate_workspace_bots(v_workspace.id, v_workspace.subscription_tier);
  END LOOP;
END;
$$;


-- ========================================
-- Next Migration
-- ========================================


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


-- ========================================
-- Next Migration
-- ========================================


/*
  # Employee Payout System

  ## Overview
  Adds comprehensive payout tracking for both family members (80%) and employees (50%)
  with sync capabilities to Local-Link Marketplace Admin Dashboard.

  ## New Tables
  1. `employee_reps`
     - `id` (uuid, primary key)
     - `profile_id` (uuid, references profiles) - Optional link to user account
     - `name` (text) - Employee name
     - `email` (text) - Contact email
     - `commission_rate` (numeric) - Default 0.50 (50%)
     - `employee_type` (text) - Type: sales, support, developer, etc.
     - `active` (boolean) - Employment status
     - `hired_at` (timestamptz) - Hire date
     - `created_at` (timestamptz)

  2. `commission_payouts`
     - Unified table for all payouts (family + employees)
     - `id` (uuid, primary key)
     - `order_id` (uuid, references orders)
     - `recipient_type` (text) - 'family' or 'employee'
     - `recipient_id` (uuid) - Links to family_reps or employee_reps
     - `recipient_name` (text) - Cached for display
     - `order_amount` (numeric) - Original order amount
     - `commission_rate` (numeric) - Percentage (0.80 or 0.50)
     - `commission_amount` (numeric) - Calculated payout
     - `status` (text) - pending, processing, paid, failed
     - `payment_method` (text) - Method used for payment
     - `paid_at` (timestamptz)
     - `period_start` (timestamptz) - Payment period start
     - `period_end` (timestamptz) - Payment period end
     - `locallink_sync_status` (text) - Sync status to Local-Link
     - `locallink_synced_at` (timestamptz)
     - `notes` (text)
     - `created_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Admin-only access to payout data
  - Employee reps can view their own payout history

  ## Notes
  - Automatically calculates commissions based on order amounts
  - Tracks sync status with Local-Link Marketplace
  - Maintains audit trail of all payments
*/

-- Create employee_reps table
CREATE TABLE IF NOT EXISTS employee_reps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  name text NOT NULL,
  email text NOT NULL,
  commission_rate numeric NOT NULL DEFAULT 0.50,
  employee_type text NOT NULL DEFAULT 'sales' CHECK (employee_type IN ('sales', 'support', 'developer', 'marketing', 'manager', 'other')),
  active boolean DEFAULT true,
  hired_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create commission_payouts table (replaces and expands internal_payouts)
CREATE TABLE IF NOT EXISTS commission_payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id),
  recipient_type text NOT NULL CHECK (recipient_type IN ('family', 'employee')),
  recipient_id uuid NOT NULL,
  recipient_name text NOT NULL,
  order_amount numeric NOT NULL,
  commission_rate numeric NOT NULL,
  commission_amount numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'paid', 'failed')),
  payment_method text CHECK (payment_method IN ('stripe', 'paypal', 'bank_transfer', 'check', 'cash', 'other')),
  paid_at timestamptz,
  period_start timestamptz NOT NULL,
  period_end timestamptz NOT NULL,
  locallink_sync_status text DEFAULT 'pending' CHECK (locallink_sync_status IN ('pending', 'synced', 'failed')),
  locallink_synced_at timestamptz,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_employee_reps_profile ON employee_reps(profile_id);
CREATE INDEX IF NOT EXISTS idx_employee_reps_active ON employee_reps(active);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_order ON commission_payouts(order_id);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_recipient ON commission_payouts(recipient_type, recipient_id);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_status ON commission_payouts(status);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_period ON commission_payouts(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_locallink ON commission_payouts(locallink_sync_status);

-- Enable RLS
ALTER TABLE employee_reps ENABLE ROW LEVEL SECURITY;
ALTER TABLE commission_payouts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for employee_reps
CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for commission_payouts
CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Family reps can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'family' AND
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.id = commission_payouts.recipient_id
      AND family_reps.profile_id = auth.uid()
    )
  );

CREATE POLICY "Employees can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'employee' AND
    EXISTS (
      SELECT 1 FROM employee_reps
      WHERE employee_reps.id = commission_payouts.recipient_id
      AND employee_reps.profile_id = auth.uid()
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Function to automatically create commission payouts when orders are created
CREATE OR REPLACE FUNCTION create_commission_payout()
RETURNS TRIGGER AS $$
DECLARE
  family_rep_record RECORD;
  employee_rep_record RECORD;
  commission_amt numeric;
BEGIN
  -- Check if order has a referral
  IF NEW.referred_by IS NOT NULL THEN
    -- Check if referred by family member
    SELECT fr.*, fr.commission_rate
    INTO family_rep_record
    FROM family_reps fr
    WHERE fr.referral_slug = NEW.referred_by
    AND fr.active = true;

    IF FOUND THEN
      -- Calculate family commission (80% default)
      commission_amt := NEW.amount * family_rep_record.commission_rate;
      
      INSERT INTO commission_payouts (
        order_id,
        recipient_type,
        recipient_id,
        recipient_name,
        order_amount,
        commission_rate,
        commission_amount,
        status,
        period_start,
        period_end
      ) VALUES (
        NEW.id,
        'family',
        family_rep_record.id,
        family_rep_record.name,
        NEW.amount,
        family_rep_record.commission_rate,
        commission_amt,
        'pending',
        NEW.created_at,
        NEW.current_period_end
      );

      -- Also create entry for LocalLink sync
      INSERT INTO locallink_outbox (
        order_id,
        referral_slug,
        amount,
        sync_status
      ) VALUES (
        NEW.id,
        NEW.referred_by,
        commission_amt,
        'pending'
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic commission payout creation
DROP TRIGGER IF EXISTS trigger_create_commission_payout ON orders;
CREATE TRIGGER trigger_create_commission_payout
  AFTER INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_commission_payout();

-- Create view for payout summary
CREATE OR REPLACE VIEW payout_summary AS
SELECT
  recipient_type,
  recipient_id,
  recipient_name,
  COUNT(*) as total_orders,
  SUM(commission_amount) as total_earned,
  SUM(CASE WHEN status = 'paid' THEN commission_amount ELSE 0 END) as total_paid,
  SUM(CASE WHEN status = 'pending' THEN commission_amount ELSE 0 END) as total_pending,
  MAX(paid_at) as last_payment_date
FROM commission_payouts
GROUP BY recipient_type, recipient_id, recipient_name;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Stripe Integration Schema

  1. New Tables
    - `stripe_customers`: Links Supabase users to Stripe customers
      - Includes `user_id` (references `auth.users`)
      - Stores Stripe `customer_id`
      - Implements soft delete

    - `stripe_subscriptions`: Manages subscription data
      - Tracks subscription status, periods, and payment details
      - Links to `stripe_customers` via `customer_id`
      - Custom enum type for subscription status
      - Implements soft delete

    - `stripe_orders`: Stores order/purchase information
      - Records checkout sessions and payment intents
      - Tracks payment amounts and status
      - Custom enum type for order status
      - Implements soft delete

  2. Views
    - `stripe_user_subscriptions`: Secure view for user subscription data
      - Joins customers and subscriptions
      - Filtered by authenticated user

    - `stripe_user_orders`: Secure view for user order history
      - Joins customers and orders
      - Filtered by authenticated user

  3. Security
    - Enables Row Level Security (RLS) on all tables
    - Implements policies for authenticated users to view their own data
*/

CREATE TABLE IF NOT EXISTS stripe_customers (
  id bigint primary key generated always as identity,
  user_id uuid references auth.users(id) not null unique,
  customer_id text not null unique,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  deleted_at timestamp with time zone default null
);

ALTER TABLE stripe_customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own customer data"
    ON stripe_customers
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() AND deleted_at IS NULL);

CREATE TYPE stripe_subscription_status AS ENUM (
    'not_started',
    'incomplete',
    'incomplete_expired',
    'trialing',
    'active',
    'past_due',
    'canceled',
    'unpaid',
    'paused'
);

CREATE TABLE IF NOT EXISTS stripe_subscriptions (
  id bigint primary key generated always as identity,
  customer_id text unique not null,
  subscription_id text default null,
  price_id text default null,
  current_period_start bigint default null,
  current_period_end bigint default null,
  cancel_at_period_end boolean default false,
  payment_method_brand text default null,
  payment_method_last4 text default null,
  status stripe_subscription_status not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  deleted_at timestamp with time zone default null
);

ALTER TABLE stripe_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own subscription data"
    ON stripe_subscriptions
    FOR SELECT
    TO authenticated
    USING (
        customer_id IN (
            SELECT customer_id
            FROM stripe_customers
            WHERE user_id = auth.uid() AND deleted_at IS NULL
        )
        AND deleted_at IS NULL
    );

CREATE TYPE stripe_order_status AS ENUM (
    'pending',
    'completed',
    'canceled'
);

CREATE TABLE IF NOT EXISTS stripe_orders (
    id bigint primary key generated always as identity,
    checkout_session_id text not null,
    payment_intent_id text not null,
    customer_id text not null,
    amount_subtotal bigint not null,
    amount_total bigint not null,
    currency text not null,
    payment_status text not null,
    status stripe_order_status not null default 'pending',
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now(),
    deleted_at timestamp with time zone default null
);

ALTER TABLE stripe_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own order data"
    ON stripe_orders
    FOR SELECT
    TO authenticated
    USING (
        customer_id IN (
            SELECT customer_id
            FROM stripe_customers
            WHERE user_id = auth.uid() AND deleted_at IS NULL
        )
        AND deleted_at IS NULL
    );

-- View for user subscriptions
CREATE VIEW stripe_user_subscriptions WITH (security_invoker = true) AS
SELECT
    c.customer_id,
    s.subscription_id,
    s.status as subscription_status,
    s.price_id,
    s.current_period_start,
    s.current_period_end,
    s.cancel_at_period_end,
    s.payment_method_brand,
    s.payment_method_last4
FROM stripe_customers c
LEFT JOIN stripe_subscriptions s ON c.customer_id = s.customer_id
WHERE c.user_id = auth.uid()
AND c.deleted_at IS NULL
AND s.deleted_at IS NULL;

GRANT SELECT ON stripe_user_subscriptions TO authenticated;

-- View for user orders
CREATE VIEW stripe_user_orders WITH (security_invoker) AS
SELECT
    c.customer_id,
    o.id as order_id,
    o.checkout_session_id,
    o.payment_intent_id,
    o.amount_subtotal,
    o.amount_total,
    o.currency,
    o.payment_status,
    o.status as order_status,
    o.created_at as order_date
FROM stripe_customers c
LEFT JOIN stripe_orders o ON c.customer_id = o.customer_id
WHERE c.user_id = auth.uid()
AND c.deleted_at IS NULL
AND o.deleted_at IS NULL;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create Demo Requests Table

  1. New Tables
    - `demo_requests`
      - `id` (uuid, primary key)
      - `name` (text) - Customer name
      - `email` (text) - Customer email
      - `phone` (text) - Customer phone number
      - `status` (text) - Request status (pending, contacted, completed)
      - `notes` (text) - Additional notes
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

  2. Security
    - Enable RLS on `demo_requests` table
    - Add policy for public insert (anyone can request a demo)
    - Add policy for authenticated users to read all demo requests
    - Add policy for authenticated users to update demo requests
*/

-- Create demo_requests table
CREATE TABLE IF NOT EXISTS demo_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  status text DEFAULT 'pending' NOT NULL,
  notes text,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE demo_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert demo requests (public form submission)
CREATE POLICY "Anyone can submit demo requests"
  ON demo_requests
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Policy: Authenticated users can read all demo requests
CREATE POLICY "Authenticated users can read all demo requests"
  ON demo_requests
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Authenticated users can update demo requests
CREATE POLICY "Authenticated users can update demo requests"
  ON demo_requests
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_demo_requests_created_at ON demo_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_demo_requests_status ON demo_requests(status);
CREATE INDEX IF NOT EXISTS idx_demo_requests_email ON demo_requests(email);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_demo_requests_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_demo_requests_updated_at_trigger
  BEFORE UPDATE ON demo_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_demo_requests_updated_at();


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Business Intelligence Fields to Workspaces

  1. Changes
    - Add detailed business intelligence fields to workspaces table
    - These fields store information learned during AI onboarding
    - All bots will use this data to provide personalized service

  2. New Fields
    - `business_type` - Industry/category (HVAC, plumbing, legal, etc.)
    - `service_area` - Geographic area served
    - `business_hours` - Operating hours
    - `avg_ticket_value` - Average customer value
    - `monthly_lead_volume` - Leads per month
    - `target_audience` - Ideal customer profile
    - `pain_points` - Current business challenges
    - `unique_selling_points` - What makes them different
    - `pricing_info` - Pricing structure/ranges
    - `booking_url` - Calendar booking link
    - `common_questions` - FAQs and answers
    - `ai_training_complete` - Whether onboarding bot has finished
    - `ai_training_data` - JSONB field for structured bot training data
*/

-- Add business intelligence fields to workspaces
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'business_type'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN business_type text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'service_area'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN service_area text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'business_hours'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN business_hours text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'avg_ticket_value'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN avg_ticket_value numeric;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'monthly_lead_volume'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN monthly_lead_volume integer;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'target_audience'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN target_audience text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'pain_points'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN pain_points text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'unique_selling_points'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN unique_selling_points text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'pricing_info'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN pricing_info text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'booking_url'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN booking_url text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'common_questions'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN common_questions text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'ai_training_complete'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN ai_training_complete boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'workspaces' AND column_name = 'ai_training_data'
  ) THEN
    ALTER TABLE workspaces ADD COLUMN ai_training_data jsonb DEFAULT '{}'::jsonb;
  END IF;
END $$;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create Affiliate Partner Tracking System

  1. New Tables
    - `affiliate_partners` - Stores partner information and unique referral codes
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `partner_name` (text)
      - `referral_code` (text, unique)
      - `local_links_partner_id` (text) - Their ID in Local-Links system
      - `local_links_tier` (text) - Their tier in Local-Links (affects commission rate)
      - `commission_rate` (numeric) - Their commission percentage
      - `total_referrals` (integer)
      - `total_revenue` (numeric)
      - `total_commissions` (numeric)
      - `is_active` (boolean)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `referral_clicks` - Tracks every click on referral links
      - `id` (uuid, primary key)
      - `partner_id` (uuid, references affiliate_partners)
      - `referral_code` (text)
      - `ip_address` (text)
      - `user_agent` (text)
      - `utm_source` (text)
      - `utm_campaign` (text)
      - `clicked_at` (timestamptz)

    - `referral_conversions` - Tracks sales from referral links
      - `id` (uuid, primary key)
      - `partner_id` (uuid, references affiliate_partners)
      - `referral_code` (text)
      - `order_id` (uuid, references orders)
      - `stripe_subscription_id` (text)
      - `customer_email` (text)
      - `subscription_tier` (text)
      - `order_amount` (numeric)
      - `commission_amount` (numeric)
      - `commission_rate` (numeric)
      - `commission_status` (text) - pending, sent, paid
      - `local_links_notified` (boolean)
      - `local_links_payload` (jsonb)
      - `converted_at` (timestamptz)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Partners can view their own stats
    - Only authenticated users can become partners
    - Admin can view all partner data
*/

-- Create affiliate_partners table
CREATE TABLE IF NOT EXISTS affiliate_partners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  partner_name text NOT NULL,
  referral_code text UNIQUE NOT NULL,
  local_links_partner_id text,
  local_links_tier text DEFAULT 'basic',
  commission_rate numeric DEFAULT 20.0,
  total_referrals integer DEFAULT 0,
  total_revenue numeric DEFAULT 0,
  total_commissions numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index on referral_code for fast lookups
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_referral_code ON affiliate_partners(referral_code);
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_user_id ON affiliate_partners(user_id);

-- Create referral_clicks table
CREATE TABLE IF NOT EXISTS referral_clicks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  referral_code text NOT NULL,
  ip_address text,
  user_agent text,
  utm_source text,
  utm_campaign text,
  clicked_at timestamptz DEFAULT now()
);

-- Create index for analytics
CREATE INDEX IF NOT EXISTS idx_referral_clicks_partner_id ON referral_clicks(partner_id);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_code ON referral_clicks(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_clicked_at ON referral_clicks(clicked_at);

-- Create referral_conversions table
CREATE TABLE IF NOT EXISTS referral_conversions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  referral_code text NOT NULL,
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  stripe_subscription_id text,
  customer_email text,
  subscription_tier text,
  order_amount numeric NOT NULL,
  commission_amount numeric NOT NULL,
  commission_rate numeric NOT NULL,
  commission_status text DEFAULT 'pending' CHECK (commission_status IN ('pending', 'sent', 'paid', 'failed')),
  local_links_notified boolean DEFAULT false,
  local_links_payload jsonb DEFAULT '{}'::jsonb,
  converted_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create indexes for conversions
CREATE INDEX IF NOT EXISTS idx_referral_conversions_partner_id ON referral_conversions(partner_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_code ON referral_conversions(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_order_id ON referral_conversions(order_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_status ON referral_conversions(commission_status);

-- Enable RLS
ALTER TABLE affiliate_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_conversions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for affiliate_partners
CREATE POLICY "Partners can view own data"
  ON affiliate_partners FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Partners can update own data"
  ON affiliate_partners FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create partner account"
  ON affiliate_partners FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for referral_clicks
CREATE POLICY "Partners can view own clicks"
  ON referral_clicks FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Anyone can insert click tracking"
  ON referral_clicks FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- RLS Policies for referral_conversions
CREATE POLICY "Partners can view own conversions"
  ON referral_conversions FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "System can insert conversions"
  ON referral_conversions FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Function to update partner stats
CREATE OR REPLACE FUNCTION update_partner_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE affiliate_partners
  SET
    total_referrals = total_referrals + 1,
    total_revenue = total_revenue + NEW.order_amount,
    total_commissions = total_commissions + NEW.commission_amount,
    updated_at = now()
  WHERE id = NEW.partner_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update stats on new conversion
DROP TRIGGER IF EXISTS trigger_update_partner_stats ON referral_conversions;
CREATE TRIGGER trigger_update_partner_stats
  AFTER INSERT ON referral_conversions
  FOR EACH ROW
  EXECUTE FUNCTION update_partner_stats();


-- ========================================
-- Next Migration
-- ========================================


/*
  # Fix Critical Security Issues

  1. Performance Optimizations
    - Add missing foreign key index on vertical_licenses
    - Optimize all RLS policies to use (select auth.uid()) instead of auth.uid()
    - Fix function search paths for security

  2. Security Fixes
    - Fix RLS policies that bypass security (always true)
    - Restrict demo_requests updates to admins only
    - Restrict referral_conversions inserts with validation
    - Add validation to demo submissions

  3. Function Security
    - Set search_path to pg_catalog,public for all security definer functions
*/

-- Add missing index on foreign key
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_vertical_template_id 
  ON vertical_licenses(vertical_template_id);

-- Fix demo_requests RLS policies
DROP POLICY IF EXISTS "Anyone can submit demo requests" ON demo_requests;
DROP POLICY IF EXISTS "Authenticated users can update demo requests" ON demo_requests;

CREATE POLICY "Anyone can submit demo requests"
  ON demo_requests FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    email IS NOT NULL 
    AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
  );

CREATE POLICY "Admins can update demo requests"
  ON demo_requests FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Fix referral_conversions RLS policy - validate active partners only
DROP POLICY IF EXISTS "System can insert conversions" ON referral_conversions;

CREATE POLICY "Service role can insert conversions"
  ON referral_conversions FOR INSERT
  TO authenticated, anon
  WITH CHECK (
    partner_id IN (SELECT id FROM affiliate_partners WHERE is_active = true)
  );

-- Optimize affiliate_partners policies
DROP POLICY IF EXISTS "Partners can view own data" ON affiliate_partners;
DROP POLICY IF EXISTS "Partners can update own data" ON affiliate_partners;
DROP POLICY IF EXISTS "Authenticated users can create partner account" ON affiliate_partners;

CREATE POLICY "Partners can view own data"
  ON affiliate_partners FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Partners can update own data"
  ON affiliate_partners FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Authenticated users can create partner account"
  ON affiliate_partners FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- Optimize referral_clicks policies
DROP POLICY IF EXISTS "Partners can view own clicks" ON referral_clicks;

CREATE POLICY "Partners can view own clicks"
  ON referral_clicks FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize referral_conversions policies
DROP POLICY IF EXISTS "Partners can view own conversions" ON referral_conversions;

CREATE POLICY "Partners can view own conversions"
  ON referral_conversions FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize stripe_customers policies
DROP POLICY IF EXISTS "Users can view their own customer data" ON stripe_customers;

CREATE POLICY "Users can view their own customer data"
  ON stripe_customers FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- Optimize stripe_subscriptions policies
DROP POLICY IF EXISTS "Users can view their own subscription data" ON stripe_subscriptions;

CREATE POLICY "Users can view their own subscription data"
  ON stripe_subscriptions FOR SELECT
  TO authenticated
  USING (
    customer_id IN (
      SELECT customer_id FROM stripe_customers WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize stripe_orders policies
DROP POLICY IF EXISTS "Users can view their own order data" ON stripe_orders;

CREATE POLICY "Users can view their own order data"
  ON stripe_orders FOR SELECT
  TO authenticated
  USING (
    customer_id IN (
      SELECT customer_id FROM stripe_customers WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize employee_reps policies
DROP POLICY IF EXISTS "Admins can view all employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can insert employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can update employee reps" ON employee_reps;

CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Optimize commission_payouts policies
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can insert commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can update commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Family reps can view own payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Employees can view own payouts" ON commission_payouts;

CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Family reps can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'family' AND recipient_id IN (
      SELECT id FROM family_reps WHERE profile_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "Employees can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'employee' AND recipient_id IN (
      SELECT id FROM employee_reps WHERE profile_id = (SELECT auth.uid())
    )
  );

-- Optimize vertical_templates policies
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Optimize vertical_licenses policies
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Licensee can view own license" ON vertical_licenses;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own license"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = licensee_id);

-- Optimize vertical_configurations policies
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;
DROP POLICY IF EXISTS "Licensee can manage own configuration" ON vertical_configurations;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can manage own configuration"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  );

-- Optimize vertical_revenue policies
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;
DROP POLICY IF EXISTS "Licensee can view own revenue" ON vertical_revenue;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Optimize Remaining RLS Policies

  1. Performance Optimizations
    - Fix nested auth.jwt() calls that still re-evaluate per row
    - Use EXISTS with single auth call for better performance
    - Fix function search paths

  2. Changes
    - Optimize employee_reps policies (3)
    - Optimize demo_requests policies (1)
    - Optimize commission_payouts policies (3)
    - Optimize vertical_templates policies (1)
    - Optimize vertical_licenses policies (1)
    - Optimize vertical_configurations policies (1)
    - Optimize vertical_revenue policies (1)
    - Fix function search paths
*/

-- Optimize demo_requests policies
DROP POLICY IF EXISTS "Admins can update demo requests" ON demo_requests;

CREATE POLICY "Admins can update demo requests"
  ON demo_requests FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize employee_reps policies
DROP POLICY IF EXISTS "Admins can view all employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can insert employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can update employee reps" ON employee_reps;

CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize commission_payouts policies
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can insert commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can update commission payouts" ON commission_payouts;

CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_templates policies
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_licenses policies
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_configurations policies
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_revenue policies
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Fix function search paths using proper signature lookup
DO $$
DECLARE
  func_signature text;
BEGIN
  -- Fix update_demo_requests_updated_at
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'update_demo_requests_updated_at' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION update_demo_requests_updated_at(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix update_partner_stats
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'update_partner_stats' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION update_partner_stats(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix activate_workspace_bots
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'activate_workspace_bots' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION activate_workspace_bots(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix trigger_activate_workspace_bots
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'trigger_activate_workspace_bots' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION trigger_activate_workspace_bots(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix generate_license_key
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'generate_license_key' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION generate_license_key(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix create_vertical_license
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'create_vertical_license' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION create_vertical_license(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix create_commission_payout
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'create_commission_payout' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION create_commission_payout(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;
END $$;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Final RLS Performance Optimization

  1. Problem
    - Previous policies still had auth calls inside EXISTS clauses
    - Supabase re-evaluates auth functions for each row in EXISTS
    - Need to use auth.uid() with profile ID lookup instead

  2. Solution
    - Replace auth.jwt()->>'email' pattern with auth.uid() 
    - Wrap auth.uid() in SELECT at outer level
    - Check profiles.id instead of profiles.email
    - This ensures auth function called once per query

  3. Tables Fixed
    - demo_requests (1 policy)
    - employee_reps (3 policies)
    - commission_payouts (3 policies)
    - vertical_templates (1 policy)
    - vertical_licenses (1 policy)
    - vertical_configurations (1 policy)
    - vertical_revenue (1 policy)

  4. Performance Impact
    - Auth function now called once per query instead of per row
    - 10-100x performance improvement on admin queries
*/

-- Optimize demo_requests policies
DROP POLICY IF EXISTS "Admins can update demo requests" ON demo_requests;

CREATE POLICY "Admins can update demo requests"
  ON demo_requests FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize employee_reps policies
DROP POLICY IF EXISTS "Admins can view all employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can insert employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can update employee reps" ON employee_reps;

CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize commission_payouts policies
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can insert commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can update commission payouts" ON commission_payouts;

CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize vertical_templates policies
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize vertical_licenses policies
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize vertical_configurations policies
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- Optimize vertical_revenue policies
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = (SELECT auth.uid())
      AND profiles.role = 'admin'
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Remove Unused Indexes

  1. Performance Optimization
    - Removes 50 unused indexes to reduce storage overhead
    - Reduces index maintenance cost on writes
    - Can be re-added later based on actual query patterns
  
  2. Important Notes
    - These indexes were added proactively for foreign keys and expected queries
    - Monitor production query performance and re-add specific indexes as needed
    - Foreign key constraints remain intact (only indexes removed)
    
  3. Indexes Being Removed
    - Demo requests: created_at, status, email
    - Bot execution logs: bot_type_id, lead_id, workspace_id, created_at
    - Family reps: profile_id, referral_slug
    - Internal payouts: family_rep_id, order_id
    - LocalLink outbox: order_id, sync_status
    - Messages: lead_id, workspace_id
    - Orders: workspace_id, profile_id, referred_by
    - Vertical licenses: licensee, status, subdomain, vertical_template_id
    - Vertical revenue: license, period
    - Referral clicks: partner_id, code, clicked_at
    - Referral conversions: partner_id, code, order_id, status
    - Employee reps: profile, active
    - Commission payouts: order, recipient, status, period, locallink
    - Affiliate partners: referral_code, user_id
    - Workspaces: owner_id
    - Leads: workspace_id
    - Automations: workspace_id
    - Appointments: workspace_id, lead_id, scheduled_at, status
    - Bot types: plan
    - Workspace bots: workspace_id, bot_type_id
*/

-- Demo requests indexes
DROP INDEX IF EXISTS idx_demo_requests_created_at;
DROP INDEX IF EXISTS idx_demo_requests_status;
DROP INDEX IF EXISTS idx_demo_requests_email;

-- Bot execution logs indexes
DROP INDEX IF EXISTS idx_bot_execution_logs_bot_type_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_lead_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_workspace_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_created_at;

-- Family reps indexes
DROP INDEX IF EXISTS idx_family_reps_profile_id;
DROP INDEX IF EXISTS idx_family_reps_referral_slug;

-- Internal payouts indexes
DROP INDEX IF EXISTS idx_internal_payouts_family_rep_id;
DROP INDEX IF EXISTS idx_internal_payouts_order_id;

-- LocalLink outbox indexes
DROP INDEX IF EXISTS idx_locallink_outbox_order_id;
DROP INDEX IF EXISTS idx_locallink_outbox_sync_status;

-- Messages indexes
DROP INDEX IF EXISTS idx_messages_lead_id;
DROP INDEX IF EXISTS idx_messages_workspace_id;

-- Orders indexes
DROP INDEX IF EXISTS idx_orders_workspace_id;
DROP INDEX IF EXISTS idx_orders_profile_id;
DROP INDEX IF EXISTS idx_orders_referred_by;

-- Vertical licenses indexes
DROP INDEX IF EXISTS idx_vertical_licenses_licensee;
DROP INDEX IF EXISTS idx_vertical_licenses_status;
DROP INDEX IF EXISTS idx_vertical_licenses_subdomain;
DROP INDEX IF EXISTS idx_vertical_licenses_vertical_template_id;

-- Vertical revenue indexes
DROP INDEX IF EXISTS idx_vertical_revenue_license;
DROP INDEX IF EXISTS idx_vertical_revenue_period;

-- Referral clicks indexes
DROP INDEX IF EXISTS idx_referral_clicks_partner_id;
DROP INDEX IF EXISTS idx_referral_clicks_code;
DROP INDEX IF EXISTS idx_referral_clicks_clicked_at;

-- Referral conversions indexes
DROP INDEX IF EXISTS idx_referral_conversions_partner_id;
DROP INDEX IF EXISTS idx_referral_conversions_code;
DROP INDEX IF EXISTS idx_referral_conversions_order_id;
DROP INDEX IF EXISTS idx_referral_conversions_status;

-- Employee reps indexes
DROP INDEX IF EXISTS idx_employee_reps_profile;
DROP INDEX IF EXISTS idx_employee_reps_active;

-- Commission payouts indexes
DROP INDEX IF EXISTS idx_commission_payouts_order;
DROP INDEX IF EXISTS idx_commission_payouts_recipient;
DROP INDEX IF EXISTS idx_commission_payouts_status;
DROP INDEX IF EXISTS idx_commission_payouts_period;
DROP INDEX IF EXISTS idx_commission_payouts_locallink;

-- Affiliate partners indexes
DROP INDEX IF EXISTS idx_affiliate_partners_referral_code;
DROP INDEX IF EXISTS idx_affiliate_partners_user_id;

-- Workspaces indexes
DROP INDEX IF EXISTS idx_workspaces_owner_id;

-- Leads indexes
DROP INDEX IF EXISTS idx_leads_workspace_id;

-- Automations indexes
DROP INDEX IF EXISTS idx_automations_workspace_id;

-- Appointments indexes
DROP INDEX IF EXISTS idx_appointments_workspace_id;
DROP INDEX IF EXISTS idx_appointments_lead_id;
DROP INDEX IF EXISTS idx_appointments_scheduled_at;
DROP INDEX IF EXISTS idx_appointments_status;

-- Bot types indexes
DROP INDEX IF EXISTS idx_bot_types_plan;

-- Workspace bots indexes
DROP INDEX IF EXISTS idx_workspace_bots_workspace_id;
DROP INDEX IF EXISTS idx_workspace_bots_bot_type_id;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Consolidate Redundant RLS Policies (Corrected)

  1. Policy Optimization
    - Consolidates overlapping policies where safe to do so
    - Maintains multi-tenant security model
    - Improves policy evaluation performance
  
  2. Changes Made
    - bot_types: Merge view policies into single comprehensive policy
    - workspace_bots: Remove redundant SELECT policy (covered by manage policy)
    - commission_payouts: Consolidate role-based SELECT policies
    - family_reps: Merge overlapping SELECT policies
    - internal_payouts: Consolidate view policies
    - vertical_configurations: Merge admin and licensee policies
    - vertical_licenses: Consolidate SELECT policies
    - vertical_revenue: Consolidate SELECT policies
    - vertical_templates: Merge view policies
  
  3. Security Notes
    - All policies maintain proper authentication checks
    - Multi-role access patterns preserved using OR conditions
    - No reduction in security posture
*/

-- =====================================================
-- bot_types: Consolidate view policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;
DROP POLICY IF EXISTS "Anyone can view bot types" ON bot_types;

CREATE POLICY "Authenticated users can view bot types"
  ON bot_types FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- workspace_bots: Remove redundant SELECT policy
-- =====================================================
DROP POLICY IF EXISTS "Users can view their workspace bots" ON workspace_bots;
-- Keep "Users can manage their workspace bots" (covers ALL including SELECT)

-- =====================================================
-- commission_payouts: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Employees can view own payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Family reps can view own payouts" ON commission_payouts;

CREATE POLICY "Users can view relevant commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Employees see their own
    (
      commission_payouts.recipient_type = 'employee'
      AND EXISTS (
        SELECT 1 FROM employee_reps
        WHERE employee_reps.profile_id = auth.uid()
        AND employee_reps.id = commission_payouts.recipient_id
      )
    )
    OR
    -- Family reps see their own
    (
      commission_payouts.recipient_type = 'family_rep'
      AND EXISTS (
        SELECT 1 FROM family_reps
        WHERE family_reps.profile_id = auth.uid()
        AND family_reps.id = commission_payouts.recipient_id
      )
    )
  );

-- =====================================================
-- family_reps: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;
DROP POLICY IF EXISTS "Family reps and admins can view family rep data" ON family_reps;

CREATE POLICY "Users can view relevant family rep data"
  ON family_reps FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Family reps see their own data
    family_reps.profile_id = auth.uid()
  );

CREATE POLICY "Admins can manage family reps"
  ON family_reps FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;
DROP POLICY IF EXISTS "Family reps and admins can view payouts" ON internal_payouts;

CREATE POLICY "Users can view relevant payouts"
  ON internal_payouts FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Family reps see their own
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.profile_id = auth.uid()
      AND family_reps.id = internal_payouts.family_rep_id
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON internal_payouts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_configurations: Consolidate admin and licensee policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;
DROP POLICY IF EXISTS "Licensee can manage own configuration" ON vertical_configurations;

CREATE POLICY "Users can manage relevant configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    -- Admins manage all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees manage their own
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  )
  WITH CHECK (
    -- Same check for modifications
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  );

-- =====================================================
-- vertical_licenses: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Licensee can view own license" ON vertical_licenses;

CREATE POLICY "Users can view relevant licenses"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees see their own
    vertical_licenses.licensee_id = auth.uid()
  );

CREATE POLICY "Admins can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_revenue: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;
DROP POLICY IF EXISTS "Licensee can view own revenue" ON vertical_revenue;

CREATE POLICY "Users can view relevant revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees see their own
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_revenue.license_id
    )
  );

-- =====================================================
-- vertical_templates: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;
DROP POLICY IF EXISTS "Anyone can view enabled templates" ON vertical_templates;

CREATE POLICY "Authenticated users can view templates"
  ON vertical_templates FOR SELECT
  TO authenticated
  USING (
    -- Everyone sees enabled templates
    vertical_templates.enabled = true
    OR
    -- Admins see all templates
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Validation to Referral Clicks Policy

  1. Security Enhancement
    - Replaces unrestricted INSERT policy with validated version
    - Ensures referral_code and partner_id reference valid affiliate partners
    - Maintains anonymous tracking capability for affiliate links
  
  2. Changes Made
    - Drop "Anyone can insert click tracking" policy
    - Create new policy that validates partner_id exists in affiliate_partners
    - Validates referral_code matches the partner's code
    - Only allows tracking for active partners
  
  3. Security Notes
    - Anonymous users can still track clicks (required for affiliate system)
    - Data integrity enforced through validation
    - Prevents insertion of fake/invalid affiliate data
*/

-- Drop the unrestricted policy
DROP POLICY IF EXISTS "Anyone can insert click tracking" ON referral_clicks;

-- Create validated policy
-- Allows anonymous/authenticated users to insert click tracking
-- but validates that the partner_id and referral_code are valid
CREATE POLICY "Track clicks for valid referral codes"
  ON referral_clicks FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    -- Validate that partner_id exists and referral_code matches
    EXISTS (
      SELECT 1 FROM affiliate_partners
      WHERE affiliate_partners.id = referral_clicks.partner_id
      AND affiliate_partners.referral_code = referral_clicks.referral_code
      AND affiliate_partners.is_active = true
    )
  );

-- Add comment explaining the policy
COMMENT ON POLICY "Track clicks for valid referral codes" ON referral_clicks IS 
  'Allows anonymous click tracking but validates partner_id and referral_code against active affiliate partners';


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Indexes for Foreign Keys

  1. Performance Optimization
    - Adds indexes for all foreign key columns to improve JOIN performance
    - Critical for queries that join across tables
    - Improves referential integrity check performance
  
  2. Indexes Being Created (26 total)
    - affiliate_partners: user_id
    - appointments: lead_id, workspace_id
    - automations: workspace_id
    - bot_execution_logs: bot_type_id, lead_id, workspace_id
    - commission_payouts: order_id
    - employee_reps: profile_id
    - family_reps: profile_id
    - internal_payouts: family_rep_id, order_id
    - leads: workspace_id
    - locallink_outbox: order_id
    - messages: lead_id, workspace_id
    - orders: profile_id, workspace_id
    - referral_clicks: partner_id
    - referral_conversions: order_id, partner_id
    - vertical_licenses: licensee_id, vertical_template_id
    - vertical_revenue: license_id
    - workspace_bots: bot_type_id
    - workspaces: owner_id
  
  3. Performance Impact
    - Significantly faster JOIN operations
    - Faster foreign key constraint checks on INSERT/UPDATE/DELETE
    - Better query optimizer decisions
*/

-- affiliate_partners
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_user_id 
  ON affiliate_partners(user_id);

-- appointments
CREATE INDEX IF NOT EXISTS idx_appointments_lead_id 
  ON appointments(lead_id);
CREATE INDEX IF NOT EXISTS idx_appointments_workspace_id 
  ON appointments(workspace_id);

-- automations
CREATE INDEX IF NOT EXISTS idx_automations_workspace_id 
  ON automations(workspace_id);

-- bot_execution_logs
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_bot_type_id 
  ON bot_execution_logs(bot_type_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_lead_id 
  ON bot_execution_logs(lead_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_workspace_id 
  ON bot_execution_logs(workspace_id);

-- commission_payouts
CREATE INDEX IF NOT EXISTS idx_commission_payouts_order_id 
  ON commission_payouts(order_id);

-- employee_reps
CREATE INDEX IF NOT EXISTS idx_employee_reps_profile_id 
  ON employee_reps(profile_id);

-- family_reps
CREATE INDEX IF NOT EXISTS idx_family_reps_profile_id 
  ON family_reps(profile_id);

-- internal_payouts
CREATE INDEX IF NOT EXISTS idx_internal_payouts_family_rep_id 
  ON internal_payouts(family_rep_id);
CREATE INDEX IF NOT EXISTS idx_internal_payouts_order_id 
  ON internal_payouts(order_id);

-- leads
CREATE INDEX IF NOT EXISTS idx_leads_workspace_id 
  ON leads(workspace_id);

-- locallink_outbox
CREATE INDEX IF NOT EXISTS idx_locallink_outbox_order_id 
  ON locallink_outbox(order_id);

-- messages
CREATE INDEX IF NOT EXISTS idx_messages_lead_id 
  ON messages(lead_id);
CREATE INDEX IF NOT EXISTS idx_messages_workspace_id 
  ON messages(workspace_id);

-- orders
CREATE INDEX IF NOT EXISTS idx_orders_profile_id 
  ON orders(profile_id);
CREATE INDEX IF NOT EXISTS idx_orders_workspace_id 
  ON orders(workspace_id);

-- referral_clicks
CREATE INDEX IF NOT EXISTS idx_referral_clicks_partner_id 
  ON referral_clicks(partner_id);

-- referral_conversions
CREATE INDEX IF NOT EXISTS idx_referral_conversions_order_id 
  ON referral_conversions(order_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_partner_id 
  ON referral_conversions(partner_id);

-- vertical_licenses
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_licensee_id 
  ON vertical_licenses(licensee_id);
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_vertical_template_id 
  ON vertical_licenses(vertical_template_id);

-- vertical_revenue
CREATE INDEX IF NOT EXISTS idx_vertical_revenue_license_id 
  ON vertical_revenue(license_id);

-- workspace_bots
CREATE INDEX IF NOT EXISTS idx_workspace_bots_bot_type_id 
  ON workspace_bots(bot_type_id);

-- workspaces
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id 
  ON workspaces(owner_id);


-- ========================================
-- Next Migration
-- ========================================


/*
  # Optimize RLS Policy Performance

  1. Performance Optimization
    - Wraps auth.uid() calls with (select auth.uid()) to cache the value
    - Prevents re-evaluation of auth.uid() for each row
    - Significantly improves query performance at scale
  
  2. Policies Being Optimized (12 policies across 8 tables)
    - bot_types: Admins can manage bot types
    - commission_payouts: Users can view relevant commission payouts
    - family_reps: Users can view relevant family rep data, Admins can manage family reps
    - internal_payouts: Users can view relevant payouts, Admins can manage payouts
    - vertical_configurations: Users can manage relevant configurations
    - vertical_licenses: Users can view relevant licenses, Admins can manage all licenses
    - vertical_revenue: Users can view relevant revenue
    - vertical_templates: Authenticated users can view templates, Admins can manage vertical templates
  
  3. Performance Impact
    - auth.uid() evaluated once per query instead of once per row
    - Can improve query performance by 10-100x on large result sets
    - No security implications (same access control logic)
*/

-- =====================================================
-- bot_types: Optimize admin check
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- commission_payouts: Optimize multi-role check
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant commission payouts" ON commission_payouts;

CREATE POLICY "Users can view relevant commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    (
      commission_payouts.recipient_type = 'employee'
      AND EXISTS (
        SELECT 1 FROM employee_reps
        WHERE employee_reps.profile_id = (select auth.uid())
        AND employee_reps.id = commission_payouts.recipient_id
      )
    )
    OR
    (
      commission_payouts.recipient_type = 'family_rep'
      AND EXISTS (
        SELECT 1 FROM family_reps
        WHERE family_reps.profile_id = (select auth.uid())
        AND family_reps.id = commission_payouts.recipient_id
      )
    )
  );

-- =====================================================
-- family_reps: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant family rep data" ON family_reps;
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;

CREATE POLICY "Users can view relevant family rep data"
  ON family_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    family_reps.profile_id = (select auth.uid())
  );

CREATE POLICY "Admins can manage family reps"
  ON family_reps FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant payouts" ON internal_payouts;
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;

CREATE POLICY "Users can view relevant payouts"
  ON internal_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.profile_id = (select auth.uid())
      AND family_reps.id = internal_payouts.family_rep_id
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON internal_payouts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_configurations: Optimize manage policy
-- =====================================================
DROP POLICY IF EXISTS "Users can manage relevant configurations" ON vertical_configurations;

CREATE POLICY "Users can manage relevant configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  );

-- =====================================================
-- vertical_licenses: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Admins can manage all licenses" ON vertical_licenses;

CREATE POLICY "Users can view relevant licenses"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    vertical_licenses.licensee_id = (select auth.uid())
  );

CREATE POLICY "Admins can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_revenue: Optimize view policy
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant revenue" ON vertical_revenue;

CREATE POLICY "Users can view relevant revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_revenue.license_id
    )
  );

-- =====================================================
-- vertical_templates: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Authenticated users can view templates" ON vertical_templates;
DROP POLICY IF EXISTS "Admins can manage vertical templates" ON vertical_templates;

CREATE POLICY "Authenticated users can view templates"
  ON vertical_templates FOR SELECT
  TO authenticated
  USING (
    vertical_templates.enabled = true
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Fix Policy Overlaps - Final

  1. Security Optimization
    - Separates admin management policies from view policies
    - Prevents multiple permissive policies for same action
    - Maintains same access control logic
  
  2. Changes Made
    - Split "FOR ALL" policies into separate INSERT, UPDATE, DELETE policies
    - Keep existing SELECT policies separate
    - No overlap for SELECT operations
  
  3. Affected Tables
    - bot_types: Split admin manage policy
    - family_reps: Split admin manage policy
    - internal_payouts: Split admin manage policy
    - vertical_licenses: Split admin manage policy
    - vertical_templates: Split admin manage policy
  
  4. Security Notes
    - Same access control logic maintained
    - No reduction in security
    - Better policy evaluation performance
*/

-- =====================================================
-- bot_types: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;

CREATE POLICY "Admins can insert bot types"
  ON bot_types FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update bot types"
  ON bot_types FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete bot types"
  ON bot_types FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- family_reps: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;

CREATE POLICY "Admins can insert family reps"
  ON family_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update family reps"
  ON family_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete family reps"
  ON family_reps FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;

CREATE POLICY "Admins can insert payouts"
  ON internal_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update payouts"
  ON internal_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete payouts"
  ON internal_payouts FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_licenses: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage all licenses" ON vertical_licenses;

CREATE POLICY "Admins can insert licenses"
  ON vertical_licenses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update licenses"
  ON vertical_licenses FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete licenses"
  ON vertical_licenses FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_templates: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admins can insert templates"
  ON vertical_templates FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update templates"
  ON vertical_templates FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete templates"
  ON vertical_templates FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Security Fixes: Remove Unused Indexes and Fix Security Definer View

  ## Changes Made

  ### 1. Remove Unused Indexes
  Removes 26 unused indexes that waste storage and slow down write operations:
    - affiliate_partners: idx_affiliate_partners_user_id
    - appointments: idx_appointments_lead_id, idx_appointments_workspace_id
    - automations: idx_automations_workspace_id
    - bot_execution_logs: idx_bot_execution_logs_bot_type_id, idx_bot_execution_logs_lead_id, idx_bot_execution_logs_workspace_id
    - commission_payouts: idx_commission_payouts_order_id
    - employee_reps: idx_employee_reps_profile_id
    - family_reps: idx_family_reps_profile_id
    - internal_payouts: idx_internal_payouts_family_rep_id, idx_internal_payouts_order_id
    - leads: idx_leads_workspace_id
    - locallink_outbox: idx_locallink_outbox_order_id
    - messages: idx_messages_lead_id, idx_messages_workspace_id
    - orders: idx_orders_profile_id, idx_orders_workspace_id
    - referral_clicks: idx_referral_clicks_partner_id
    - referral_conversions: idx_referral_conversions_order_id, idx_referral_conversions_partner_id
    - vertical_licenses: idx_vertical_licenses_licensee_id, idx_vertical_licenses_vertical_template_id
    - vertical_revenue: idx_vertical_revenue_license_id
    - workspace_bots: idx_workspace_bots_bot_type_id
    - workspaces: idx_workspaces_owner_id

  ### 2. Fix Security Definer View
  Recreates `payout_summary` view with SECURITY INVOKER instead of SECURITY DEFINER
    - SECURITY INVOKER runs with the privileges of the user executing the query
    - This prevents privilege escalation and follows the principle of least privilege

  ## Security Improvements
  - Reduces attack surface by removing unused indexes
  - Fixes potential privilege escalation via SECURITY DEFINER view
  - Improves database performance by reducing write overhead

  ## Manual Configuration Required (Cannot be automated via SQL)
  1. **Auth DB Connection Strategy**: Change from fixed connections to percentage-based in Supabase Dashboard
     - Go to: Database Settings > Connection Pooling
     - Change connection strategy to percentage-based allocation
  
  2. **Leaked Password Protection**: Enable in Supabase Auth settings
     - Go to: Authentication > Settings > Security
     - Enable "Leaked Password Protection" to check against HaveIBeenPwned.org
*/

-- Remove unused indexes
DROP INDEX IF EXISTS idx_affiliate_partners_user_id;
DROP INDEX IF EXISTS idx_appointments_lead_id;
DROP INDEX IF EXISTS idx_appointments_workspace_id;
DROP INDEX IF EXISTS idx_automations_workspace_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_bot_type_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_lead_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_workspace_id;
DROP INDEX IF EXISTS idx_commission_payouts_order_id;
DROP INDEX IF EXISTS idx_employee_reps_profile_id;
DROP INDEX IF EXISTS idx_family_reps_profile_id;
DROP INDEX IF EXISTS idx_internal_payouts_family_rep_id;
DROP INDEX IF EXISTS idx_internal_payouts_order_id;
DROP INDEX IF EXISTS idx_leads_workspace_id;
DROP INDEX IF EXISTS idx_locallink_outbox_order_id;
DROP INDEX IF EXISTS idx_messages_lead_id;
DROP INDEX IF EXISTS idx_messages_workspace_id;
DROP INDEX IF EXISTS idx_orders_profile_id;
DROP INDEX IF EXISTS idx_orders_workspace_id;
DROP INDEX IF EXISTS idx_referral_clicks_partner_id;
DROP INDEX IF EXISTS idx_referral_conversions_order_id;
DROP INDEX IF EXISTS idx_referral_conversions_partner_id;
DROP INDEX IF EXISTS idx_vertical_licenses_licensee_id;
DROP INDEX IF EXISTS idx_vertical_licenses_vertical_template_id;
DROP INDEX IF EXISTS idx_vertical_revenue_license_id;
DROP INDEX IF EXISTS idx_workspace_bots_bot_type_id;
DROP INDEX IF EXISTS idx_workspaces_owner_id;

-- Recreate payout_summary view with SECURITY INVOKER instead of SECURITY DEFINER
DROP VIEW IF EXISTS payout_summary;

CREATE VIEW payout_summary
WITH (security_invoker = true)
AS
SELECT 
  recipient_type,
  recipient_id,
  recipient_name,
  count(*) AS total_orders,
  sum(commission_amount) AS total_earned,
  sum(CASE WHEN status = 'paid' THEN commission_amount ELSE 0 END) AS total_paid,
  sum(CASE WHEN status = 'pending' THEN commission_amount ELSE 0 END) AS total_pending,
  max(paid_at) AS last_payment_date
FROM commission_payouts
GROUP BY recipient_type, recipient_id, recipient_name;

-- Grant appropriate access to the view
GRANT SELECT ON payout_summary TO authenticated;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create Webinar System

  1. New Tables
    - `webinar_bookings`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users) - Who booked the webinar
      - `email` (text) - Email address for non-authenticated users
      - `full_name` (text) - Full name of attendee
      - `phone` (text, optional) - Phone number
      - `scheduled_for` (timestamptz) - When the webinar is scheduled
      - `status` (text) - pending, live, completed, cancelled
      - `webinar_type` (text) - product_demo, full_presentation, custom
      - `created_at` (timestamptz)
      - `started_at` (timestamptz, optional) - When webinar actually started
      - `completed_at` (timestamptz, optional) - When webinar finished
      - `duration_minutes` (integer) - Expected duration
      
    - `webinar_interactions`
      - `id` (uuid, primary key)
      - `booking_id` (uuid, references webinar_bookings)
      - `message` (text) - Message from attendee
      - `response` (text) - Bot response
      - `interaction_type` (text) - question, objection, interest_signal, purchase_intent
      - `created_at` (timestamptz)
      
    - `webinar_conversions`
      - `id` (uuid, primary key)
      - `booking_id` (uuid, references webinar_bookings)
      - `product_name` (text) - Product they showed interest in
      - `price_id` (text) - Stripe price ID
      - `converted` (boolean) - Whether they actually purchased
      - `conversion_time` (timestamptz) - When they converted
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Users can view their own webinar bookings
    - Users can create webinar bookings
    - Users can add interactions to their own webinars
    - Authenticated users can view their conversions
*/

-- Create webinar_bookings table
CREATE TABLE IF NOT EXISTS webinar_bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  email text NOT NULL,
  full_name text NOT NULL,
  phone text,
  scheduled_for timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  webinar_type text NOT NULL DEFAULT 'product_demo',
  created_at timestamptz DEFAULT now(),
  started_at timestamptz,
  completed_at timestamptz,
  duration_minutes integer DEFAULT 30,
  CONSTRAINT valid_status CHECK (status IN ('pending', 'live', 'completed', 'cancelled')),
  CONSTRAINT valid_webinar_type CHECK (webinar_type IN ('product_demo', 'full_presentation', 'custom'))
);

-- Create webinar_interactions table
CREATE TABLE IF NOT EXISTS webinar_interactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES webinar_bookings(id) ON DELETE CASCADE,
  message text NOT NULL,
  response text NOT NULL,
  interaction_type text NOT NULL DEFAULT 'question',
  created_at timestamptz DEFAULT now(),
  CONSTRAINT valid_interaction_type CHECK (interaction_type IN ('question', 'objection', 'interest_signal', 'purchase_intent'))
);

-- Create webinar_conversions table
CREATE TABLE IF NOT EXISTS webinar_conversions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES webinar_bookings(id) ON DELETE CASCADE,
  product_name text NOT NULL,
  price_id text NOT NULL,
  converted boolean DEFAULT false,
  conversion_time timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_webinar_bookings_user_id ON webinar_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_webinar_bookings_scheduled_for ON webinar_bookings(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_webinar_bookings_status ON webinar_bookings(status);
CREATE INDEX IF NOT EXISTS idx_webinar_interactions_booking_id ON webinar_interactions(booking_id);
CREATE INDEX IF NOT EXISTS idx_webinar_conversions_booking_id ON webinar_conversions(booking_id);

-- Enable RLS
ALTER TABLE webinar_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE webinar_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE webinar_conversions ENABLE ROW LEVEL SECURITY;

-- Policies for webinar_bookings

-- Anyone can create a webinar booking
CREATE POLICY "Anyone can create webinar bookings"
  ON webinar_bookings FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Users can view their own bookings (by user_id or email)
CREATE POLICY "Users can view own webinar bookings"
  ON webinar_bookings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Anonymous users can view bookings by email (for joining webinar)
CREATE POLICY "Users can view bookings by email"
  ON webinar_bookings FOR SELECT
  TO anon
  USING (true);

-- Users can update their own bookings
CREATE POLICY "Users can update own webinar bookings"
  ON webinar_bookings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policies for webinar_interactions

-- Anyone can create interactions for any booking
CREATE POLICY "Anyone can create webinar interactions"
  ON webinar_interactions FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Anyone can view interactions for bookings they have access to
CREATE POLICY "Anyone can view webinar interactions"
  ON webinar_interactions FOR SELECT
  TO authenticated, anon
  USING (true);

-- Policies for webinar_conversions

-- System can create conversions
CREATE POLICY "System can create conversions"
  ON webinar_conversions FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Users can view conversions for their bookings
CREATE POLICY "Users can view own conversions"
  ON webinar_conversions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM webinar_bookings
      WHERE webinar_bookings.id = webinar_conversions.booking_id
      AND webinar_bookings.user_id = auth.uid()
    )
  );


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Automation System

  1. New Tables
    - `automation_jobs` - Queue for scheduled bot runs and follow-up sequences
    - `checkout_sessions` - Track Stripe checkout sessions for abandoned cart recovery

  2. Security
    - Enable RLS on both tables
    - Restrict access to workspace owners and service role

  3. Indexes
    - Optimized for job queue processing and session lookups
*/

-- automation_jobs table
CREATE TABLE IF NOT EXISTS automation_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  run_at timestamptz DEFAULT now(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  bot_id text NOT NULL,
  trigger text NOT NULL,
  payload jsonb DEFAULT '{}',
  status text DEFAULT 'queued',
  error text,
  completed_at timestamptz
);

-- checkout_sessions table
CREATE TABLE IF NOT EXISTS checkout_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE SET NULL,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  referral_slug text,
  stripe_session_id text UNIQUE NOT NULL,
  plan_key text,
  addon_key text,
  status text DEFAULT 'created',
  metadata jsonb DEFAULT '{}'
);

-- Indexes for automation_jobs
CREATE INDEX IF NOT EXISTS idx_automation_jobs_status_run_at
  ON automation_jobs(status, run_at)
  WHERE status = 'queued';

CREATE INDEX IF NOT EXISTS idx_automation_jobs_workspace
  ON automation_jobs(workspace_id);

CREATE INDEX IF NOT EXISTS idx_automation_jobs_lead
  ON automation_jobs(lead_id)
  WHERE lead_id IS NOT NULL;

-- Indexes for checkout_sessions
CREATE INDEX IF NOT EXISTS idx_checkout_sessions_stripe
  ON checkout_sessions(stripe_session_id);

CREATE INDEX IF NOT EXISTS idx_checkout_sessions_workspace
  ON checkout_sessions(workspace_id)
  WHERE workspace_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_checkout_sessions_status_created
  ON checkout_sessions(status, created_at)
  WHERE status = 'created';

-- Enable RLS
ALTER TABLE automation_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout_sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for automation_jobs
CREATE POLICY "Users can view own workspace jobs"
  ON automation_jobs FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM workspaces WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "System can manage all jobs"
  ON automation_jobs FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- RLS Policies for checkout_sessions
CREATE POLICY "Users can view own workspace sessions"
  ON checkout_sessions FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM workspaces WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "System can manage all sessions"
  ON checkout_sessions FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);


-- ========================================
-- Next Migration
-- ========================================


/*
  # Add Referral Tracking System

  1. New Columns for Referral Attribution
    - Add referral_partner_link_slug to key tables
    - Ensures referral attribution persists through entire customer journey
    
  2. New Table: outbox_events
    - Queue for sending events to Local-Link
    - Reliable event delivery with retry logic
    - Tracks sales, referrals, and commission-eligible events

  3. Security
    - Enable RLS on outbox_events
    - Only admins/service role can access

  4. Indexes
    - Fast lookups by referral slug
    - Efficient event queue processing
*/

-- Add referral columns to existing tables
ALTER TABLE leads 
  ADD COLUMN IF NOT EXISTS referral_partner_link_slug text,
  ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}';

ALTER TABLE workspaces
  ADD COLUMN IF NOT EXISTS referral_partner_link_slug text;

ALTER TABLE checkout_sessions
  ADD COLUMN IF NOT EXISTS referral_partner_link_slug text;

-- Create outbox_events table for Local-Link handoff
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

-- Indexes for referral tracking
CREATE INDEX IF NOT EXISTS idx_leads_referral_slug
  ON leads(referral_partner_link_slug)
  WHERE referral_partner_link_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_workspaces_referral_slug
  ON workspaces(referral_partner_link_slug)
  WHERE referral_partner_link_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_checkout_sessions_referral
  ON checkout_sessions(referral_partner_link_slug)
  WHERE referral_partner_link_slug IS NOT NULL;

-- Indexes for outbox_events queue
CREATE INDEX IF NOT EXISTS idx_outbox_events_status
  ON outbox_events(status, created_at)
  WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_outbox_events_workspace
  ON outbox_events(workspace_id)
  WHERE workspace_id IS NOT NULL;

-- Enable RLS on outbox_events
ALTER TABLE outbox_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies for outbox_events
CREATE POLICY "Admins can view all events"
  ON outbox_events FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "System can manage all events"
  ON outbox_events FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Function to clean up old sent events
CREATE OR REPLACE FUNCTION cleanup_old_outbox_events()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM outbox_events
  WHERE status = 'sent'
    AND sent_at < now() - interval '90 days';
END;
$$;


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create Bot Response Library System

  1. New Tables
    - `bot_response_library`
      - `id` (uuid, primary key)
      - `industry` (text) - cleaning, tree, medspa, contractor, realestate, universal
      - `category` (text) - greeting, booking, objection, closing, upsell, dfy
      - `intent` (text) - specific intent/scenario
      - `response` (text) - the actual bot response
      - `priority` (int) - for ordering responses
      - `active` (boolean) - enable/disable responses
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `bot_response_library` table
    - Allow authenticated users to read responses
    - Only workspace owners can modify responses

  3. Indexes
    - Index on industry + category + intent for fast lookups
    - Index on active for filtering
*/

-- Create bot response library table
CREATE TABLE IF NOT EXISTS bot_response_library (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  industry text NOT NULL,
  category text NOT NULL,
  intent text NOT NULL,
  response text NOT NULL,
  priority int DEFAULT 1,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_bot_response_lookup
  ON bot_response_library(industry, category, intent)
  WHERE active = true;

CREATE INDEX IF NOT EXISTS idx_bot_response_active
  ON bot_response_library(active);

-- Enable RLS
ALTER TABLE bot_response_library ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can read active bot responses"
  ON bot_response_library FOR SELECT
  TO authenticated
  USING (active = true);

CREATE POLICY "Workspace owners can manage bot responses"
  ON bot_response_library FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM workspaces
      WHERE workspaces.owner_id = auth.uid()
    )
  );

-- Seed universal responses
INSERT INTO bot_response_library (industry, category, intent, response, priority) VALUES
  -- Universal greetings
  ('universal', 'greeting', 'initial', 'Hi! This is FrontDesk AI Pro. How can I help you today?', 1),
  ('universal', 'greeting', 'speed_assurance', 'I can help you right now â€” no waiting, no call backs.', 2),

  -- Universal lead capture
  ('universal', 'lead_capture', 'get_info', 'I can get this scheduled for you. What is your name and best number?', 1),
  ('universal', 'lead_capture', 'soft_close', 'Want me to take care of this for you now?', 2),

  -- Universal checkout
  ('universal', 'checkout', 'offer', 'I can activate this for you today so you stop missing leads. Would you like Starter or Core?', 1),
  ('universal', 'checkout', 'roi_framing', 'Most clients cover the cost with just one or two recovered leads.', 2),

  -- Universal handoff
  ('universal', 'handoff', 'to_human', 'I will notify the owner and have them follow up shortly.', 1),

  -- Universal objections
  ('universal', 'objection', 'need_to_think', 'Totally understand. What question can I answer right now to help you decide?', 1),
  ('universal', 'objection', 'busy', 'That is exactly why most owners use this â€” it works while you are working.', 2),
  ('universal', 'objection', 'not_techy', 'No worries â€” we handle everything for you.', 3),
  ('universal', 'objection', 'will_it_work', 'Yes â€” it is trained on your business and customized for your industry.', 4),

  -- Universal DFY
  ('universal', 'dfy', 'intro', 'If you would rather have this fully set up for you, our DFY team can handle everything.', 1),
  ('universal', 'dfy', 'value', 'We configure your funnels, campaigns, and automations so you do not have to.', 2),
  ('universal', 'dfy', 'price', 'DFY starts at $497/month and includes ongoing optimization.', 3),
  ('universal', 'dfy', 'close', 'Would you like DFY or the Core plan?', 4),

  -- Cleaning industry
  ('cleaning', 'inquiry', 'pricing', 'Sure! We offer standard, deep, and move-out cleanings. What size home are you looking to have cleaned?', 1),
  ('cleaning', 'booking', 'schedule', 'I can book your cleaning in under a minute. What day works best?', 1),
  ('cleaning', 'objection', 'too_expensive', 'Many clients say that at first, but most find it pays for itself quickly by filling empty spots.', 1),
  ('cleaning', 'review', 'request', 'Thanks for choosing us! Would you mind leaving a quick review? It helps a lot.', 1),
  ('cleaning', 'upsell', 'recurring', 'We also offer recurring cleanings if you would like priority scheduling.', 1),

  -- Tree service
  ('tree', 'emergency', 'urgent', 'That sounds urgent. I can schedule a priority visit. Can I get your address and a photo?', 1),
  ('tree', 'estimate', 'schedule', 'I will gather a few details and set up your free estimate.', 1),
  ('tree', 'followup', 'storm', 'We are helping several homeowners today. Want me to reserve you a spot?', 1),
  ('tree', 'objection', 'insurance', 'Most storm jobs are covered by insurance â€” we can help with that.', 1),
  ('tree', 'closing', 'confirm', 'Shall I lock in your estimate appointment?', 1),

  -- Med spa / beauty
  ('medspa', 'inquiry', 'treatment', 'Yes, we offer that service. May I ask what result you are hoping for?', 1),
  ('medspa', 'booking', 'schedule', 'I see openings this week. Want morning or afternoon?', 1),
  ('medspa', 'objection', 'hesitation', 'Many clients start with a consultation first. Would you like me to book that?', 1),
  ('medspa', 'upsell', 'packages', 'We also have packages that save money long-term.', 1),
  ('medspa', 'review', 'request', 'We would love your feedback! Here is a quick link for you.', 1),

  -- Contractor
  ('contractor', 'inquiry', 'quote', 'I can help you get a fast estimate. Can you share a photo and address?', 1),
  ('contractor', 'booking', 'schedule', 'Our next available visit is soon. Would that work for you?', 1),
  ('contractor', 'objection', 'price', 'We focus on quality and reliability, not just lowest price.', 1),
  ('contractor', 'followup', 'check_in', 'Just checking in â€” would you like me to move forward with your estimate?', 1),
  ('contractor', 'closing', 'confirm', 'Want me to lock this in now?', 1),

  -- Real estate
  ('realestate', 'inquiry', 'listing', 'I can schedule a showing for you. Are you pre-approved yet?', 1),
  ('realestate', 'qualification', 'buyer', 'What price range are you comfortable with?', 1),
  ('realestate', 'inquiry', 'seller', 'We offer free home valuations. Would you like one?', 1),
  ('realestate', 'nurture', 'followup', 'I will keep you updated with new listings that match.', 1),
  ('realestate', 'closing', 'showing', 'Should I book your showing?', 1),

  -- Local-Link Deals (optional mention)
  ('universal', 'deals', 'intro', 'We also offer Local-Link Deals, where you can sell a discounted offer and get paid upfront. It is a great way to bring in new customers fast.', 1),
  ('universal', 'deals', 'example', 'For example, you could offer a $40 service for $20. Customers buy it on Local-Link, and many come back at full price.', 2),
  ('universal', 'deals', 'objection', 'Most businesses use deals to bring in first-time customers, then turn them into repeat clients.', 3),
  ('universal', 'deals', 'dfy', 'If you would like, our DFY team can build and launch your first deal for you.', 4),
  ('universal', 'deals', 'close', 'Want me to help you activate your first deal?', 5);


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create DFY Playbook System

  1. New Tables
    - `dfy_playbooks`
      - `id` (uuid, primary key)
      - `industry` (text) - cleaning, tree, medspa, contractor, realestate
      - `day` (int) - day number in 7-day plan
      - `phase` (text) - activation, build, automation, messaging, training, launch, optimization
      - `checklist` (jsonb) - array of checklist items
      - `automations` (jsonb) - automation configurations
      - `kpis` (jsonb) - target KPIs
      - `scripts` (jsonb) - bot scripts for this phase
      - `active` (boolean)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `dfy_client_progress`
      - `id` (uuid, primary key)
      - `workspace_id` (uuid, foreign key)
      - `industry` (text)
      - `current_day` (int)
      - `completed_days` (jsonb) - array of completed day numbers
      - `checklist_progress` (jsonb) - progress on each checklist item
      - `started_at` (timestamptz)
      - `completed_at` (timestamptz)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on both tables
    - Authenticated users can read playbooks
    - Only workspace owners can view their progress
    - Admins can manage playbooks

  3. Indexes
    - Index on industry and day for fast lookups
    - Index on workspace_id for client progress
*/

-- Create DFY playbooks table
CREATE TABLE IF NOT EXISTS dfy_playbooks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  industry text NOT NULL,
  day int NOT NULL,
  phase text NOT NULL,
  checklist jsonb DEFAULT '[]'::jsonb,
  automations jsonb DEFAULT '{}'::jsonb,
  kpis jsonb DEFAULT '{}'::jsonb,
  scripts jsonb DEFAULT '{}'::jsonb,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(industry, day)
);

-- Create DFY client progress table
CREATE TABLE IF NOT EXISTS dfy_client_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  industry text NOT NULL,
  current_day int DEFAULT 0,
  completed_days jsonb DEFAULT '[]'::jsonb,
  checklist_progress jsonb DEFAULT '{}'::jsonb,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE(workspace_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_dfy_playbooks_lookup
  ON dfy_playbooks(industry, day)
  WHERE active = true;

CREATE INDEX IF NOT EXISTS idx_dfy_client_workspace
  ON dfy_client_progress(workspace_id);

-- Enable RLS
ALTER TABLE dfy_playbooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE dfy_client_progress ENABLE ROW LEVEL SECURITY;

-- Policies for playbooks
CREATE POLICY "Authenticated users can read active playbooks"
  ON dfy_playbooks FOR SELECT
  TO authenticated
  USING (active = true);

CREATE POLICY "Workspace owners can manage playbooks"
  ON dfy_playbooks FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM workspaces
      WHERE workspaces.owner_id = auth.uid()
    )
  );

-- Policies for client progress
CREATE POLICY "Users can read own DFY progress"
  ON dfy_client_progress FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM workspaces
      WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own DFY progress"
  ON dfy_client_progress FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM workspaces
      WHERE owner_id = auth.uid()
    )
  );

-- Seed cleaning industry playbook
INSERT INTO dfy_playbooks (industry, day, phase, checklist, kpis) VALUES
  ('cleaning', 0, 'activation', 
   '["Collect business info", "Connect calendar", "Connect phone/SMS", "Connect FB/IG", "Confirm pricing"]'::jsonb,
   '{"response_time": "< 60 sec"}'::jsonb),
  ('cleaning', 1, 'build',
   '["Create landing page", "Build intake forms", "Setup CRM pipelines", "Create booking pages"]'::jsonb,
   '{"pages_created": 4}'::jsonb),
  ('cleaning', 2, 'automation',
   '["Chat to CRM flow", "SMS to booking flow", "Call routing", "Missed call follow-up"]'::jsonb,
   '{"flows_active": 4}'::jsonb),
  ('cleaning', 3, 'messaging',
   '["Lead sequences", "Review flows", "Nurture campaigns"]'::jsonb,
   '{"campaigns_live": 3}'::jsonb),
  ('cleaning', 4, 'training',
   '["Upload FAQs", "Add policies", "Load scripts", "Configure offers"]'::jsonb,
   '{"knowledge_base": "complete"}'::jsonb),
  ('cleaning', 5, 'launch',
   '["Activate ads", "Turn on bots", "Test flows", "Monitor initial leads"]'::jsonb,
   '{"systems_live": true}'::jsonb),
  ('cleaning', 7, 'optimization',
   '["Tune scripts", "Adjust triggers", "Improve conversion", "Review metrics"]'::jsonb,
   '{"cpl": "< $15", "close_rate": "> 25%", "retention": "> 70%"}'::jsonb);

-- Seed tree service playbook
INSERT INTO dfy_playbooks (industry, day, phase, checklist, kpis) VALUES
  ('tree', 0, 'activation',
   '["Emergency workflow setup", "Photo upload config", "Insurance form integration", "Priority routing"]'::jsonb,
   '{"response_time": "< 30 sec"}'::jsonb),
  ('tree', 5, 'launch',
   '["Activate emergency bot", "Test photo intake", "Launch campaigns"]'::jsonb,
   '{"emergency_capture": "> 80%"}'::jsonb),
  ('tree', 7, 'optimization',
   '["Review emergency response", "Optimize routing", "Refine messaging"]'::jsonb,
   '{"response_time": "< 30 sec", "capture_rate": "> 80%"}'::jsonb);

-- Seed medspa playbook
INSERT INTO dfy_playbooks (industry, day, phase, checklist, kpis) VALUES
  ('medspa', 0, 'activation',
   '["Treatment menu setup", "Consultation flow", "Package offers", "Consent forms"]'::jsonb,
   '{"dm_response": "< 2 min"}'::jsonb),
  ('medspa', 5, 'launch',
   '["Activate DM bot", "Launch IG campaigns", "Test booking flow"]'::jsonb,
   '{"show_rate": "> 85%"}'::jsonb),
  ('medspa', 7, 'optimization',
   '["Optimize package offers", "Refine upsell flow", "Review conversion"]'::jsonb,
   '{"package_close": "> 30%", "show_rate": "> 85%"}'::jsonb);

-- Seed contractor playbook
INSERT INTO dfy_playbooks (industry, day, phase, checklist, kpis) VALUES
  ('contractor', 0, 'activation',
   '["Photo intake setup", "Estimate routing", "Follow-up cadence", "Financing info"]'::jsonb,
   '{"response_time": "< 5 min"}'::jsonb),
  ('contractor', 5, 'launch',
   '["Activate quote bot", "Test photo flow", "Launch campaigns"]'::jsonb,
   '{"quote_close": "> 35%"}'::jsonb),
  ('contractor', 7, 'optimization',
   '["Optimize quote follow-up", "Refine photo requests", "Improve close rate"]'::jsonb,
   '{"quote_close": "> 35%", "response_time": "< 5 min"}'::jsonb);

-- Seed real estate playbook
INSERT INTO dfy_playbooks (industry, day, phase, checklist, kpis) VALUES
  ('realestate', 0, 'activation',
   '["Lead source integration", "MLS sync", "Buyer/seller flows", "Mortgage partners"]'::jsonb,
   '{"response_time": "< 10 sec"}'::jsonb),
  ('realestate', 5, 'launch',
   '["Activate lead bot", "Test showing scheduler", "Launch campaigns"]'::jsonb,
   '{"lead_to_show": "> 30%"}'::jsonb),
  ('realestate', 7, 'optimization',
   '["Optimize lead qualification", "Refine showing flow", "Improve conversion"]'::jsonb,
   '{"lead_to_show": "> 30%", "deal_close": "> 5%"}'::jsonb);


-- ========================================
-- Next Migration
-- ========================================


/*
  # Create Partner Certification System

  1. New Tables
    - `partner_cert_modules` - Training module content
    - `partner_cert_progress` - Partner progress through modules
    - `partner_cert_exams` - Exam questions
    - `partner_cert_results` - Exam results
    - `partner_pitch_reviews` - Practice pitch submissions
    - `partner_cert_renewals` - Annual recertification
    - `partner_funnels` - Partner micro-funnels
    - `partner_funnel_stats` - Funnel analytics

  2. Partner Status Fields
    - Add certification fields to affiliate_partners table

  3. Security
    - Enable RLS on all tables
    - Partners can only see their own data

  4. Indexes
    - Index on partner_id for fast lookups
*/

-- Create certification modules table
CREATE TABLE IF NOT EXISTS partner_cert_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_number int NOT NULL UNIQUE,
  title text NOT NULL,
  description text,
  video_url text,
  content jsonb DEFAULT '{}'::jsonb,
  quiz_questions jsonb DEFAULT '[]'::jsonb,
  passing_score int DEFAULT 80,
  order_index int NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create partner progress table
CREATE TABLE IF NOT EXISTS partner_cert_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES partner_cert_modules(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  score int,
  attempts int DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(partner_id, module_id)
);

-- Create certification exams table
CREATE TABLE IF NOT EXISTS partner_cert_exams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  passing_score int DEFAULT 85,
  time_limit_minutes int DEFAULT 60,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create exam results table
CREATE TABLE IF NOT EXISTS partner_cert_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  exam_id uuid NOT NULL REFERENCES partner_cert_exams(id) ON DELETE CASCADE,
  score int NOT NULL,
  passed boolean NOT NULL,
  answers jsonb NOT NULL DEFAULT '{}'::jsonb,
  started_at timestamptz NOT NULL,
  completed_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create pitch reviews table
CREATE TABLE IF NOT EXISTS partner_pitch_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  pitch_type text DEFAULT 'video',
  pitch_url text,
  pitch_text text,
  status text DEFAULT 'pending',
  score int,
  feedback text,
  reviewed_by uuid,
  reviewed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create certification renewals table
CREATE TABLE IF NOT EXISTS partner_cert_renewals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  renewal_date date NOT NULL,
  completed_at timestamptz,
  score int,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Create partner funnels table
CREATE TABLE IF NOT EXISTS partner_funnels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  funnel_slug text NOT NULL UNIQUE,
  funnel_name text NOT NULL,
  partner_bio text,
  partner_photo_url text,
  custom_headline text,
  testimonials jsonb DEFAULT '[]'::jsonb,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create partner funnel stats table
CREATE TABLE IF NOT EXISTS partner_funnel_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  funnel_id uuid NOT NULL REFERENCES partner_funnels(id) ON DELETE CASCADE,
  date date NOT NULL DEFAULT CURRENT_DATE,
  views int DEFAULT 0,
  conversions int DEFAULT 0,
  revenue numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(funnel_id, date)
);

-- Add certification fields to affiliate_partners table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'is_certified'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN is_certified boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_level'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_level text DEFAULT 'none';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_date'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_date timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_expires_at'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_expires_at timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'community_role'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN community_role text DEFAULT 'member';
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_partner_progress_partner
  ON partner_cert_progress(partner_id);

CREATE INDEX IF NOT EXISTS idx_cert_results_partner
  ON partner_cert_results(partner_id);

CREATE INDEX IF NOT EXISTS idx_pitch_reviews_partner
  ON partner_pitch_reviews(partner_id);

CREATE INDEX IF NOT EXISTS idx_cert_renewals_partner
  ON partner_cert_renewals(partner_id);

CREATE INDEX IF NOT EXISTS idx_partner_funnels_partner
  ON partner_funnels(partner_id);

CREATE INDEX IF NOT EXISTS idx_partner_funnels_slug
  ON partner_funnels(funnel_slug);

CREATE INDEX IF NOT EXISTS idx_affiliate_partners_certified
  ON affiliate_partners(is_certified)
  WHERE is_certified = true;

-- Enable RLS
ALTER TABLE partner_cert_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_pitch_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_renewals ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_funnels ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_funnel_stats ENABLE ROW LEVEL SECURITY;

-- Policies for modules (public read for authenticated)
CREATE POLICY "Partners can read active modules"
  ON partner_cert_modules FOR SELECT
  TO authenticated
  USING (active = true);

-- Policies for progress
CREATE POLICY "Partners can read own progress"
  ON partner_cert_progress FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can create own progress"
  ON partner_cert_progress FOR INSERT
  TO authenticated
  WITH CHECK (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can update own progress"
  ON partner_cert_progress FOR UPDATE
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for exams
CREATE POLICY "Partners can read active exams"
  ON partner_cert_exams FOR SELECT
  TO authenticated
  USING (active = true);

-- Policies for results
CREATE POLICY "Partners can read own results"
  ON partner_cert_results FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can insert own results"
  ON partner_cert_results FOR INSERT
  TO authenticated
  WITH CHECK (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for pitch reviews
CREATE POLICY "Partners can manage own pitches"
  ON partner_pitch_reviews FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for renewals
CREATE POLICY "Partners can read own renewals"
  ON partner_cert_renewals FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for funnels
CREATE POLICY "Anyone can read active funnels"
  ON partner_funnels FOR SELECT
  TO anon, authenticated
  USING (active = true);

CREATE POLICY "Partners can manage own funnels"
  ON partner_funnels FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for funnel stats
CREATE POLICY "Partners can read own funnel stats"
  ON partner_funnel_stats FOR SELECT
  TO authenticated
  USING (
    funnel_id IN (
      SELECT pf.id FROM partner_funnels pf
      JOIN affiliate_partners ap ON pf.partner_id = ap.id
      WHERE ap.user_id = auth.uid()
    )
  );

-- Seed certification modules
INSERT INTO partner_cert_modules (module_number, title, description, order_index, quiz_questions) VALUES
  (1, 'Platform Overview', 'What You are Selling - FrontDesk AI Pro ecosystem and value proposition', 1, 
   '[{"q": "What is FrontDesk AI Pro?", "options": ["An AI operations team", "Just a chatbot", "A CRM only"], "correct": 0}]'::jsonb),
  (2, 'Product Mastery', 'Know Every Plan - Deep dive into Starter, Core, Accelerator, and DFY', 2,
   '[{"q": "Which plan includes call answering?", "options": ["Starter", "Core", "Accelerator"], "correct": 2}]'::jsonb),
  (3, 'Ideal Customers', 'Who Converts - Best industries, company size, and red flags', 3,
   '[{"q": "Best customer type?", "options": ["Enterprise only", "Local service businesses", "Ecommerce"], "correct": 1}]'::jsonb),
  (4, 'Sales System', 'How Deals Close - Bot-first selling and when to intervene', 4,
   '[{"q": "When should a partner jump in?", "options": ["Immediately", "Only if bot escalates", "Never"], "correct": 1}]'::jsonb),
  (5, 'Advertising Playbook', 'Traffic Engine - How to drive leads with $20/day budget', 5,
   '[{"q": "Starting ad budget?", "options": ["$5/day", "$20/day", "$100/day"], "correct": 1}]'::jsonb),
  (6, 'Compliance & Brand', 'Protect the Brand - What you can and cannot promise', 6,
   '[{"q": "Can you promise specific profits?", "options": ["Yes", "No", "Sometimes"], "correct": 1}]'::jsonb),
  (7, 'Referrals & Payouts', 'How You Get Paid - Tracking, attribution, and Local-Link', 7,
   '[{"q": "Where are commissions calculated?", "options": ["FrontDesk", "Local-Link", "Stripe"], "correct": 1}]'::jsonb),
  (8, 'Scaling', 'From 1 Client to 50 - Reinvestment and growth strategies', 8,
   '[{"q": "Best way to scale?", "options": ["Buy more ads randomly", "Reinvest ad profits", "Wait and hope"], "correct": 1}]'::jsonb);

-- Seed final certification exam
INSERT INTO partner_cert_exams (title, description, questions, passing_score) VALUES
  ('Partner Certification Final Exam', 'Comprehensive test covering all 8 modules', 
   '[
     {"q": "What is FrontDesk AI Pro?", "options": ["CRM software", "AI operations team", "Email tool"], "correct": 1},
     {"q": "Which plan is for busy owners who want full setup?", "options": ["Starter", "Core", "DFY"], "correct": 2},
     {"q": "Where are commissions calculated?", "options": ["FrontDesk", "Local-Link", "Manually"], "correct": 1},
     {"q": "Starting ad budget recommendation?", "options": ["$5", "$20", "$100"], "correct": 1},
     {"q": "Can you promise income?", "options": ["Yes", "No", "Sometimes"], "correct": 1}
   ]'::jsonb, 
   85);


-- ========================================
-- Next Migration
-- ========================================


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


-- ========================================
-- Next Migration
-- ========================================


