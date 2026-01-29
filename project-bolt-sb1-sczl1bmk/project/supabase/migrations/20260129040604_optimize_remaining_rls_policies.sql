/*
  # Optimize Remaining RLS Policies

  1. Performance Optimizations
    - Fix nested auth.jwt() calls that still re-evaluate per row
    - Use EXISTS with single auth call for better performance
    - Fix function search paths

  2. Changes
    - Optimize employee_reps policies (3)
    - Optimize demo_requests policies (1)
    - Optimize commission_payouts policies (3)
    - Optimize vertical_templates policies (1)
    - Optimize vertical_licenses policies (1)
    - Optimize vertical_configurations policies (1)
    - Optimize vertical_revenue policies (1)
    - Fix function search paths
*/

-- Optimize demo_requests policies
DROP POLICY IF EXISTS "Admins can update demo requests" ON demo_requests;

CREATE POLICY "Admins can update demo requests"
  ON demo_requests FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
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
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can insert employee reps"
  ON employee_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can update employee reps"
  ON employee_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize commission_payouts policies
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can insert commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Admins can update commission payouts" ON commission_payouts;

CREATE POLICY "Admins can view all commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can insert commission payouts"
  ON commission_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

CREATE POLICY "Admins can update commission payouts"
  ON commission_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_templates policies
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admin can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_licenses policies
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;

CREATE POLICY "Admin can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_configurations policies
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;

CREATE POLICY "Admin can manage all configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Optimize vertical_revenue policies
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;

CREATE POLICY "Admin can view all revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE role = 'admin' 
      AND email = (SELECT (auth.jwt()->>'email')::text)
    )
  );

-- Fix function search paths using proper signature lookup
DO $$
DECLARE
  func_signature text;
BEGIN
  -- Fix update_demo_requests_updated_at
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'update_demo_requests_updated_at' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION update_demo_requests_updated_at(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix update_partner_stats
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'update_partner_stats' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION update_partner_stats(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix activate_workspace_bots
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'activate_workspace_bots' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION activate_workspace_bots(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix trigger_activate_workspace_bots
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'trigger_activate_workspace_bots' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION trigger_activate_workspace_bots(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix generate_license_key
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'generate_license_key' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION generate_license_key(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix create_vertical_license
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'create_vertical_license' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION create_vertical_license(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;

  -- Fix create_commission_payout
  SELECT pg_get_function_identity_arguments(oid) INTO func_signature
  FROM pg_proc WHERE proname = 'create_commission_payout' AND pronamespace = 'public'::regnamespace;
  
  IF func_signature IS NOT NULL THEN
    EXECUTE format('ALTER FUNCTION create_commission_payout(%s) SET search_path = pg_catalog, public', func_signature);
  END IF;
END $$;