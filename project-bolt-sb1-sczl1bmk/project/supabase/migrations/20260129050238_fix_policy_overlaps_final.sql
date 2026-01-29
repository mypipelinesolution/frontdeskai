/*
  # Fix Policy Overlaps - Final

  1. Security Optimization
    - Separates admin management policies from view policies
    - Prevents multiple permissive policies for same action
    - Maintains same access control logic
  
  2. Changes Made
    - Split "FOR ALL" policies into separate INSERT, UPDATE, DELETE policies
    - Keep existing SELECT policies separate
    - No overlap for SELECT operations
  
  3. Affected Tables
    - bot_types: Split admin manage policy
    - family_reps: Split admin manage policy
    - internal_payouts: Split admin manage policy
    - vertical_licenses: Split admin manage policy
    - vertical_templates: Split admin manage policy
  
  4. Security Notes
    - Same access control logic maintained
    - No reduction in security
    - Better policy evaluation performance
*/

-- =====================================================
-- bot_types: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage bot types" ON bot_types;

CREATE POLICY "Admins can insert bot types"
  ON bot_types FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update bot types"
  ON bot_types FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete bot types"
  ON bot_types FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- family_reps: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage family reps" ON family_reps;

CREATE POLICY "Admins can insert family reps"
  ON family_reps FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update family reps"
  ON family_reps FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete family reps"
  ON family_reps FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- internal_payouts: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage payouts" ON internal_payouts;

CREATE POLICY "Admins can insert payouts"
  ON internal_payouts FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update payouts"
  ON internal_payouts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete payouts"
  ON internal_payouts FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_licenses: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage all licenses" ON vertical_licenses;

CREATE POLICY "Admins can insert licenses"
  ON vertical_licenses FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update licenses"
  ON vertical_licenses FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete licenses"
  ON vertical_licenses FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- vertical_templates: Split ALL into INSERT, UPDATE, DELETE
-- =====================================================
DROP POLICY IF EXISTS "Admins can manage vertical templates" ON vertical_templates;

CREATE POLICY "Admins can insert templates"
  ON vertical_templates FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update templates"
  ON vertical_templates FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete templates"
  ON vertical_templates FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = (select auth.uid())
      AND profiles.role = 'admin'
    )
  );
