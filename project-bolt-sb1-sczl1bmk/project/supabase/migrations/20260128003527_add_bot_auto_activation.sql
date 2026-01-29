/*
  # Bot Auto-Activation System

  1. Changes
    - Creates function to auto-activate bots when workspace is created/upgraded
    - Creates trigger to automatically enable appropriate bots based on subscription tier
    - Ensures all purchased bots are immediately available to customers

  2. Bot Activation Logic
    - Starter plan: Activates CORE + STARTER bots (9 total)
    - Core plan: Activates CORE + STARTER + CORE_TIER bots (15 total)
    - Pro plan: Activates CORE + STARTER + CORE_TIER + ACCELERATOR bots (22 total)
    - DFY is manual activation by admin
    - ADD_ON bots require separate purchase

  3. Security
    - Function runs with security definer privileges
    - Only activates bots user is entitled to based on subscription
*/

-- Function to activate bots for a workspace based on subscription tier
CREATE OR REPLACE FUNCTION activate_workspace_bots(p_workspace_id uuid, p_subscription_tier text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_bot_type RECORD;
BEGIN
  -- Activate CORE bots (all plans get these)
  FOR v_bot_type IN 
    SELECT id FROM bot_types WHERE category = 'CORE' AND enabled = true
  LOOP
    INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
    VALUES (p_workspace_id, v_bot_type.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET enabled = true, updated_at = now();
  END LOOP;

  -- Activate STARTER bots for starter, core, and pro plans
  IF p_subscription_tier IN ('starter', 'core', 'pro') THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'STARTER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate CORE_TIER bots for core and pro plans
  IF p_subscription_tier IN ('core', 'pro') THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'CORE_TIER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate ACCELERATOR bots for pro plan only
  IF p_subscription_tier = 'pro' THEN
    FOR v_bot_type IN 
      SELECT id FROM bot_types WHERE category = 'ACCELERATOR' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (p_workspace_id, v_bot_type.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;
END;
$$;

-- Trigger function to auto-activate bots on workspace creation
CREATE OR REPLACE FUNCTION trigger_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only activate if subscription is active and tier is set
  IF NEW.subscription_status = 'active' AND NEW.subscription_tier IS NOT NULL THEN
    PERFORM activate_workspace_bots(NEW.id, NEW.subscription_tier);
  END IF;
  
  RETURN NEW;
END;
$$;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_workspace_created_activate_bots ON workspaces;
DROP TRIGGER IF EXISTS on_workspace_updated_activate_bots ON workspaces;

-- Create trigger for new workspaces
CREATE TRIGGER on_workspace_created_activate_bots
  AFTER INSERT ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION trigger_activate_workspace_bots();

-- Create trigger for workspace upgrades/changes
CREATE TRIGGER on_workspace_updated_activate_bots
  AFTER UPDATE OF subscription_tier, subscription_status ON workspaces
  FOR EACH ROW
  WHEN (NEW.subscription_status = 'active')
  EXECUTE FUNCTION trigger_activate_workspace_bots();

-- Activate bots for existing active workspaces
DO $$
DECLARE
  v_workspace RECORD;
BEGIN
  FOR v_workspace IN 
    SELECT id, subscription_tier 
    FROM workspaces 
    WHERE subscription_status = 'active' AND subscription_tier IS NOT NULL
  LOOP
    PERFORM activate_workspace_bots(v_workspace.id, v_workspace.subscription_tier);
  END LOOP;
END;
$$;
