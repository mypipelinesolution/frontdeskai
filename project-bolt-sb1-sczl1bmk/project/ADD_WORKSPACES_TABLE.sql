-- Add workspaces table to existing database
-- Run this in Supabase SQL Editor

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

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_workspaces_stripe_subscription ON workspaces(stripe_subscription_id);

-- Enable Row Level Security
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view their own workspaces
CREATE POLICY "Users can view their own workspaces"
  ON workspaces FOR SELECT
  TO authenticated
  USING (owner_id = auth.uid());

-- RLS Policy: Users can create workspaces
CREATE POLICY "Users can create workspaces"
  ON workspaces FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

-- RLS Policy: Users can update their own workspaces
CREATE POLICY "Users can update their own workspaces"
  ON workspaces FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- Create a workspace for existing users who have subscriptions
INSERT INTO workspaces (owner_id, business_name, stripe_subscription_id, stripe_customer_id, subscription_status)
SELECT 
  id as owner_id,
  COALESCE(company_name, full_name, email) as business_name,
  stripe_subscription_id,
  stripe_customer_id,
  COALESCE(subscription_status, 'trialing') as subscription_status
FROM profiles
WHERE stripe_subscription_id IS NOT NULL
ON CONFLICT DO NOTHING;
