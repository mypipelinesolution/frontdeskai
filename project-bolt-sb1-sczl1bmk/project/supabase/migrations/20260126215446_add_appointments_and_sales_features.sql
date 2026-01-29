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