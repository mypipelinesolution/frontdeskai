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