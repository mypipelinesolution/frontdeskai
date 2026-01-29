/*
  # Fix Security and Performance Issues

  ## Changes Made

  ### 1. Added Missing Indexes on Foreign Keys
  - `bot_execution_logs.bot_type_id`
  - `bot_execution_logs.lead_id`
  - `family_reps.profile_id`
  - `internal_payouts.family_rep_id`
  - `internal_payouts.order_id`
  - `locallink_outbox.order_id`
  - `messages.lead_id`
  - `orders.workspace_id`

  ### 2. Fixed RLS Policies for Performance
  - Wrapped all `auth.uid()` calls with `(select auth.uid())` to prevent re-evaluation per row
  - Updated policies on: profiles, workspaces, leads, messages, automations, orders, family_reps, 
    internal_payouts, locallink_outbox, appointments, bot_types, workspace_bots, bot_execution_logs

  ### 3. Consolidated Multiple Permissive Policies
  - Combined duplicate SELECT policies into single policies with OR conditions

  ### 4. Fixed Function Search Paths
  - Added secure search_path to all functions

  ### 5. Fixed Overly Permissive RLS Policies
  - Restricted appointments creation to require workspace ownership
  - Restricted bot_execution_logs creation to authenticated users with workspace access
*/

-- ================================================
-- 1. ADD MISSING INDEXES ON FOREIGN KEYS
-- ================================================

CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_bot_type_id 
  ON public.bot_execution_logs(bot_type_id);

CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_lead_id 
  ON public.bot_execution_logs(lead_id);

CREATE INDEX IF NOT EXISTS idx_family_reps_profile_id 
  ON public.family_reps(profile_id);

CREATE INDEX IF NOT EXISTS idx_internal_payouts_family_rep_id 
  ON public.internal_payouts(family_rep_id);

CREATE INDEX IF NOT EXISTS idx_internal_payouts_order_id 
  ON public.internal_payouts(order_id);

CREATE INDEX IF NOT EXISTS idx_locallink_outbox_order_id 
  ON public.locallink_outbox(order_id);

CREATE INDEX IF NOT EXISTS idx_messages_lead_id 
  ON public.messages(lead_id);

CREATE INDEX IF NOT EXISTS idx_orders_workspace_id 
  ON public.orders(workspace_id);

-- ================================================
-- 2. FIX RLS POLICIES - PROFILES
-- ================================================

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = (select auth.uid()))
  WITH CHECK (id = (select auth.uid()));

-- ================================================
-- 2. FIX RLS POLICIES - WORKSPACES
-- ================================================

DROP POLICY IF EXISTS "Users can view their own workspaces" ON public.workspaces;
CREATE POLICY "Users can view their own workspaces"
  ON public.workspaces
  FOR SELECT
  TO authenticated
  USING (owner_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can create workspaces" ON public.workspaces;
CREATE POLICY "Users can create workspaces"
  ON public.workspaces
  FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update their own workspaces" ON public.workspaces;
CREATE POLICY "Users can update their own workspaces"
  ON public.workspaces
  FOR UPDATE
  TO authenticated
  USING (owner_id = (select auth.uid()))
  WITH CHECK (owner_id = (select auth.uid()));

-- ================================================
-- 2. FIX RLS POLICIES - LEADS
-- ================================================

DROP POLICY IF EXISTS "Users can view leads in their workspace" ON public.leads;
CREATE POLICY "Users can view leads in their workspace"
  ON public.leads
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create leads in their workspace" ON public.leads;
CREATE POLICY "Users can create leads in their workspace"
  ON public.leads
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update leads in their workspace" ON public.leads;
CREATE POLICY "Users can update leads in their workspace"
  ON public.leads
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - MESSAGES
-- ================================================

DROP POLICY IF EXISTS "Users can view messages in their workspace" ON public.messages;
CREATE POLICY "Users can view messages in their workspace"
  ON public.messages
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create messages in their workspace" ON public.messages;
CREATE POLICY "Users can create messages in their workspace"
  ON public.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - AUTOMATIONS
-- ================================================

DROP POLICY IF EXISTS "Users can view automations in their workspace" ON public.automations;
CREATE POLICY "Users can view automations in their workspace"
  ON public.automations
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can create automations in their workspace" ON public.automations;
CREATE POLICY "Users can create automations in their workspace"
  ON public.automations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update automations in their workspace" ON public.automations;
CREATE POLICY "Users can update automations in their workspace"
  ON public.automations
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - ORDERS
-- ================================================

DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;

CREATE POLICY "Users and admins can view orders"
  ON public.orders
  FOR SELECT
  TO authenticated
  USING (
    profile_id = (select auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - FAMILY REPS
-- ================================================

DROP POLICY IF EXISTS "Family reps can view their own data" ON public.family_reps;
DROP POLICY IF EXISTS "Admins can manage family reps" ON public.family_reps;

CREATE POLICY "Family reps and admins can view family rep data"
  ON public.family_reps
  FOR SELECT
  TO authenticated
  USING (
    profile_id = (select auth.uid())
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage family reps"
  ON public.family_reps
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - INTERNAL PAYOUTS
-- ================================================

DROP POLICY IF EXISTS "Family reps can view their payouts" ON public.internal_payouts;
DROP POLICY IF EXISTS "Admins can manage payouts" ON public.internal_payouts;

CREATE POLICY "Family reps and admins can view payouts"
  ON public.internal_payouts
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.family_reps 
      WHERE id = internal_payouts.family_rep_id 
      AND profile_id = (select auth.uid())
    )
    OR
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage payouts"
  ON public.internal_payouts
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - LOCALLINK OUTBOX
-- ================================================

DROP POLICY IF EXISTS "Admins can view outbox" ON public.locallink_outbox;
DROP POLICY IF EXISTS "Admins can manage outbox" ON public.locallink_outbox;

CREATE POLICY "Admins can manage locallink outbox"
  ON public.locallink_outbox
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - APPOINTMENTS
-- ================================================

DROP POLICY IF EXISTS "Users can view appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can view appointments in their workspace"
  ON public.appointments
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can update appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can update appointments in their workspace"
  ON public.appointments
  FOR UPDATE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

DROP POLICY IF EXISTS "Users can delete appointments in their workspace" ON public.appointments;
CREATE POLICY "Users can delete appointments in their workspace"
  ON public.appointments
  FOR DELETE
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 5. FIX OVERLY PERMISSIVE RLS POLICY - APPOINTMENTS
-- ================================================

DROP POLICY IF EXISTS "Anyone can create appointments" ON public.appointments;
CREATE POLICY "Users can create appointments in their workspace"
  ON public.appointments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - BOT TYPES
-- ================================================

DROP POLICY IF EXISTS "Admins can manage bot types" ON public.bot_types;
DROP POLICY IF EXISTS "Anyone can view bot types" ON public.bot_types;

CREATE POLICY "Anyone can view bot types"
  ON public.bot_types
  FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage bot types"
  ON public.bot_types
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = (select auth.uid()) AND role = 'admin'
    )
  );

-- ================================================
-- 3. CONSOLIDATE MULTIPLE PERMISSIVE POLICIES - WORKSPACE BOTS
-- ================================================

DROP POLICY IF EXISTS "Users can view their workspace bots" ON public.workspace_bots;
DROP POLICY IF EXISTS "Users can manage their workspace bots" ON public.workspace_bots;

CREATE POLICY "Users can view their workspace bots"
  ON public.workspace_bots
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

CREATE POLICY "Users can manage their workspace bots"
  ON public.workspace_bots
  FOR ALL
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  )
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 2. FIX RLS POLICIES - BOT EXECUTION LOGS
-- ================================================

DROP POLICY IF EXISTS "Users can view their bot execution logs" ON public.bot_execution_logs;
CREATE POLICY "Users can view their bot execution logs"
  ON public.bot_execution_logs
  FOR SELECT
  TO authenticated
  USING (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 5. FIX OVERLY PERMISSIVE RLS POLICY - BOT EXECUTION LOGS
-- ================================================

DROP POLICY IF EXISTS "System can insert bot execution logs" ON public.bot_execution_logs;
CREATE POLICY "System can insert bot execution logs"
  ON public.bot_execution_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (
    workspace_id IN (
      SELECT id FROM public.workspaces WHERE owner_id = (select auth.uid())
    )
  );

-- ================================================
-- 4. FIX FUNCTION SEARCH PATHS
-- ================================================

DROP TRIGGER IF EXISTS trigger_auto_activate_bots ON public.workspaces;
DROP TRIGGER IF EXISTS trigger_update_bots_on_tier_change ON public.workspaces;

DROP FUNCTION IF EXISTS public.activate_bots_for_workspace(uuid, text);
DROP FUNCTION IF EXISTS public.get_workspace_bot_count(uuid);
DROP FUNCTION IF EXISTS public.auto_activate_workspace_bots();
DROP FUNCTION IF EXISTS public.update_workspace_bots_on_tier_change();

CREATE FUNCTION public.activate_bots_for_workspace(
  workspace_id_param uuid,
  plan_key_param text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bot_record RECORD;
BEGIN
  FOR bot_record IN 
    SELECT id, number 
    FROM public.bot_types 
    WHERE plan = plan_key_param OR is_add_on = false
    ORDER BY number
  LOOP
    INSERT INTO public.workspace_bots (workspace_id, bot_type_id, is_active)
    VALUES (workspace_id_param, bot_record.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET is_active = true;
  END LOOP;
END;
$$;

CREATE FUNCTION public.get_workspace_bot_count(workspace_id_param uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  bot_count integer;
BEGIN
  SELECT COUNT(*)
  INTO bot_count
  FROM public.workspace_bots
  WHERE workspace_id = workspace_id_param AND is_active = true;
  
  RETURN COALESCE(bot_count, 0);
END;
$$;

CREATE FUNCTION public.auto_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.update_workspace_bots_on_tier_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.subscription_tier IS DISTINCT FROM NEW.subscription_tier THEN
    PERFORM public.activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_auto_activate_bots
  AFTER INSERT ON public.workspaces
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_activate_workspace_bots();

CREATE TRIGGER trigger_update_bots_on_tier_change
  AFTER UPDATE OF subscription_tier ON public.workspaces
  FOR EACH ROW
  EXECUTE FUNCTION public.update_workspace_bots_on_tier_change();