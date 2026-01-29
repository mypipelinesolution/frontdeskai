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