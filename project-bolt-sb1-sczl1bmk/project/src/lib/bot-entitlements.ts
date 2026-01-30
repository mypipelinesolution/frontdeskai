/**
 * Bot Entitlements & Plan Mappings
 *
 * Defines which bots are enabled for each subscription plan.
 * When a plan is purchased, these bots are automatically activated.
 */

export type PlanKey = "starter" | "core" | "pro" | "dfy";

/**
 * Maps plan keys to their included bot IDs
 */
export const planBotMap: Record<PlanKey, string[]> = {
  starter: [
    "bot_business_brain",
    "bot_lead_intel",
    "bot_memory",
    "bot_compliance",
    "bot_website_chat",
    "bot_missed_call_text",
    "bot_basic_followup",
    "bot_intake_form",
    "bot_simple_reporting"
  ],
  core: [
    "bot_business_brain",
    "bot_lead_intel",
    "bot_memory",
    "bot_compliance",
    "bot_website_chat",
    "bot_missed_call_text",
    "bot_basic_followup",
    "bot_intake_form",
    "bot_simple_reporting",
    "bot_smart_booking",
    "bot_sales_conversation",
    "bot_crm_manager",
    "bot_campaign_builder",
    "bot_reputation_monitor",
    "bot_priority_routing"
  ],
  pro: [
    "bot_business_brain",
    "bot_lead_intel",
    "bot_memory",
    "bot_compliance",
    "bot_website_chat",
    "bot_missed_call_text",
    "bot_basic_followup",
    "bot_intake_form",
    "bot_simple_reporting",
    "bot_smart_booking",
    "bot_sales_conversation",
    "bot_crm_manager",
    "bot_campaign_builder",
    "bot_reputation_monitor",
    "bot_priority_routing",
    "bot_call_answering",
    "bot_lead_nurture_engine",
    "bot_workflow_automation",
    "bot_analytics_revenue",
    "bot_multichannel_orchestrator",
    "bot_upsell_crosssell"
  ],
  dfy: [
    // DFY includes all Pro bots + DFY suite
    "bot_business_brain",
    "bot_lead_intel",
    "bot_memory",
    "bot_compliance",
    "bot_website_chat",
    "bot_missed_call_text",
    "bot_basic_followup",
    "bot_intake_form",
    "bot_simple_reporting",
    "bot_smart_booking",
    "bot_sales_conversation",
    "bot_crm_manager",
    "bot_campaign_builder",
    "bot_reputation_monitor",
    "bot_priority_routing",
    "bot_call_answering",
    "bot_lead_nurture_engine",
    "bot_workflow_automation",
    "bot_analytics_revenue",
    "bot_multichannel_orchestrator",
    "bot_upsell_crosssell",
    "bot_dfy_setup",
    "bot_funnel_builder",
    "bot_campaign_launch",
    "bot_ad_integration",
    "bot_optimization_coach"
  ]
};

/**
 * Maps addon keys to their bot IDs
 */
export const addonBotMap: Record<string, string[]> = {
  addon_webinar: ["bot_webinar_host"],
  addon_voice: ["bot_advanced_voice_sales"],
  addon_social: ["bot_social_dm"],
  addon_reviews: ["bot_review_booster_pro"],
  addon_whitelabel: ["bot_whitelabel_branding"],
  addon_seo: ["bot_local_seo_content"],
  addon_referral: ["bot_partner_referral"]
};

/**
 * Get all bot IDs for a given plan
 */
export function getBotsForPlan(planKey: PlanKey): string[] {
  return planBotMap[planKey] || planBotMap.core;
}

/**
 * Get bot IDs for an addon
 */
export function getBotsForAddon(addonKey: string): string[] {
  return addonBotMap[addonKey] || [];
}

/**
 * Check if a bot is included in a plan
 */
export function isPlanBot(botId: string, planKey: PlanKey): boolean {
  return planBotMap[planKey]?.includes(botId) || false;
}

/**
 * Check if a bot requires an addon
 */
export function isAddonBot(botId: string): boolean {
  return Object.values(addonBotMap).some(bots => bots.includes(botId));
}
