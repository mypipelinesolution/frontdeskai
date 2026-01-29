/*
  # Consolidate Redundant RLS Policies (Corrected)

  1. Policy Optimization
    - Consolidates overlapping policies where safe to do so
    - Maintains multi-tenant security model
    - Improves policy evaluation performance
  
  2. Changes Made
    - bot_types: Merge view policies into single comprehensive policy
    - workspace_bots: Remove redundant SELECT policy (covered by manage policy)
    - commission_payouts: Consolidate role-based SELECT policies
    - family_reps: Merge overlapping SELECT policies
    - internal_payouts: Consolidate view policies
    - vertical_configurations: Merge admin and licensee policies
    - vertical_licenses: Consolidate SELECT policies
    - vertical_revenue: Consolidate SELECT policies
    - vertical_templates: Merge view policies
  
  3. Security Notes
    - All policies maintain proper authentication checks
    - Multi-role access patterns preserved using OR conditions
    - No reduction in security posture
*/

-- =====================================================
-- bot_types: Consolidate view policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;
DROP POLICY IF EXISTS "Anyone can view bot types" ON bot_types;

CREATE POLICY "Authenticated users can view bot types"
  ON bot_types FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- workspace_bots: Remove redundant SELECT policy
-- =====================================================
DROP POLICY IF EXISTS "Users can view their workspace bots" ON workspace_bots;
-- Keep "Users can manage their workspace bots" (covers ALL including SELECT)

-- =====================================================
-- commission_payouts: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can view all commission payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Employees can view own payouts" ON commission_payouts;
DROP POLICY IF EXISTS "Family reps can view own payouts" ON commission_payouts;

CREATE POLICY "Users can view relevant commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Employees see their own
    (
      commission_payouts.recipient_type = 'employee'
      AND EXISTS (
        SELECT 1 FROM employee_reps
        WHERE employee_reps.profile_id = auth.uid()
        AND employee_reps.id = commission_payouts.recipient_id
      )
    )
    OR
    -- Family reps see their own
    (
      commission_payouts.recipient_type = 'family_rep'
      AND EXISTS (
        SELECT 1 FROM family_reps
        WHERE family_reps.profile_id = auth.uid()
        AND family_reps.id = commission_payouts.recipient_id
      )
    )
  );

-- =====================================================
-- family_reps: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;
DROP POLICY IF EXISTS "Family reps and admins can view family rep data" ON family_reps;

CREATE POLICY "Users can view relevant family rep data"
  ON family_reps FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Family reps see their own data
    family_reps.profile_id = auth.uid()
  );

CREATE POLICY "Admins can manage family reps"
  ON family_reps FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;
DROP POLICY IF EXISTS "Family reps and admins can view payouts" ON internal_payouts;

CREATE POLICY "Users can view relevant payouts"
  ON internal_payouts FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Family reps see their own
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.profile_id = auth.uid()
      AND family_reps.id = internal_payouts.family_rep_id
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON internal_payouts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_configurations: Consolidate admin and licensee policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage all configurations" ON vertical_configurations;
DROP POLICY IF EXISTS "Licensee can manage own configuration" ON vertical_configurations;

CREATE POLICY "Users can manage relevant configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    -- Admins manage all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees manage their own
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  )
  WITH CHECK (
    -- Same check for modifications
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  );

-- =====================================================
-- vertical_licenses: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage all licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Licensee can view own license" ON vertical_licenses;

CREATE POLICY "Users can view relevant licenses"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees see their own
    vertical_licenses.licensee_id = auth.uid()
  );

CREATE POLICY "Admins can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_revenue: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can view all revenue" ON vertical_revenue;
DROP POLICY IF EXISTS "Licensee can view own revenue" ON vertical_revenue;

CREATE POLICY "Users can view relevant revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    -- Admins see all
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Licensees see their own
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = auth.uid()
      AND vertical_licenses.id = vertical_revenue.license_id
    )
  );

-- =====================================================
-- vertical_templates: Consolidate SELECT policies
-- =====================================================
DROP POLICY IF EXISTS "Admin can manage vertical templates" ON vertical_templates;
DROP POLICY IF EXISTS "Anyone can view enabled templates" ON vertical_templates;

CREATE POLICY "Authenticated users can view templates"
  ON vertical_templates FOR SELECT
  TO authenticated
  USING (
    -- Everyone sees enabled templates
    vertical_templates.enabled = true
    OR
    -- Admins see all templates
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );
