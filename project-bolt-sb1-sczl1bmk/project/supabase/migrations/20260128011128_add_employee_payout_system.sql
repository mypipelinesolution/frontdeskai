/*
  # Employee Payout System

  ## Overview
  Adds comprehensive payout tracking for both family members (80%) and employees (50%)
  with sync capabilities to Local-Link Marketplace Admin Dashboard.

  ## New Tables
  1. `employee_reps`
     - `id` (uuid, primary key)
     - `profile_id` (uuid, references profiles) - Optional link to user account
     - `name` (text) - Employee name
     - `email` (text) - Contact email
     - `commission_rate` (numeric) - Default 0.50 (50%)
     - `employee_type` (text) - Type: sales, support, developer, etc.
     - `active` (boolean) - Employment status
     - `hired_at` (timestamptz) - Hire date
     - `created_at` (timestamptz)

  2. `commission_payouts`
     - Unified table for all payouts (family + employees)
     - `id` (uuid, primary key)
     - `order_id` (uuid, references orders)
     - `recipient_type` (text) - 'family' or 'employee'
     - `recipient_id` (uuid) - Links to family_reps or employee_reps
     - `recipient_name` (text) - Cached for display
     - `order_amount` (numeric) - Original order amount
     - `commission_rate` (numeric) - Percentage (0.80 or 0.50)
     - `commission_amount` (numeric) - Calculated payout
     - `status` (text) - pending, processing, paid, failed
     - `payment_method` (text) - Method used for payment
     - `paid_at` (timestamptz)
     - `period_start` (timestamptz) - Payment period start
     - `period_end` (timestamptz) - Payment period end
     - `locallink_sync_status` (text) - Sync status to Local-Link
     - `locallink_synced_at` (timestamptz)
     - `notes` (text)
     - `created_at` (timestamptz)

  ## Security
  - Enable RLS on all tables
  - Admin-only access to payout data
  - Employee reps can view their own payout history

  ## Notes
  - Automatically calculates commissions based on order amounts
  - Tracks sync status with Local-Link Marketplace
  - Maintains audit trail of all payments
*/

-- Create employee_reps table
CREATE TABLE IF NOT EXISTS employee_reps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  name text NOT NULL,
  email text NOT NULL,
  commission_rate numeric NOT NULL DEFAULT 0.50,
  employee_type text NOT NULL DEFAULT 'sales' CHECK (employee_type IN ('sales', 'support', 'developer', 'marketing', 'manager', 'other')),
  active boolean DEFAULT true,
  hired_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Create commission_payouts table (replaces and expands internal_payouts)
CREATE TABLE IF NOT EXISTS commission_payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id),
  recipient_type text NOT NULL CHECK (recipient_type IN ('family', 'employee')),
  recipient_id uuid NOT NULL,
  recipient_name text NOT NULL,
  order_amount numeric NOT NULL,
  commission_rate numeric NOT NULL,
  commission_amount numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'paid', 'failed')),
  payment_method text CHECK (payment_method IN ('stripe', 'paypal', 'bank_transfer', 'check', 'cash', 'other')),
  paid_at timestamptz,
  period_start timestamptz NOT NULL,
  period_end timestamptz NOT NULL,
  locallink_sync_status text DEFAULT 'pending' CHECK (locallink_sync_status IN ('pending', 'synced', 'failed')),
  locallink_synced_at timestamptz,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_employee_reps_profile ON employee_reps(profile_id);
CREATE INDEX IF NOT EXISTS idx_employee_reps_active ON employee_reps(active);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_order ON commission_payouts(order_id);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_recipient ON commission_payouts(recipient_type, recipient_id);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_status ON commission_payouts(status);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_period ON commission_payouts(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_commission_payouts_locallink ON commission_payouts(locallink_sync_status);

-- Enable RLS
ALTER TABLE employee_reps ENABLE ROW LEVEL SECURITY;
ALTER TABLE commission_payouts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for employee_reps
CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- RLS Policies for commission_payouts
CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Family reps can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'family' AND
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.id = commission_payouts.recipient_id
      AND family_reps.profile_id = auth.uid()
    )
  );

CREATE POLICY "Employees can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'employee' AND
    EXISTS (
      SELECT 1 FROM employee_reps
      WHERE employee_reps.id = commission_payouts.recipient_id
      AND employee_reps.profile_id = auth.uid()
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Function to automatically create commission payouts when orders are created
CREATE OR REPLACE FUNCTION create_commission_payout()
RETURNS TRIGGER AS $$
DECLARE
  family_rep_record RECORD;
  employee_rep_record RECORD;
  commission_amt numeric;
BEGIN
  -- Check if order has a referral
  IF NEW.referred_by IS NOT NULL THEN
    -- Check if referred by family member
    SELECT fr.*, fr.commission_rate
    INTO family_rep_record
    FROM family_reps fr
    WHERE fr.referral_slug = NEW.referred_by
    AND fr.active = true;

    IF FOUND THEN
      -- Calculate family commission (80% default)
      commission_amt := NEW.amount * family_rep_record.commission_rate;
      
      INSERT INTO commission_payouts (
        order_id,
        recipient_type,
        recipient_id,
        recipient_name,
        order_amount,
        commission_rate,
        commission_amount,
        status,
        period_start,
        period_end
      ) VALUES (
        NEW.id,
        'family',
        family_rep_record.id,
        family_rep_record.name,
        NEW.amount,
        family_rep_record.commission_rate,
        commission_amt,
        'pending',
        NEW.created_at,
        NEW.current_period_end
      );

      -- Also create entry for LocalLink sync
      INSERT INTO locallink_outbox (
        order_id,
        referral_slug,
        amount,
        sync_status
      ) VALUES (
        NEW.id,
        NEW.referred_by,
        commission_amt,
        'pending'
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic commission payout creation
DROP TRIGGER IF EXISTS trigger_create_commission_payout ON orders;
CREATE TRIGGER trigger_create_commission_payout
  AFTER INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_commission_payout();

-- Create view for payout summary
CREATE OR REPLACE VIEW payout_summary AS
SELECT
  recipient_type,
  recipient_id,
  recipient_name,
  COUNT(*) as total_orders,
  SUM(commission_amount) as total_earned,
  SUM(CASE WHEN status = 'paid' THEN commission_amount ELSE 0 END) as total_paid,
  SUM(CASE WHEN status = 'pending' THEN commission_amount ELSE 0 END) as total_pending,
  MAX(paid_at) as last_payment_date
FROM commission_payouts
GROUP BY recipient_type, recipient_id, recipient_name;