/*
  # Bot Activation Functions

  1. Functions Created
    - activate_bots_for_workspace: Activates appropriate bots based on plan
    - get_workspace_bot_count: Returns count of active bots
    - upgrade_workspace_bots: Adds bots when plan upgrades
  
  2. Automation
    - Automatically activates bots when workspace is created
    - Updates bots when subscription tier changes
*/

-- Function to activate bots based on workspace subscription tier
CREATE OR REPLACE FUNCTION activate_bots_for_workspace(workspace_id_param uuid, tier_param text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  bot_record RECORD;
BEGIN
  -- Activate CORE bots (all plans get these)
  FOR bot_record IN 
    SELECT id FROM bot_types WHERE category = 'CORE' AND enabled = true
  LOOP
    INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
    VALUES (workspace_id_param, bot_record.id, true)
    ON CONFLICT (workspace_id, bot_type_id) 
    DO UPDATE SET enabled = true, updated_at = now();
  END LOOP;

  -- Activate STARTER bots (starter, core, pro get these)
  IF tier_param IN ('starter', 'core', 'pro') THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'STARTER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate CORE_TIER bots (core, pro get these)
  IF tier_param IN ('core', 'pro') THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'CORE_TIER' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;

  -- Activate ACCELERATOR bots (pro only)
  IF tier_param = 'pro' THEN
    FOR bot_record IN 
      SELECT id FROM bot_types WHERE category = 'ACCELERATOR' AND enabled = true
    LOOP
      INSERT INTO workspace_bots (workspace_id, bot_type_id, enabled)
      VALUES (workspace_id_param, bot_record.id, true)
      ON CONFLICT (workspace_id, bot_type_id) 
      DO UPDATE SET enabled = true, updated_at = now();
    END LOOP;
  END IF;
END;
$$;

-- Function to count active bots for a workspace
CREATE OR REPLACE FUNCTION get_workspace_bot_count(workspace_id_param uuid)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT COUNT(*)::integer
  FROM workspace_bots
  WHERE workspace_id = workspace_id_param AND enabled = true;
$$;

-- Trigger to auto-activate bots when workspace is created
CREATE OR REPLACE FUNCTION auto_activate_workspace_bots()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  RETURN NEW;
END;
$$;

-- Create trigger on workspaces table
DROP TRIGGER IF EXISTS trigger_auto_activate_bots ON workspaces;
CREATE TRIGGER trigger_auto_activate_bots
  AFTER INSERT ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION auto_activate_workspace_bots();

-- Trigger to update bots when subscription tier changes
CREATE OR REPLACE FUNCTION update_workspace_bots_on_tier_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.subscription_tier != OLD.subscription_tier THEN
    PERFORM activate_bots_for_workspace(NEW.id, NEW.subscription_tier);
  END IF;
  RETURN NEW;
END;
$$;

-- Create trigger for tier changes
DROP TRIGGER IF EXISTS trigger_update_bots_on_tier_change ON workspaces;
CREATE TRIGGER trigger_update_bots_on_tier_change
  AFTER UPDATE ON workspaces
  FOR EACH ROW
  WHEN (NEW.subscription_tier IS DISTINCT FROM OLD.subscription_tier)
  EXECUTE FUNCTION update_workspace_bots_on_tier_change();