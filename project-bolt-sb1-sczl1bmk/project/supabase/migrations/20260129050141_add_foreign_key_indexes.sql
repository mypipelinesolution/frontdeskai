/*
  # Add Indexes for Foreign Keys

  1. Performance Optimization
    - Adds indexes for all foreign key columns to improve JOIN performance
    - Critical for queries that join across tables
    - Improves referential integrity check performance
  
  2. Indexes Being Created (26 total)
    - affiliate_partners: user_id
    - appointments: lead_id, workspace_id
    - automations: workspace_id
    - bot_execution_logs: bot_type_id, lead_id, workspace_id
    - commission_payouts: order_id
    - employee_reps: profile_id
    - family_reps: profile_id
    - internal_payouts: family_rep_id, order_id
    - leads: workspace_id
    - locallink_outbox: order_id
    - messages: lead_id, workspace_id
    - orders: profile_id, workspace_id
    - referral_clicks: partner_id
    - referral_conversions: order_id, partner_id
    - vertical_licenses: licensee_id, vertical_template_id
    - vertical_revenue: license_id
    - workspace_bots: bot_type_id
    - workspaces: owner_id
  
  3. Performance Impact
    - Significantly faster JOIN operations
    - Faster foreign key constraint checks on INSERT/UPDATE/DELETE
    - Better query optimizer decisions
*/

-- affiliate_partners
CREATE INDEX IF NOT EXISTS idx_affiliate_partners_user_id 
  ON affiliate_partners(user_id);

-- appointments
CREATE INDEX IF NOT EXISTS idx_appointments_lead_id 
  ON appointments(lead_id);
CREATE INDEX IF NOT EXISTS idx_appointments_workspace_id 
  ON appointments(workspace_id);

-- automations
CREATE INDEX IF NOT EXISTS idx_automations_workspace_id 
  ON automations(workspace_id);

-- bot_execution_logs
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_bot_type_id 
  ON bot_execution_logs(bot_type_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_lead_id 
  ON bot_execution_logs(lead_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_workspace_id 
  ON bot_execution_logs(workspace_id);

-- commission_payouts
CREATE INDEX IF NOT EXISTS idx_commission_payouts_order_id 
  ON commission_payouts(order_id);

-- employee_reps
CREATE INDEX IF NOT EXISTS idx_employee_reps_profile_id 
  ON employee_reps(profile_id);

-- family_reps
CREATE INDEX IF NOT EXISTS idx_family_reps_profile_id 
  ON family_reps(profile_id);

-- internal_payouts
CREATE INDEX IF NOT EXISTS idx_internal_payouts_family_rep_id 
  ON internal_payouts(family_rep_id);
CREATE INDEX IF NOT EXISTS idx_internal_payouts_order_id 
  ON internal_payouts(order_id);

-- leads
CREATE INDEX IF NOT EXISTS idx_leads_workspace_id 
  ON leads(workspace_id);

-- locallink_outbox
CREATE INDEX IF NOT EXISTS idx_locallink_outbox_order_id 
  ON locallink_outbox(order_id);

-- messages
CREATE INDEX IF NOT EXISTS idx_messages_lead_id 
  ON messages(lead_id);
CREATE INDEX IF NOT EXISTS idx_messages_workspace_id 
  ON messages(workspace_id);

-- orders
CREATE INDEX IF NOT EXISTS idx_orders_profile_id 
  ON orders(profile_id);
CREATE INDEX IF NOT EXISTS idx_orders_workspace_id 
  ON orders(workspace_id);

-- referral_clicks
CREATE INDEX IF NOT EXISTS idx_referral_clicks_partner_id 
  ON referral_clicks(partner_id);

-- referral_conversions
CREATE INDEX IF NOT EXISTS idx_referral_conversions_order_id 
  ON referral_conversions(order_id);
CREATE INDEX IF NOT EXISTS idx_referral_conversions_partner_id 
  ON referral_conversions(partner_id);

-- vertical_licenses
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_licensee_id 
  ON vertical_licenses(licensee_id);
CREATE INDEX IF NOT EXISTS idx_vertical_licenses_vertical_template_id 
  ON vertical_licenses(vertical_template_id);

-- vertical_revenue
CREATE INDEX IF NOT EXISTS idx_vertical_revenue_license_id 
  ON vertical_revenue(license_id);

-- workspace_bots
CREATE INDEX IF NOT EXISTS idx_workspace_bots_bot_type_id 
  ON workspace_bots(bot_type_id);

-- workspaces
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id 
  ON workspaces(owner_id);
