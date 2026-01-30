/*
  # Create Bot Response Library System

  1. New Tables
    - `bot_response_library`
      - `id` (uuid, primary key)
      - `industry` (text) - cleaning, tree, medspa, contractor, realestate, universal
      - `category` (text) - greeting, booking, objection, closing, upsell, dfy
      - `intent` (text) - specific intent/scenario
      - `response` (text) - the actual bot response
      - `priority` (int) - for ordering responses
      - `active` (boolean) - enable/disable responses
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `bot_response_library` table
    - Allow authenticated users to read responses
    - Only workspace owners can modify responses

  3. Indexes
    - Index on industry + category + intent for fast lookups
    - Index on active for filtering
*/

-- Create bot response library table
CREATE TABLE IF NOT EXISTS bot_response_library (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  industry text NOT NULL,
  category text NOT NULL,
  intent text NOT NULL,
  response text NOT NULL,
  priority int DEFAULT 1,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_bot_response_lookup
  ON bot_response_library(industry, category, intent)
  WHERE active = true;

CREATE INDEX IF NOT EXISTS idx_bot_response_active
  ON bot_response_library(active);

-- Enable RLS
ALTER TABLE bot_response_library ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can read active bot responses"
  ON bot_response_library FOR SELECT
  TO authenticated
  USING (active = true);

CREATE POLICY "Workspace owners can manage bot responses"
  ON bot_response_library FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM workspaces
      WHERE workspaces.owner_id = auth.uid()
    )
  );

-- Seed universal responses
INSERT INTO bot_response_library (industry, category, intent, response, priority) VALUES
  -- Universal greetings
  ('universal', 'greeting', 'initial', 'Hi! This is FrontDesk AI Pro. How can I help you today?', 1),
  ('universal', 'greeting', 'speed_assurance', 'I can help you right now — no waiting, no call backs.', 2),

  -- Universal lead capture
  ('universal', 'lead_capture', 'get_info', 'I can get this scheduled for you. What is your name and best number?', 1),
  ('universal', 'lead_capture', 'soft_close', 'Want me to take care of this for you now?', 2),

  -- Universal checkout
  ('universal', 'checkout', 'offer', 'I can activate this for you today so you stop missing leads. Would you like Starter or Core?', 1),
  ('universal', 'checkout', 'roi_framing', 'Most clients cover the cost with just one or two recovered leads.', 2),

  -- Universal handoff
  ('universal', 'handoff', 'to_human', 'I will notify the owner and have them follow up shortly.', 1),

  -- Universal objections
  ('universal', 'objection', 'need_to_think', 'Totally understand. What question can I answer right now to help you decide?', 1),
  ('universal', 'objection', 'busy', 'That is exactly why most owners use this — it works while you are working.', 2),
  ('universal', 'objection', 'not_techy', 'No worries — we handle everything for you.', 3),
  ('universal', 'objection', 'will_it_work', 'Yes — it is trained on your business and customized for your industry.', 4),

  -- Universal DFY
  ('universal', 'dfy', 'intro', 'If you would rather have this fully set up for you, our DFY team can handle everything.', 1),
  ('universal', 'dfy', 'value', 'We configure your funnels, campaigns, and automations so you do not have to.', 2),
  ('universal', 'dfy', 'price', 'DFY starts at $497/month and includes ongoing optimization.', 3),
  ('universal', 'dfy', 'close', 'Would you like DFY or the Core plan?', 4),

  -- Cleaning industry
  ('cleaning', 'inquiry', 'pricing', 'Sure! We offer standard, deep, and move-out cleanings. What size home are you looking to have cleaned?', 1),
  ('cleaning', 'booking', 'schedule', 'I can book your cleaning in under a minute. What day works best?', 1),
  ('cleaning', 'objection', 'too_expensive', 'Many clients say that at first, but most find it pays for itself quickly by filling empty spots.', 1),
  ('cleaning', 'review', 'request', 'Thanks for choosing us! Would you mind leaving a quick review? It helps a lot.', 1),
  ('cleaning', 'upsell', 'recurring', 'We also offer recurring cleanings if you would like priority scheduling.', 1),

  -- Tree service
  ('tree', 'emergency', 'urgent', 'That sounds urgent. I can schedule a priority visit. Can I get your address and a photo?', 1),
  ('tree', 'estimate', 'schedule', 'I will gather a few details and set up your free estimate.', 1),
  ('tree', 'followup', 'storm', 'We are helping several homeowners today. Want me to reserve you a spot?', 1),
  ('tree', 'objection', 'insurance', 'Most storm jobs are covered by insurance — we can help with that.', 1),
  ('tree', 'closing', 'confirm', 'Shall I lock in your estimate appointment?', 1),

  -- Med spa / beauty
  ('medspa', 'inquiry', 'treatment', 'Yes, we offer that service. May I ask what result you are hoping for?', 1),
  ('medspa', 'booking', 'schedule', 'I see openings this week. Want morning or afternoon?', 1),
  ('medspa', 'objection', 'hesitation', 'Many clients start with a consultation first. Would you like me to book that?', 1),
  ('medspa', 'upsell', 'packages', 'We also have packages that save money long-term.', 1),
  ('medspa', 'review', 'request', 'We would love your feedback! Here is a quick link for you.', 1),

  -- Contractor
  ('contractor', 'inquiry', 'quote', 'I can help you get a fast estimate. Can you share a photo and address?', 1),
  ('contractor', 'booking', 'schedule', 'Our next available visit is soon. Would that work for you?', 1),
  ('contractor', 'objection', 'price', 'We focus on quality and reliability, not just lowest price.', 1),
  ('contractor', 'followup', 'check_in', 'Just checking in — would you like me to move forward with your estimate?', 1),
  ('contractor', 'closing', 'confirm', 'Want me to lock this in now?', 1),

  -- Real estate
  ('realestate', 'inquiry', 'listing', 'I can schedule a showing for you. Are you pre-approved yet?', 1),
  ('realestate', 'qualification', 'buyer', 'What price range are you comfortable with?', 1),
  ('realestate', 'inquiry', 'seller', 'We offer free home valuations. Would you like one?', 1),
  ('realestate', 'nurture', 'followup', 'I will keep you updated with new listings that match.', 1),
  ('realestate', 'closing', 'showing', 'Should I book your showing?', 1),

  -- Local-Link Deals (optional mention)
  ('universal', 'deals', 'intro', 'We also offer Local-Link Deals, where you can sell a discounted offer and get paid upfront. It is a great way to bring in new customers fast.', 1),
  ('universal', 'deals', 'example', 'For example, you could offer a $40 service for $20. Customers buy it on Local-Link, and many come back at full price.', 2),
  ('universal', 'deals', 'objection', 'Most businesses use deals to bring in first-time customers, then turn them into repeat clients.', 3),
  ('universal', 'deals', 'dfy', 'If you would like, our DFY team can build and launch your first deal for you.', 4),
  ('universal', 'deals', 'close', 'Want me to help you activate your first deal?', 5);
