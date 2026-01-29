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