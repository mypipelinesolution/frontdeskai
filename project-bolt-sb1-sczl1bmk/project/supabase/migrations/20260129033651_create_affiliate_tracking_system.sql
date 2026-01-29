/*
  # Create Affiliate Partner Tracking System

  1. New Tables
    - `affiliate_partners` - Stores partner information and unique referral codes
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `partner_name` (text)
      - `referral_code` (text, unique)
      - `local_links_partner_id` (text) - Their ID in Local-Links system
      - `local_links_tier` (text) - Their tier in Local-Links (affects commission rate)
      - `commission_rate` (numeric) - Their commission percentage
      - `total_referrals` (integer)
      - `total_revenue` (numeric)
      - `total_commissions` (numeric)
      - `is_active` (boolean)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

    - `referral_clicks` - Tracks every click on referral links
      - `id` (uuid, primary key)
      - `partner_id` (uuid, references affiliate_partners)
      - `referral_code` (text)
      - `ip_address` (text)
      - `user_agent` (text)
      - `utm_source` (text)
      - `utm_campaign` (text)
      - `clicked_at` (timestamptz)

    - `referral_conversions` - Tracks sales from referral links
      - `id` (uuid, primary key)
      - `partner_id` (uuid, references affiliate_partners)
      - `referral_code` (text)
      - `order_id` (uuid, references orders)
      - `stripe_subscription_id` (text)
      - `customer_email` (text)
      - `subscription_tier` (text)
      - `order_amount` (numeric)
      - `commission_amount` (numeric)
      - `commission_rate` (numeric)
      - `commission_status` (text) - pending, sent, paid
      - `local_links_notified` (boolean)
      - `local_links_payload` (jsonb)
      - `converted_at` (timestamptz)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Partners can view their own stats
    - Only authenticated users can become partners
    - Admin can view all partner data
*/

-- Create affiliate_partners table
CREATE TABLE IF NOT EXISTS affiliate_partners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  partner_name text NOT NULL,
  referral_code text UNIQUE NOT NULL,
  local_links_partner_id text,
  local_links_tier text DEFAULT 'basic',
  commission_rate numeric DEFAULT 20.0,
  total_referrals integer DEFAULT 0,
  total_revenue numeric DEFAULT 0,
  total_commissions numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index on referral_code for fast lookups
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_referral_code ON affiliate_partners(referral_code);
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_user_id ON affiliate_partners(user_id);

-- Create referral_clicks table
CREATE TABLE IF NOT EXISTS referral_clicks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  referral_code text NOT NULL,
  ip_address text,
  user_agent text,
  utm_source text,
  utm_campaign text,
  clicked_at timestamptz DEFAULT now()
);

-- Create index for analytics
CREATE INDEX IF NOT EXISTS idx_referral_clicks_partner_id ON referral_clicks(partner_id);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_code ON referral_clicks(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_clicked_at ON referral_clicks(clicked_at);

-- Create referral_conversions table
CREATE TABLE IF NOT EXISTS referral_conversions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid REFERENCES affiliate_partners(id) ON DELETE CASCADE,
  referral_code text NOT NULL,
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  stripe_subscription_id text,
  customer_email text,
  subscription_tier text,
  order_amount numeric NOT NULL,
  commission_amount numeric NOT NULL,
  commission_rate numeric NOT NULL,
  commission_status text DEFAULT 'pending' CHECK (commission_status IN ('pending', 'sent', 'paid', 'failed')),
  local_links_notified boolean DEFAULT false,
  local_links_payload jsonb DEFAULT '{}'::jsonb,
  converted_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create indexes for conversions
CREATE INDEX IF NOT EXISTS idx_referral_conversions_partner_id ON referral_conversions(partner_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_code ON referral_conversions(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_order_id ON referral_conversions(order_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_status ON referral_conversions(commission_status);

-- Enable RLS
ALTER TABLE affiliate_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_conversions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for affiliate_partners
CREATE POLICY "Partners can view own data"
  ON affiliate_partners FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Partners can update own data"
  ON affiliate_partners FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create partner account"
  ON affiliate_partners FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for referral_clicks
CREATE POLICY "Partners can view own clicks"
  ON referral_clicks FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Anyone can insert click tracking"
  ON referral_clicks FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- RLS Policies for referral_conversions
CREATE POLICY "Partners can view own conversions"
  ON referral_conversions FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "System can insert conversions"
  ON referral_conversions FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Function to update partner stats
CREATE OR REPLACE FUNCTION update_partner_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE affiliate_partners
  SET
    total_referrals = total_referrals + 1,
    total_revenue = total_revenue + NEW.order_amount,
    total_commissions = total_commissions + NEW.commission_amount,
    updated_at = now()
  WHERE id = NEW.partner_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update stats on new conversion
DROP TRIGGER IF EXISTS trigger_update_partner_stats ON referral_conversions;
CREATE TRIGGER trigger_update_partner_stats
  AFTER INSERT ON referral_conversions
  FOR EACH ROW
  EXECUTE FUNCTION update_partner_stats();