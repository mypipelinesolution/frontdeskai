/*
  # Add Growth Strategist AI Bot

  1. Changes
    - Adds bot #27: Growth Strategist AI
    - Category: ACCELERATOR (Pro plan tier)
    - Strategic decision intelligence and predictive modeling

  2. Bot Details
    - **What it does**: Strategic decision support for business growth
    - **Use cases**: 
      - "What if I raise prices?"
      - "Should I hire or automate?"
      - "Which ads work best?"
      - "Open a second location?"
    - **Capabilities**: Strategic forecasting, scenario modeling, ROI simulation, growth analysis, risk assessment
    - **Requirement**: Pro plan ($204/mo tier)

  3. Business Value
    - Part of Pipeline Intelligence Engine™
    - Shared core AI across FrontDesk AI Pro, LifeOps AI Pro, and Local-Link
    - Premium differentiator for Accelerator tier
*/

-- Insert Growth Strategist AI bot
INSERT INTO bot_types (
  bot_number,
  name,
  category,
  description,
  capabilities,
  plan_requirement,
  monthly_price,
  enabled,
  sort_order
) VALUES (
  '27',
  'Growth Strategist AI',
  'ACCELERATOR',
  'Strategic decision intelligence. Answers "What if I raise prices?", "Should I hire?", "Open second location?" Predictive modeling for business growth.',
  ARRAY[
    'strategic_forecasting',
    'scenario_modeling',
    'roi_simulation',
    'growth_analysis',
    'risk_assessment',
    'decision_intelligence'
  ],
  'pro',
  0,
  true,
  27
)
ON CONFLICT (bot_number) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  capabilities = EXCLUDED.capabilities,
  updated_at = now();
