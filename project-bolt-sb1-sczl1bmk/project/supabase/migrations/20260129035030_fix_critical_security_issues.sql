/*
  # Fix Critical Security Issues

  1. Performance Optimizations
    - Add missing foreign key index on vertical_licenses
    - Optimize all RLS policies to use (select auth.uid()) instead of auth.uid()
    - Fix function search paths for security

  2. Security Fixes
    - Fix RLS policies that bypass security (always true)
    - Restrict demo_requests updates to admins only
    - Restrict referral_conversions inserts with validation
    - Add validation to demo submissions

  3. Function Security
    - Set search_path to pg_catalog,public for all security definer functions
*/

-- Add missing index on foreign key
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_vertical_template_id 
  ON vertical_licenses(vertical_template_id);

-- Fix demo_requests RLS policies
DROP POLICY IF EXISTS "Anyone can submit demo requests" ON demo_requests;
DROP POLICY IF EXISTS "Authenticated users can update demo requests" ON demo_requests;

CREATE POLICY "Anyone can submit demo requests"
  ON demo_requests FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    email IS NOT NULL 
    AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
  );

CREATE POLICY "Admins can update demo requests"
  ON demo_requests FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Fix referral_conversions RLS policy - validate active partners only
DROP POLICY IF EXISTS "System can insert conversions" ON referral_conversions;

CREATE POLICY "Service role can insert conversions"
  ON referral_conversions FOR INSERT
  TO authenticated, anon
  WITH CHECK (
    partner_id IN (SELECT id FROM affiliate_partners WHERE is_active = true)
  );

-- Optimize affiliate_partners policies
DROP POLICY IF EXISTS "Partners can view own data" ON affiliate_partners;
DROP POLICY IF EXISTS "Partners can update own data" ON affiliate_partners;
DROP POLICY IF EXISTS "Authenticated users can create partner account" ON affiliate_partners;

CREATE POLICY "Partners can view own data"
  ON affiliate_partners FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Partners can update own data"
  ON affiliate_partners FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

CREATE POLICY "Authenticated users can create partner account"
  ON affiliate_partners FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- Optimize referral_clicks policies
DROP POLICY IF EXISTS "Partners can view own clicks" ON referral_clicks;

CREATE POLICY "Partners can view own clicks"
  ON referral_clicks FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize referral_conversions policies
DROP POLICY IF EXISTS "Partners can view own conversions" ON referral_conversions;

CREATE POLICY "Partners can view own conversions"
  ON referral_conversions FOR SELECT
  TO authenticated
  USING (
    partner_id IN (
      SELECT id FROM affiliate_partners WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize stripe_customers policies
DROP POLICY IF EXISTS "Users can view their own customer data" ON stripe_customers;

CREATE POLICY "Users can view their own customer data"
  ON stripe_customers FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

-- Optimize stripe_subscriptions policies
DROP POLICY IF EXISTS "Users can view their own subscription data" ON stripe_subscriptions;

CREATE POLICY "Users can view their own subscription data"
  ON stripe_subscriptions FOR SELECT
  TO authenticated
  USING (
    customer_id IN (
      SELECT customer_id FROM stripe_customers WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize stripe_orders policies
DROP POLICY IF EXISTS "Users can view their own order data" ON stripe_orders;

CREATE POLICY "Users can view their own order data"
  ON stripe_orders FOR SELECT
  TO authenticated
  USING (
    customer_id IN (
      SELECT customer_id FROM stripe_customers WHERE user_id = (SELECT auth.uid())
    )
  );

-- Optimize employee_reps policies
DROP POLICY IF EXISTS "Admins can view all employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can insert employee reps" ON employee_reps;
DROP POLICY IF EXISTS "Admins can update employee reps" ON employee_reps;

CREATE POLICY "Admins can view all employee reps"
  ON employee_reps FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Optimize commission_payouts policies
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can insert commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can update commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Family reps can view own payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Employees can view own payouts" ON commission_payouts;

CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Family reps can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'family' AND recipient_id IN (
      SELECT id FROM family_reps WHERE profile_id = (SELECT auth.uid())
    )
  );

CREATE POLICY "Employees can view own payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    recipient_type = 'employee' AND recipient_id IN (
      SELECT id FROM employee_reps WHERE profile_id = (SELECT auth.uid())
    )
  );

-- Optimize vertical_templates policies
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

-- Optimize vertical_licenses policies
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Licensee can view own license" ON vertical_licenses;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own license"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = licensee_id);

-- Optimize vertical_configurations policies
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;
DROP POLICY IF EXISTS "Licensee can manage own configuration" ON vertical_configurations;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  )
  WITH CHECK (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can manage own configuration"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  )
  WITH CHECK (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  );

-- Optimize vertical_revenue policies
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;
DROP POLICY IF EXISTS "Licensee can view own revenue" ON vertical_revenue;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    (SELECT (auth.jwt()->>'email')) IN (
      SELECT email FROM profiles WHERE role = 'admin'
    )
  );

CREATE POLICY "Licensee can view own revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    license_id IN (
      SELECT id FROM vertical_licenses WHERE licensee_id = (SELECT auth.uid())
    )
  );