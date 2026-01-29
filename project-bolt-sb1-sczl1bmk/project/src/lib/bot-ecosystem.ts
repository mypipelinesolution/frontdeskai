export interface Bot {
  number: string;
  name: string;
  category: 'CORE' | 'STARTER' | 'CORE_TIER' | 'ACCELERATOR' | 'DFY' | 'ADD_ON' | 'ADMIN';
  description: string;
  capabilities: string[];
  planRequirement: string;
  monthlyPrice?: number;
}

export const BOT_ECOSYSTEM: Record<string, Bot> = {
  '1': {
    number: '1',
    name: 'AI Business Brain',
    category: 'CORE',
    description: 'Trained on client business, services, pricing, FAQs, policies. Custom tone/personality. Learns from conversations. Powers everything.',
    capabilities: ['business_knowledge', 'custom_training', 'conversation_learning', 'personality_matching'],
    planRequirement: 'all',
  },
  '2': {
    number: '2',
    name: 'Lead Intelligence Bot',
    category: 'CORE',
    description: 'Tracks every lead, scores intent, routes hot leads, updates CRM automatically.',
    capabilities: ['lead_tracking', 'intent_scoring', 'hot_lead_routing', 'crm_updates'],
    planRequirement: 'all',
  },
  '3': {
    number: '3',
    name: 'Conversation Memory Bot',
    category: 'CORE',
    description: 'Remembers past chats, recalls context, personalizes replies based on history.',
    capabilities: ['conversation_history', 'context_recall', 'personalization'],
    planRequirement: 'all',
  },
  '4': {
    number: '4',
    name: 'Compliance + Safety Bot',
    category: 'CORE',
    description: 'Filters bad requests, protects business info, prevents inappropriate responses.',
    capabilities: ['content_filtering', 'data_protection', 'safety_checks'],
    planRequirement: 'all',
  },
  '5': {
    number: '5',
    name: 'Website Chat Bot',
    category: 'STARTER',
    description: '24/7 site chat widget. Lead capture, FAQ handling, instant replies.',
    capabilities: ['live_chat', 'lead_capture', 'faq_responses', 'instant_reply'],
    planRequirement: 'starter',
  },
  '6': {
    number: '6',
    name: 'Missed Call Text Bot',
    category: 'STARTER',
    description: 'Auto-SMS when calls missed. "Sorry we missed you…" Captures callback info.',
    capabilities: ['missed_call_detection', 'auto_sms', 'callback_capture'],
    planRequirement: 'starter',
  },
  '7': {
    number: '7',
    name: 'Basic Follow-Up Bot',
    category: 'STARTER',
    description: '3-5 message sequences via text + email. Stops leads from ghosting.',
    capabilities: ['follow_up_sequences', 'sms_email', 'ghost_prevention'],
    planRequirement: 'starter',
  },
  '8': {
    number: '8',
    name: 'Intake Form Bot',
    category: 'STARTER',
    description: 'Collects customer info, auto-fills CRM, prepares sales conversation.',
    capabilities: ['form_collection', 'crm_population', 'data_preparation'],
    planRequirement: 'starter',
  },
  '9': {
    number: '9',
    name: 'Simple Reporting Bot',
    category: 'STARTER',
    description: 'Tracks leads, chats, responses, and activity. Basic analytics dashboard.',
    capabilities: ['lead_reporting', 'activity_tracking', 'basic_analytics'],
    planRequirement: 'starter',
  },
  '10': {
    number: '10',
    name: 'Smart Booking Bot',
    category: 'CORE_TIER',
    description: 'Books appointments, syncs calendar, sends reminders, handles reschedules.',
    capabilities: ['appointment_booking', 'calendar_sync', 'reminders', 'rescheduling'],
    planRequirement: 'core',
  },
  '11': {
    number: '11',
    name: 'Sales Conversation Bot',
    category: 'CORE_TIER',
    description: 'Qualifies leads, handles objections, explains services, pushes to close.',
    capabilities: ['lead_qualification', 'objection_handling', 'sales_pitch', 'closing'],
    planRequirement: 'core',
  },
  '12': {
    number: '12',
    name: 'CRM Manager Bot',
    category: 'CORE_TIER',
    description: 'Updates records, tags leads, tracks stages, notes calls automatically.',
    capabilities: ['record_updates', 'lead_tagging', 'stage_tracking', 'call_notes'],
    planRequirement: 'core',
  },
  '13': {
    number: '13',
    name: 'Campaign Builder Bot',
    category: 'CORE_TIER',
    description: 'Creates SMS/email campaigns, schedules sends, A/B tests messages.',
    capabilities: ['campaign_creation', 'message_scheduling', 'ab_testing'],
    planRequirement: 'core',
  },
  '14': {
    number: '14',
    name: 'Reputation Monitor Bot',
    category: 'CORE_TIER',
    description: 'Reviews monitoring, review requests, negative feedback alerts.',
    capabilities: ['review_monitoring', 'review_requests', 'alert_system'],
    planRequirement: 'core',
  },
  '15': {
    number: '15',
    name: 'Priority Routing Bot',
    category: 'CORE_TIER',
    description: 'Sends hot leads to owner instantly via SMS alerts and push notifications.',
    capabilities: ['hot_lead_detection', 'sms_alerts', 'push_notifications', 'instant_routing'],
    planRequirement: 'core',
  },
  '16': {
    number: '16',
    name: 'AI Call Answering Bot',
    category: 'ACCELERATOR',
    description: 'Voice AI that answers calls, qualifies callers, takes messages, routes calls.',
    capabilities: ['voice_ai', 'call_answering', 'caller_qualification', 'call_routing'],
    planRequirement: 'pro',
  },
  '17': {
    number: '17',
    name: 'Lead Nurture Engine',
    category: 'ACCELERATOR',
    description: 'Long-term follow-up, drip campaigns, reactivation sequences.',
    capabilities: ['long_term_nurture', 'drip_campaigns', 'reactivation', 'lifecycle_marketing'],
    planRequirement: 'pro',
  },
  '18': {
    number: '18',
    name: 'Workflow Automation Bot',
    category: 'ACCELERATOR',
    description: 'Custom triggers, multi-step actions, if/then logic for complex automations.',
    capabilities: ['custom_triggers', 'multi_step_workflows', 'conditional_logic', 'advanced_automation'],
    planRequirement: 'pro',
  },
  '19': {
    number: '19',
    name: 'Analytics & Revenue Bot',
    category: 'ACCELERATOR',
    description: 'Funnel tracking, ROI reporting, conversion stats, revenue attribution.',
    capabilities: ['funnel_analytics', 'roi_tracking', 'conversion_reporting', 'revenue_attribution'],
    planRequirement: 'pro',
  },
  '20': {
    number: '20',
    name: 'Multi-Channel Orchestrator',
    category: 'ACCELERATOR',
    description: 'Chat + SMS + Email + Voice unified. Central control, smart channel switching.',
    capabilities: ['multi_channel', 'unified_inbox', 'smart_routing', 'channel_switching'],
    planRequirement: 'pro',
  },
  '21': {
    number: '21',
    name: 'Upsell / Cross-Sell Bot',
    category: 'ACCELERATOR',
    description: 'Detects buying intent, offers upgrades, promotes add-ons intelligently.',
    capabilities: ['intent_detection', 'upsell_offers', 'cross_sell', 'revenue_optimization'],
    planRequirement: 'pro',
  },
  '27': {
    number: '27',
    name: 'Growth Strategist AI',
    category: 'ACCELERATOR',
    description: 'Strategic decision intelligence. Answers "What if I raise prices?", "Should I hire?", "Open second location?" Predictive modeling for business growth.',
    capabilities: ['strategic_forecasting', 'scenario_modeling', 'roi_simulation', 'growth_analysis', 'risk_assessment', 'decision_intelligence'],
    planRequirement: 'pro',
  },
  '22': {
    number: '22',
    name: 'DFY Setup Bot',
    category: 'DFY',
    description: 'Collects business info, configures automations, trains AI on your business.',
    capabilities: ['onboarding_automation', 'business_configuration', 'ai_training', 'setup_wizard'],
    planRequirement: 'dfy',
  },
  '23': {
    number: '23',
    name: 'Funnel Builder Bot',
    category: 'DFY',
    description: 'Builds landing pages, forms, pipelines automatically for your business.',
    capabilities: ['landing_page_creation', 'form_builder', 'pipeline_setup', 'funnel_optimization'],
    planRequirement: 'dfy',
  },
  '24': {
    number: '24',
    name: 'Campaign Launch Bot',
    category: 'DFY',
    description: 'Deploys first campaigns, tests messaging, optimizes flows for maximum conversion.',
    capabilities: ['campaign_deployment', 'message_testing', 'flow_optimization', 'launch_automation'],
    planRequirement: 'dfy',
  },
  '25': {
    number: '25',
    name: 'Ad Integration Bot',
    category: 'DFY',
    description: 'Connects FB/Google ads, syncs leads, routes to CRM seamlessly.',
    capabilities: ['fb_ads_integration', 'google_ads_integration', 'lead_sync', 'ad_tracking'],
    planRequirement: 'dfy',
  },
  '26': {
    number: '26',
    name: 'Optimization Coach Bot',
    category: 'DFY',
    description: 'Reviews performance, suggests changes, improves conversion continuously.',
    capabilities: ['performance_review', 'optimization_suggestions', 'conversion_improvement', 'coaching'],
    planRequirement: 'dfy',
  },
  'A1': {
    number: 'A1',
    name: 'AI Webinar Host Bot',
    category: 'ADD_ON',
    description: 'Runs automated webinars, presents content, answers questions, sells packages.',
    capabilities: ['webinar_hosting', 'presentation', 'qa_handling', 'sales_automation'],
    planRequirement: 'add_on',
    monthlyPrice: 97,
  },
  'A2': {
    number: 'A2',
    name: 'Advanced Voice Sales Agent',
    category: 'ADD_ON',
    description: 'Trained closer that negotiates, handles complex sales, books appointments.',
    capabilities: ['voice_sales', 'negotiation', 'advanced_closing', 'appointment_booking'],
    planRequirement: 'add_on',
    monthlyPrice: 79,
  },
  'A3': {
    number: 'A3',
    name: 'Social DM Bot (FB/IG)',
    category: 'ADD_ON',
    description: 'Responds to DMs on Facebook and Instagram, qualifies, routes to checkout.',
    capabilities: ['fb_messenger', 'instagram_dm', 'social_qualification', 'checkout_routing'],
    planRequirement: 'add_on',
    monthlyPrice: 59,
  },
  'A4': {
    number: 'A4',
    name: 'Review Booster Pro',
    category: 'ADD_ON',
    description: 'Multi-platform review requests, SMS + email automation, GMB sync.',
    capabilities: ['multi_platform_reviews', 'automated_requests', 'gmb_integration', 'review_management'],
    planRequirement: 'add_on',
    monthlyPrice: 39,
  },
  'A5': {
    number: 'A5',
    name: 'White-Label Branding Bot',
    category: 'ADD_ON',
    description: 'Custom domain, custom logo, removes FrontDesk AI branding completely.',
    capabilities: ['custom_domain', 'custom_branding', 'white_label', 'brand_removal'],
    planRequirement: 'add_on',
    monthlyPrice: 99,
  },
  'A6': {
    number: 'A6',
    name: 'Local SEO Content Bot',
    category: 'ADD_ON',
    description: 'Generates blog posts, service pages, location pages for SEO.',
    capabilities: ['content_generation', 'blog_posts', 'seo_optimization', 'local_pages'],
    planRequirement: 'add_on',
    monthlyPrice: 49,
  },
  'A7': {
    number: 'A7',
    name: 'Partner Referral Bot',
    category: 'ADD_ON',
    description: 'Manages referrals, tracks commissions, pays out automatically.',
    capabilities: ['referral_tracking', 'commission_calculation', 'automated_payouts', 'partner_management'],
    planRequirement: 'add_on',
    monthlyPrice: 29,
  },
};

export function getBotsByPlan(plan: 'starter' | 'core' | 'pro'): Bot[] {
  const bots: Bot[] = [];

  Object.values(BOT_ECOSYSTEM).forEach(bot => {
    if (bot.category === 'CORE') {
      bots.push(bot);
    }

    if (plan === 'starter' && bot.category === 'STARTER') {
      bots.push(bot);
    }

    if (plan === 'core' && (bot.category === 'STARTER' || bot.category === 'CORE_TIER')) {
      bots.push(bot);
    }

    if (plan === 'pro' && (bot.category === 'STARTER' || bot.category === 'CORE_TIER' || bot.category === 'ACCELERATOR')) {
      bots.push(bot);
    }
  });

  return bots;
}

export function getDFYBots(): Bot[] {
  return Object.values(BOT_ECOSYSTEM).filter(bot => bot.category === 'DFY');
}

export function getAddOnBots(): Bot[] {
  return Object.values(BOT_ECOSYSTEM).filter(bot => bot.category === 'ADD_ON');
}

export function getBotCount(plan: 'starter' | 'core' | 'pro'): number {
  return getBotsByPlan(plan).length;
}

export const PLAN_BOT_SUMMARY = {
  starter: {
    count: 9,
    description: 'AI Receptionist Team',
    categories: ['4 Core Bots', '5 Receptionist Bots'],
  },
  core: {
    count: 15,
    description: 'AI Sales Assistant Team',
    categories: ['4 Core Bots', '5 Receptionist Bots', '6 Sales Bots'],
  },
  pro: {
    count: 22,
    description: 'AI Growth Machine Team',
    categories: ['4 Core Bots', '5 Receptionist Bots', '6 Sales Bots', '7 Growth Bots'],
  },
  dfy: {
    count: 5,
    description: 'Done For You Team',
    categories: ['5 Setup & Optimization Bots'],
  },
};
