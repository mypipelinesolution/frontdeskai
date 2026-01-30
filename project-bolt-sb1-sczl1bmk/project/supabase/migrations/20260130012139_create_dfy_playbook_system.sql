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
