/*
  # Optimize RLS Policy Performance

  1. Performance Optimization
    - Wraps auth.uid() calls with (select auth.uid()) to cache the value
    - Prevents re-evaluation of auth.uid() for each row
    - Significantly improves query performance at scale
  
  2. Policies Being Optimized (12 policies across 8 tables)
    - bot_types: Admins can manage bot types
    - commission_payouts: Users can view relevant commission payouts
    - family_reps: Users can view relevant family rep data, Admins can manage family reps
    - internal_payouts: Users can view relevant payouts, Admins can manage payouts
    - vertical_configurations: Users can manage relevant configurations
    - vertical_licenses: Users can view relevant licenses, Admins can manage all licenses
    - vertical_revenue: Users can view relevant revenue
    - vertical_templates: Authenticated users can view templates, Admins can manage vertical templates
  
  3. Performance Impact
    - auth.uid() evaluated once per query instead of once per row
    - Can improve query performance by 10-100x on large result sets
    - No security implications (same access control logic)
*/

-- =====================================================
-- bot_types: Optimize admin check
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- commission_payouts: Optimize multi-role check
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant commission payouts" ON commission_payouts;

CREATE POLICY "Users can view relevant commission payouts"
  ON commission_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    (
      commission_payouts.recipient_type = 'employee'
      AND EXISTS (
        SELECT 1 FROM employee_reps
        WHERE employee_reps.profile_id = (select auth.uid())
        AND employee_reps.id = commission_payouts.recipient_id
      )
    )
    OR
    (
      commission_payouts.recipient_type = 'family_rep'
      AND EXISTS (
        SELECT 1 FROM family_reps
        WHERE family_reps.profile_id = (select auth.uid())
        AND family_reps.id = commission_payouts.recipient_id
      )
    )
  );

-- =====================================================
-- family_reps: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant family rep data" ON family_reps;
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;

CREATE POLICY "Users can view relevant family rep data"
  ON family_reps FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    family_reps.profile_id = (select auth.uid())
  );

CREATE POLICY "Admins can manage family reps"
  ON family_reps FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant payouts" ON internal_payouts;
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;

CREATE POLICY "Users can view relevant payouts"
  ON internal_payouts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM family_reps
      WHERE family_reps.profile_id = (select auth.uid())
      AND family_reps.id = internal_payouts.family_rep_id
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON internal_payouts FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_configurations: Optimize manage policy
-- =====================================================
DROP POLICY IF EXISTS "Users can manage relevant configurations" ON vertical_configurations;

CREATE POLICY "Users can manage relevant configurations"
  ON vertical_configurations FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_configurations.license_id
    )
  );

-- =====================================================
-- vertical_licenses: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant licenses" ON vertical_licenses;
DROP POLICY IF EXISTS "Admins can manage all licenses" ON vertical_licenses;

CREATE POLICY "Users can view relevant licenses"
  ON vertical_licenses FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    vertical_licenses.licensee_id = (select auth.uid())
  );

CREATE POLICY "Admins can manage all licenses"
  ON vertical_licenses FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_revenue: Optimize view policy
-- =====================================================
DROP POLICY IF EXISTS "Users can view relevant revenue" ON vertical_revenue;

CREATE POLICY "Users can view relevant revenue"
  ON vertical_revenue FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM vertical_licenses
      WHERE vertical_licenses.licensee_id = (select auth.uid())
      AND vertical_licenses.id = vertical_revenue.license_id
    )
  );

-- =====================================================
-- vertical_templates: Optimize view and manage policies
-- =====================================================
DROP POLICY IF EXISTS "Authenticated users can view templates" ON vertical_templates;
DROP POLICY IF EXISTS "Admins can manage vertical templates" ON vertical_templates;

CREATE POLICY "Authenticated users can view templates"
  ON vertical_templates FOR SELECT
  TO authenticated
  USING (
    vertical_templates.enabled = true
    OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can manage vertical templates"
  ON vertical_templates FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );
