/*
  # Create Partner Certification System

  1. New Tables
    - `partner_cert_modules` - Training module content
    - `partner_cert_progress` - Partner progress through modules
    - `partner_cert_exams` - Exam questions
    - `partner_cert_results` - Exam results
    - `partner_pitch_reviews` - Practice pitch submissions
    - `partner_cert_renewals` - Annual recertification
    - `partner_funnels` - Partner micro-funnels
    - `partner_funnel_stats` - Funnel analytics

  2. Partner Status Fields
    - Add certification fields to affiliate_partners table

  3. Security
    - Enable RLS on all tables
    - Partners can only see their own data

  4. Indexes
    - Index on partner_id for fast lookups
*/

-- Create certification modules table
CREATE TABLE IF NOT EXISTS partner_cert_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_number int NOT NULL UNIQUE,
  title text NOT NULL,
  description text,
  video_url text,
  content jsonb DEFAULT '{}'::jsonb,
  quiz_questions jsonb DEFAULT '[]'::jsonb,
  passing_score int DEFAULT 80,
  order_index int NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create partner progress table
CREATE TABLE IF NOT EXISTS partner_cert_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES partner_cert_modules(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  score int,
  attempts int DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(partner_id, module_id)
);

-- Create certification exams table
CREATE TABLE IF NOT EXISTS partner_cert_exams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  passing_score int DEFAULT 85,
  time_limit_minutes int DEFAULT 60,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create exam results table
CREATE TABLE IF NOT EXISTS partner_cert_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  exam_id uuid NOT NULL REFERENCES partner_cert_exams(id) ON DELETE CASCADE,
  score int NOT NULL,
  passed boolean NOT NULL,
  answers jsonb NOT NULL DEFAULT '{}'::jsonb,
  started_at timestamptz NOT NULL,
  completed_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create pitch reviews table
CREATE TABLE IF NOT EXISTS partner_pitch_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  pitch_type text DEFAULT 'video',
  pitch_url text,
  pitch_text text,
  status text DEFAULT 'pending',
  score int,
  feedback text,
  reviewed_by uuid,
  reviewed_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Create certification renewals table
CREATE TABLE IF NOT EXISTS partner_cert_renewals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  renewal_date date NOT NULL,
  completed_at timestamptz,
  score int,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Create partner funnels table
CREATE TABLE IF NOT EXISTS partner_funnels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  funnel_slug text NOT NULL UNIQUE,
  funnel_name text NOT NULL,
  partner_bio text,
  partner_photo_url text,
  custom_headline text,
  testimonials jsonb DEFAULT '[]'::jsonb,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create partner funnel stats table
CREATE TABLE IF NOT EXISTS partner_funnel_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  funnel_id uuid NOT NULL REFERENCES partner_funnels(id) ON DELETE CASCADE,
  date date NOT NULL DEFAULT CURRENT_DATE,
  views int DEFAULT 0,
  conversions int DEFAULT 0,
  revenue numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(funnel_id, date)
);

-- Add certification fields to affiliate_partners table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'is_certified'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN is_certified boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_level'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_level text DEFAULT 'none';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_date'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_date timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'cert_expires_at'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN cert_expires_at timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'affiliate_partners' AND column_name = 'community_role'
  ) THEN
    ALTER TABLE affiliate_partners ADD COLUMN community_role text DEFAULT 'member';
  END IF;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_partner_progress_partner
  ON partner_cert_progress(partner_id);

CREATE INDEX IF NOT EXISTS idx_cert_results_partner
  ON partner_cert_results(partner_id);

CREATE INDEX IF NOT EXISTS idx_pitch_reviews_partner
  ON partner_pitch_reviews(partner_id);

CREATE INDEX IF NOT EXISTS idx_cert_renewals_partner
  ON partner_cert_renewals(partner_id);

CREATE INDEX IF NOT EXISTS idx_partner_funnels_partner
  ON partner_funnels(partner_id);

CREATE INDEX IF NOT EXISTS idx_partner_funnels_slug
  ON partner_funnels(funnel_slug);

CREATE INDEX IF NOT EXISTS idx_affiliate_partners_certified
  ON affiliate_partners(is_certified)
  WHERE is_certified = true;

-- Enable RLS
ALTER TABLE partner_cert_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_pitch_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_cert_renewals ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_funnels ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_funnel_stats ENABLE ROW LEVEL SECURITY;

-- Policies for modules (public read for authenticated)
CREATE POLICY "Partners can read active modules"
  ON partner_cert_modules FOR SELECT
  TO authenticated
  USING (active = true);

-- Policies for progress
CREATE POLICY "Partners can read own progress"
  ON partner_cert_progress FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can create own progress"
  ON partner_cert_progress FOR INSERT
  TO authenticated
  WITH CHECK (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can update own progress"
  ON partner_cert_progress FOR UPDATE
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for exams
CREATE POLICY "Partners can read active exams"
  ON partner_cert_exams FOR SELECT
  TO authenticated
  USING (active = true);

-- Policies for results
CREATE POLICY "Partners can read own results"
  ON partner_cert_results FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

CREATE POLICY "Partners can insert own results"
  ON partner_cert_results FOR INSERT
  TO authenticated
  WITH CHECK (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for pitch reviews
CREATE POLICY "Partners can manage own pitches"
  ON partner_pitch_reviews FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for renewals
CREATE POLICY "Partners can read own renewals"
  ON partner_cert_renewals FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for funnels
CREATE POLICY "Anyone can read active funnels"
  ON partner_funnels FOR SELECT
  TO anon, authenticated
  USING (active = true);

CREATE POLICY "Partners can manage own funnels"
  ON partner_funnels FOR ALL
  TO authenticated
  USING (
    partner_id IN (
      SELECT ap.id FROM affiliate_partners ap WHERE ap.user_id = auth.uid()
    )
  );

-- Policies for funnel stats
CREATE POLICY "Partners can read own funnel stats"
  ON partner_funnel_stats FOR SELECT
  TO authenticated
  USING (
    funnel_id IN (
      SELECT pf.id FROM partner_funnels pf
      JOIN affiliate_partners ap ON pf.partner_id = ap.id
      WHERE ap.user_id = auth.uid()
    )
  );

-- Seed certification modules
INSERT INTO partner_cert_modules (module_number, title, description, order_index, quiz_questions) VALUES
  (1, 'Platform Overview', 'What You are Selling - FrontDesk AI Pro ecosystem and value proposition', 1, 
   '[{"q": "What is FrontDesk AI Pro?", "options": ["An AI operations team", "Just a chatbot", "A CRM only"], "correct": 0}]'::jsonb),
  (2, 'Product Mastery', 'Know Every Plan - Deep dive into Starter, Core, Accelerator, and DFY', 2,
   '[{"q": "Which plan includes call answering?", "options": ["Starter", "Core", "Accelerator"], "correct": 2}]'::jsonb),
  (3, 'Ideal Customers', 'Who Converts - Best industries, company size, and red flags', 3,
   '[{"q": "Best customer type?", "options": ["Enterprise only", "Local service businesses", "Ecommerce"], "correct": 1}]'::jsonb),
  (4, 'Sales System', 'How Deals Close - Bot-first selling and when to intervene', 4,
   '[{"q": "When should a partner jump in?", "options": ["Immediately", "Only if bot escalates", "Never"], "correct": 1}]'::jsonb),
  (5, 'Advertising Playbook', 'Traffic Engine - How to drive leads with $20/day budget', 5,
   '[{"q": "Starting ad budget?", "options": ["$5/day", "$20/day", "$100/day"], "correct": 1}]'::jsonb),
  (6, 'Compliance & Brand', 'Protect the Brand - What you can and cannot promise', 6,
   '[{"q": "Can you promise specific profits?", "options": ["Yes", "No", "Sometimes"], "correct": 1}]'::jsonb),
  (7, 'Referrals & Payouts', 'How You Get Paid - Tracking, attribution, and Local-Link', 7,
   '[{"q": "Where are commissions calculated?", "options": ["FrontDesk", "Local-Link", "Stripe"], "correct": 1}]'::jsonb),
  (8, 'Scaling', 'From 1 Client to 50 - Reinvestment and growth strategies', 8,
   '[{"q": "Best way to scale?", "options": ["Buy more ads randomly", "Reinvest ad profits", "Wait and hope"], "correct": 1}]'::jsonb);

-- Seed final certification exam
INSERT INTO partner_cert_exams (title, description, questions, passing_score) VALUES
  ('Partner Certification Final Exam', 'Comprehensive test covering all 8 modules', 
   '[
     {"q": "What is FrontDesk AI Pro?", "options": ["CRM software", "AI operations team", "Email tool"], "correct": 1},
     {"q": "Which plan is for busy owners who want full setup?", "options": ["Starter", "Core", "DFY"], "correct": 2},
     {"q": "Where are commissions calculated?", "options": ["FrontDesk", "Local-Link", "Manually"], "correct": 1},
     {"q": "Starting ad budget recommendation?", "options": ["$5", "$20", "$100"], "correct": 1},
     {"q": "Can you promise income?", "options": ["Yes", "No", "Sometimes"], "correct": 1}
   ]'::jsonb, 
   85);
