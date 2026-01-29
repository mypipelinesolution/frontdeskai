/*
  # Complete 37-Bot Ecosystem

  1. New Tables
    - bot_types: Defines all 37 AI bots with metadata
    - workspace_bots: Tracks which bots are enabled per workspace
    - bot_add_ons: Premium add-on bots and pricing
    - bot_execution_logs: Tracks bot activity and performance
  
  2. Bot Categories
    - CORE: 4 bots (all plans)
    - STARTER: 5 bots ($104/mo)
    - CORE_TIER: 6 bots ($154/mo)
    - ACCELERATOR: 6 bots ($204/mo)
    - DFY: 5 bots ($497 one-time)
    - ADD_ON: 7 premium bots (separate pricing)
    - ADMIN: 4 internal bots
  
  3. Security
    - Enable RLS on all tables
    - Workspace owners manage their bots
    - Admins manage bot types
*/

-- Bot types enumeration table
CREATE TABLE IF NOT EXISTS bot_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bot_number text UNIQUE NOT NULL,
  name text NOT NULL,
  category text NOT NULL CHECK (category IN ('CORE', 'STARTER', 'CORE_TIER', 'ACCELERATOR', 'DFY', 'ADD_ON', 'ADMIN')),
  description text NOT NULL,
  capabilities text[] DEFAULT '{}',
  plan_requirement text CHECK (plan_requirement IN ('all', 'starter', 'core', 'pro', 'dfy', 'add_on', 'admin')),
  monthly_price integer DEFAULT 0,
  enabled boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Workspace bots: tracks which bots are active per workspace
CREATE TABLE IF NOT EXISTS workspace_bots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  bot_type_id uuid REFERENCES bot_types(id) ON DELETE CASCADE,
  enabled boolean DEFAULT true,
  configuration jsonb DEFAULT '{}',
  last_executed_at timestamptz,
  execution_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(workspace_id, bot_type_id)
);

-- Bot execution logs for monitoring and analytics
CREATE TABLE IF NOT EXISTS bot_execution_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE,
  bot_type_id uuid REFERENCES bot_types(id) ON DELETE CASCADE,
  lead_id uuid REFERENCES leads(id) ON DELETE SET NULL,
  action text NOT NULL,
  status text DEFAULT 'success' CHECK (status IN ('success', 'failed', 'pending')),
  input_data jsonb,
  output_data jsonb,
  error_message text,
  execution_time_ms integer,
  created_at timestamptz DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_bot_types_category ON bot_types(category);
CREATE INDEX IF NOT EXISTS idx_bot_types_plan ON bot_types(plan_requirement);
CREATE INDEX IF NOT EXISTS idx_workspace_bots_workspace_id ON workspace_bots(workspace_id);
CREATE INDEX IF NOT EXISTS idx_workspace_bots_bot_type_id ON workspace_bots(bot_type_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_workspace_id ON bot_execution_logs(workspace_id);
CREATE INDEX IF NOT EXISTS idx_bot_execution_logs_created_at ON bot_execution_logs(created_at);

-- Enable RLS
ALTER TABLE bot_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_bots ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_execution_logs ENABLE ROW LEVEL SECURITY;

-- Bot types policies (admins only can manage)
CREATE POLICY "Anyone can view bot types"
  ON bot_types FOR SELECT
  TO authenticated, anon
  USING (enabled = true);

CREATE POLICY "Admins can manage bot types"
  ON bot_types FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Workspace bots policies
CREATE POLICY "Users can view their workspace bots"
  ON workspace_bots FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can manage their workspace bots"
  ON workspace_bots FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = workspace_bots.workspace_id AND workspaces.owner_id = auth.uid())
  );

-- Bot execution logs policies
CREATE POLICY "Users can view their bot execution logs"
  ON bot_execution_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM workspaces WHERE workspaces.id = bot_execution_logs.workspace_id AND workspaces.owner_id = auth.uid())
    OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "System can insert bot execution logs"
  ON bot_execution_logs FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Insert all 37 bot types
INSERT INTO bot_types (bot_number, name, category, description, capabilities, plan_requirement, monthly_price, sort_order) VALUES

-- CORE FOUNDATION (4 bots - ALL PLANS)
('1', 'AI Business Brain', 'CORE', 'Trained on client business, services, pricing, FAQs, policies. Custom tone/personality. Learns from conversations. Powers everything.', 
 ARRAY['business_knowledge', 'custom_training', 'conversation_learning', 'personality_matching'], 'all', 0, 1),

('2', 'Lead Intelligence Bot', 'CORE', 'Tracks every lead, scores intent, routes hot leads, updates CRM automatically.',
 ARRAY['lead_tracking', 'intent_scoring', 'hot_lead_routing', 'crm_updates'], 'all', 0, 2),

('3', 'Conversation Memory Bot', 'CORE', 'Remembers past chats, recalls context, personalizes replies based on history.',
 ARRAY['conversation_history', 'context_recall', 'personalization'], 'all', 0, 3),

('4', 'Compliance + Safety Bot', 'CORE', 'Filters bad requests, protects business info, prevents inappropriate responses.',
 ARRAY['content_filtering', 'data_protection', 'safety_checks'], 'all', 0, 4),

-- STARTER PLAN (5 bots - $104/month)
('5', 'Website Chat Bot', 'STARTER', '24/7 site chat widget. Lead capture, FAQ handling, instant replies.',
 ARRAY['live_chat', 'lead_capture', 'faq_responses', 'instant_reply'], 'starter', 0, 5),

('6', 'Missed Call Text Bot', 'STARTER', 'Auto-SMS when calls missed. "Sorry we missed you…" Captures callback info.',
 ARRAY['missed_call_detection', 'auto_sms', 'callback_capture'], 'starter', 0, 6),

('7', 'Basic Follow-Up Bot', 'STARTER', '3-5 message sequences via text + email. Stops leads from ghosting.',
 ARRAY['follow_up_sequences', 'sms_email', 'ghost_prevention'], 'starter', 0, 7),

('8', 'Intake Form Bot', 'STARTER', 'Collects customer info, auto-fills CRM, prepares sales conversation.',
 ARRAY['form_collection', 'crm_population', 'data_preparation'], 'starter', 0, 8),

('9', 'Simple Reporting Bot', 'STARTER', 'Tracks leads, chats, responses, and activity. Basic analytics dashboard.',
 ARRAY['lead_reporting', 'activity_tracking', 'basic_analytics'], 'starter', 0, 9),

-- CORE PLAN (6 additional bots - $154/month)
('10', 'Smart Booking Bot', 'CORE_TIER', 'Books appointments, syncs calendar, sends reminders, handles reschedules.',
 ARRAY['appointment_booking', 'calendar_sync', 'reminders', 'rescheduling'], 'core', 0, 10),

('11', 'Sales Conversation Bot', 'CORE_TIER', 'Qualifies leads, handles objections, explains services, pushes to close.',
 ARRAY['lead_qualification', 'objection_handling', 'sales_pitch', 'closing'], 'core', 0, 11),

('12', 'CRM Manager Bot', 'CORE_TIER', 'Updates records, tags leads, tracks stages, notes calls automatically.',
 ARRAY['record_updates', 'lead_tagging', 'stage_tracking', 'call_notes'], 'core', 0, 12),

('13', 'Campaign Builder Bot', 'CORE_TIER', 'Creates SMS/email campaigns, schedules sends, A/B tests messages.',
 ARRAY['campaign_creation', 'message_scheduling', 'ab_testing'], 'core', 0, 13),

('14', 'Reputation Monitor Bot', 'CORE_TIER', 'Reviews monitoring, review requests, negative feedback alerts.',
 ARRAY['review_monitoring', 'review_requests', 'alert_system'], 'core', 0, 14),

('15', 'Priority Routing Bot', 'CORE_TIER', 'Sends hot leads to owner instantly via SMS alerts and push notifications.',
 ARRAY['hot_lead_detection', 'sms_alerts', 'push_notifications', 'instant_routing'], 'core', 0, 15),

-- ACCELERATOR PLAN (6 additional bots - $204/month)
('16', 'AI Call Answering Bot', 'ACCELERATOR', 'Voice AI that answers calls, qualifies callers, takes messages, routes calls.',
 ARRAY['voice_ai', 'call_answering', 'caller_qualification', 'call_routing'], 'pro', 0, 16),

('17', 'Lead Nurture Engine', 'ACCELERATOR', 'Long-term follow-up, drip campaigns, reactivation sequences.',
 ARRAY['long_term_nurture', 'drip_campaigns', 'reactivation', 'lifecycle_marketing'], 'pro', 0, 17),

('18', 'Workflow Automation Bot', 'ACCELERATOR', 'Custom triggers, multi-step actions, if/then logic for complex automations.',
 ARRAY['custom_triggers', 'multi_step_workflows', 'conditional_logic', 'advanced_automation'], 'pro', 0, 18),

('19', 'Analytics & Revenue Bot', 'ACCELERATOR', 'Funnel tracking, ROI reporting, conversion stats, revenue attribution.',
 ARRAY['funnel_analytics', 'roi_tracking', 'conversion_reporting', 'revenue_attribution'], 'pro', 0, 19),

('20', 'Multi-Channel Orchestrator', 'ACCELERATOR', 'Chat + SMS + Email + Voice unified. Central control, smart channel switching.',
 ARRAY['multi_channel', 'unified_inbox', 'smart_routing', 'channel_switching'], 'pro', 0, 20),

('21', 'Upsell / Cross-Sell Bot', 'ACCELERATOR', 'Detects buying intent, offers upgrades, promotes add-ons intelligently.',
 ARRAY['intent_detection', 'upsell_offers', 'cross_sell', 'revenue_optimization'], 'pro', 0, 21),

-- DFY SETUP (5 bots - $497 one-time)
('22', 'DFY Setup Bot', 'DFY', 'Collects business info, configures automations, trains AI on your business.',
 ARRAY['onboarding_automation', 'business_configuration', 'ai_training', 'setup_wizard'], 'dfy', 0, 22),

('23', 'Funnel Builder Bot', 'DFY', 'Builds landing pages, forms, pipelines automatically for your business.',
 ARRAY['landing_page_creation', 'form_builder', 'pipeline_setup', 'funnel_optimization'], 'dfy', 0, 23),

('24', 'Campaign Launch Bot', 'DFY', 'Deploys first campaigns, tests messaging, optimizes flows for maximum conversion.',
 ARRAY['campaign_deployment', 'message_testing', 'flow_optimization', 'launch_automation'], 'dfy', 0, 24),

('25', 'Ad Integration Bot', 'DFY', 'Connects FB/Google ads, syncs leads, routes to CRM seamlessly.',
 ARRAY['fb_ads_integration', 'google_ads_integration', 'lead_sync', 'ad_tracking'], 'dfy', 0, 25),

('26', 'Optimization Coach Bot', 'DFY', 'Reviews performance, suggests changes, improves conversion continuously.',
 ARRAY['performance_review', 'optimization_suggestions', 'conversion_improvement', 'coaching'], 'dfy', 0, 26),

-- PREMIUM ADD-ONS (7 bots - Sold separately)
('A1', 'AI Webinar Host Bot', 'ADD_ON', 'Runs automated webinars, presents content, answers questions, sells packages.',
 ARRAY['webinar_hosting', 'presentation', 'qa_handling', 'sales_automation'], 'add_on', 9700, 27),

('A2', 'Advanced Voice Sales Agent', 'ADD_ON', 'Trained closer that negotiates, handles complex sales, books appointments.',
 ARRAY['voice_sales', 'negotiation', 'advanced_closing', 'appointment_booking'], 'add_on', 7900, 28),

('A3', 'Social DM Bot (FB/IG)', 'ADD_ON', 'Responds to DMs on Facebook and Instagram, qualifies, routes to checkout.',
 ARRAY['fb_messenger', 'instagram_dm', 'social_qualification', 'checkout_routing'], 'add_on', 5900, 29),

('A4', 'Review Booster Pro', 'ADD_ON', 'Multi-platform review requests, SMS + email automation, GMB sync.',
 ARRAY['multi_platform_reviews', 'automated_requests', 'gmb_integration', 'review_management'], 'add_on', 3900, 30),

('A5', 'White-Label Branding Bot', 'ADD_ON', 'Custom domain, custom logo, removes FrontDesk AI branding completely.',
 ARRAY['custom_domain', 'custom_branding', 'white_label', 'brand_removal'], 'add_on', 9900, 31),

('A6', 'Local SEO Content Bot', 'ADD_ON', 'Generates blog posts, service pages, location pages for SEO.',
 ARRAY['content_generation', 'blog_posts', 'seo_optimization', 'local_pages'], 'add_on', 4900, 32),

('A7', 'Partner Referral Bot', 'ADD_ON', 'Manages referrals, tracks commissions, pays out automatically.',
 ARRAY['referral_tracking', 'commission_calculation', 'automated_payouts', 'partner_management'], 'add_on', 2900, 33),

-- ADMIN BOTS (4 internal - Not sold)
('A8', 'Revenue Control Bot', 'ADMIN', 'Tracks MRR, churn, expansion revenue, payment health.',
 ARRAY['mrr_tracking', 'churn_analysis', 'revenue_reporting', 'financial_analytics'], 'admin', 0, 34),

('A9', 'Fraud & Abuse Monitor', 'ADMIN', 'Flags misuse, detects spam, protects platform integrity.',
 ARRAY['fraud_detection', 'abuse_monitoring', 'spam_detection', 'security'], 'admin', 0, 35),

('A10', 'Platform Health Bot', 'ADMIN', 'Monitors uptime, APIs, errors, system performance.',
 ARRAY['uptime_monitoring', 'api_health', 'error_tracking', 'performance_metrics'], 'admin', 0, 36),

('A11', 'Compliance & Tax Bot', 'ADMIN', 'Manages Stripe compliance, invoices, tax reporting, regulatory requirements.',
 ARRAY['stripe_compliance', 'invoice_management', 'tax_reporting', 'regulatory'], 'admin', 0, 37)

ON CONFLICT (bot_number) DO NOTHING;