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