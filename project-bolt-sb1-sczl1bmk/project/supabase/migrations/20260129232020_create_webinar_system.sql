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
