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