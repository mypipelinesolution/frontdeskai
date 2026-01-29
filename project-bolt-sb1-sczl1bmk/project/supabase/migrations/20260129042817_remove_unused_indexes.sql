/*
  # Remove Unused Indexes

  1. Performance Optimization
    - Removes 50 unused indexes to reduce storage overhead
    - Reduces index maintenance cost on writes
    - Can be re-added later based on actual query patterns
  
  2. Important Notes
    - These indexes were added proactively for foreign keys and expected queries
    - Monitor production query performance and re-add specific indexes as needed
    - Foreign key constraints remain intact (only indexes removed)
    
  3. Indexes Being Removed
    - Demo requests: created_at, status, email
    - Bot execution logs: bot_type_id, lead_id, workspace_id, created_at
    - Family reps: profile_id, referral_slug
    - Internal payouts: family_rep_id, order_id
    - LocalLink outbox: order_id, sync_status
    - Messages: lead_id, workspace_id
    - Orders: workspace_id, profile_id, referred_by
    - Vertical licenses: licensee, status, subdomain, vertical_template_id
    - Vertical revenue: license, period
    - Referral clicks: partner_id, code, clicked_at
    - Referral conversions: partner_id, code, order_id, status
    - Employee reps: profile, active
    - Commission payouts: order, recipient, status, period, locallink
    - Affiliate partners: referral_code, user_id
    - Workspaces: owner_id
    - Leads: workspace_id
    - Automations: workspace_id
    - Appointments: workspace_id, lead_id, scheduled_at, status
    - Bot types: plan
    - Workspace bots: workspace_id, bot_type_id
*/

-- Demo requests indexes
DROP INDEX IF EXISTS idx_demo_requests_created_at;
DROP INDEX IF EXISTS idx_demo_requests_status;
DROP INDEX IF EXISTS idx_demo_requests_email;

-- Bot execution logs indexes
DROP INDEX IF EXISTS idx_bot_execution_logs_bot_type_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_lead_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_workspace_id;
DROP INDEX IF EXISTS idx_bot_execution_logs_created_at;

-- Family reps indexes
DROP INDEX IF EXISTS idx_family_reps_profile_id;
DROP INDEX IF EXISTS idx_family_reps_referral_slug;

-- Internal payouts indexes
DROP INDEX IF EXISTS idx_internal_payouts_family_rep_id;
DROP INDEX IF EXISTS idx_internal_payouts_order_id;

-- LocalLink outbox indexes
DROP INDEX IF EXISTS idx_locallink_outbox_order_id;
DROP INDEX IF EXISTS idx_locallink_outbox_sync_status;

-- Messages indexes
DROP INDEX IF EXISTS idx_messages_lead_id;
DROP INDEX IF EXISTS idx_messages_workspace_id;

-- Orders indexes
DROP INDEX IF EXISTS idx_orders_workspace_id;
DROP INDEX IF EXISTS idx_orders_profile_id;
DROP INDEX IF EXISTS idx_orders_referred_by;

-- Vertical licenses indexes
DROP INDEX IF EXISTS idx_vertical_licenses_licensee;
DROP INDEX IF EXISTS idx_vertical_licenses_status;
DROP INDEX IF EXISTS idx_vertical_licenses_subdomain;
DROP INDEX IF EXISTS idx_vertical_licenses_vertical_template_id;

-- Vertical revenue indexes
DROP INDEX IF EXISTS idx_vertical_revenue_license;
DROP INDEX IF EXISTS idx_vertical_revenue_period;

-- Referral clicks indexes
DROP INDEX IF EXISTS idx_referral_clicks_partner_id;
DROP INDEX IF EXISTS idx_referral_clicks_code;
DROP INDEX IF EXISTS idx_referral_clicks_clicked_at;

-- Referral conversions indexes
DROP INDEX IF EXISTS idx_referral_conversions_partner_id;
DROP INDEX IF EXISTS idx_referral_conversions_code;
DROP INDEX IF EXISTS idx_referral_conversions_order_id;
DROP INDEX IF EXISTS idx_referral_conversions_status;

-- Employee reps indexes
DROP INDEX IF EXISTS idx_employee_reps_profile;
DROP INDEX IF EXISTS idx_employee_reps_active;

-- Commission payouts indexes
DROP INDEX IF EXISTS idx_commission_payouts_order;
DROP INDEX IF EXISTS idx_commission_payouts_recipient;
DROP INDEX IF EXISTS idx_commission_payouts_status;
DROP INDEX IF EXISTS idx_commission_payouts_period;
DROP INDEX IF EXISTS idx_commission_payouts_locallink;

-- Affiliate partners indexes
DROP INDEX IF EXISTS idx_affiliate_partners_referral_code;
DROP INDEX IF EXISTS idx_affiliate_partners_user_id;

-- Workspaces indexes
DROP INDEX IF EXISTS idx_workspaces_owner_id;

-- Leads indexes
DROP INDEX IF EXISTS idx_leads_workspace_id;

-- Automations indexes
DROP INDEX IF EXISTS idx_automations_workspace_id;

-- Appointments indexes
DROP INDEX IF EXISTS idx_appointments_workspace_id;
DROP INDEX IF EXISTS idx_appointments_lead_id;
DROP INDEX IF EXISTS idx_appointments_scheduled_at;
DROP INDEX IF EXISTS idx_appointments_status;

-- Bot types indexes
DROP INDEX IF EXISTS idx_bot_types_plan;

-- Workspace bots indexes
DROP INDEX IF EXISTS idx_workspace_bots_workspace_id;
DROP INDEX IF EXISTS idx_workspace_bots_bot_type_id;
