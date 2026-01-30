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