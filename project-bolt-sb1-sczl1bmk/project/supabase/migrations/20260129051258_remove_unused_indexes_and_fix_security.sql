/*
  # Security Fixes: Remove Unused Indexes and Fix Security Definer View

  ## Changes Made

  ### 1. Remove Unused Indexes
  Removes 26 unused indexes that waste storage and slow down write operations:
    - affiliate_partners: idx_affiliate_partners_user_id
    - appointments: idx_appointments_lead_id, idx_appointments_workspace_id
    - automations: idx_automations_workspace_id
    - bot_execution_logs: idx_bot_execution_logs_bot_type_id, idx_bot_execution_logs_lead_id, idx_bot_execution_logs_workspace_id
    - commission_payouts: idx_commission_payouts_order_id
    - employee_reps: idx_employee_reps_profile_id
    - family_reps: idx_family_reps_profile_id
    - internal_payouts: idx_internal_payouts_family_rep_id, idx_internal_payouts_order_id
    - leads: idx_leads_workspace_id
    - locallink_outbox: idx_locallink_outbox_order_id
    - messages: idx_messages_lead_id, idx_messages_workspace_id
    - orders: idx_orders_profile_id, idx_orders_workspace_id
    - referral_clicks: idx_referral_clicks_partner_id
    - referral_conversions: idx_referral_conversions_order_id, idx_referral_conversions_partner_id
    - vertical_licenses: idx_vertical_licenses_licensee_id, idx_vertical_licenses_vertical_template_id
    - vertical_revenue: idx_vertical_revenue_license_id
    - workspace_bots: idx_workspace_bots_bot_type_id
    - workspaces: idx_workspaces_owner_id

  ### 2. Fix Security Definer View
  Recreates `payout_summary` view with SECURITY INVOKER instead of SECURITY DEFINER
    - SECURITY INVOKER runs with the privileges of the user executing the query
    - This prevents privilege escalation and follows the principle of least privilege

  ## Security Improvements
  - Reduces attack surface by removing unused indexes
  - Fixes potential privilege escalation via SECURITY DEFINER view
  - Improves database performance by reducing write overhead

  ## Manual Configuration Required (Cannot be automated via SQL)
  1. **Auth DB Connection Strategy**: Change from fixed connections to percentage-based in Supabase Dashboard
     - Go to: Database Settings > Connection Pooling
     - Change connection strategy to percentage-based allocation
  
  2. **Leaked Password Protection**: Enable in Supabase Auth settings
     - Go to: Authentication > Settings > Security
     - Enable "Leaked Password Protection" to check against HaveIBeenPwned.org
*/

-- Remove unused indexes
DROP INDEX IF EXISTS idx_affiliate_partners_user_id;
DROP INDEX IF EXISTS idx_appointments_lead_id;
DROP INDEX IF EXISTS idx_appointments_workspace_id;
DROP INDEX IF EXISTS idx_automations_workspace_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_bot_type_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_lead_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_workspace_id;
DROP INDEX IF EXISTS idx_commission_payouts_order_id;
DROP INDEX IF EXISTS idx_employee_reps_profile_id;
DROP INDEX IF EXISTS idx_family_reps_profile_id;
DROP INDEX IF EXISTS idx_internal_payouts_family_rep_id;
DROP INDEX IF EXISTS idx_internal_payouts_order_id;
DROP INDEX IF EXISTS idx_leads_workspace_id;
DROP INDEX IF EXISTS idx_locallink_outbox_order_id;
DROP INDEX IF EXISTS idx_messages_lead_id;
DROP INDEX IF EXISTS idx_messages_workspace_id;
DROP INDEX IF EXISTS idx_orders_profile_id;
DROP INDEX IF EXISTS idx_orders_workspace_id;
DROP INDEX IF EXISTS idx_referral_clicks_partner_id;
DROP INDEX IF EXISTS idx_referral_conversions_order_id;
DROP INDEX IF EXISTS idx_referral_conversions_partner_id;
DROP INDEX IF EXISTS idx_vertical_licenses_licensee_id;
DROP INDEX IF EXISTS idx_vertical_licenses_vertical_template_id;
DROP INDEX IF EXISTS idx_vertical_revenue_license_id;
DROP INDEX IF EXISTS idx_workspace_bots_bot_type_id;
DROP INDEX IF EXISTS idx_workspaces_owner_id;

-- Recreate payout_summary view with SECURITY INVOKER instead of SECURITY DEFINER
DROP VIEW IF EXISTS payout_summary;

CREATE VIEW payout_summary
WITH (security_invoker = true)
AS
SELECT 
  recipient_type,
  recipient_id,
  recipient_name,
  count(*) AS total_orders,
  sum(commission_amount) AS total_earned,
  sum(CASE WHEN status = 'paid' THEN commission_amount ELSE 0 END) AS total_paid,
  sum(CASE WHEN status = 'pending' THEN commission_amount ELSE 0 END) AS total_pending,
  max(paid_at) AS last_payment_date
FROM commission_payouts
GROUP BY recipient_type, recipient_id, recipient_name;

-- Grant appropriate access to the view
GRANT SELECT ON payout_summary TO authenticated;
