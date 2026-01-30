export type PlanKey = 'fd_starter' | 'fd_core' | 'fd_pro' | 'fd_dfy' | 'fd_agency_dfy';

export interface PlanDetails {
  key: PlanKey;
  name: string;
  price: number;
  priceId?: string;
  description: string;
  features: string[];
  popular?: boolean;
  amountCents: number;
}

export const PLAN_DETAILS: Record<PlanKey, PlanDetails> = {
  fd_starter: {
    key: 'fd_starter',
    name: 'Starter',
    price: 104,
    amountCents: 10400,
    priceId: import.meta.env.VITE_STRIPE_PRICE_STARTER || '',
    description: '',
    features: [
      '24/7 AI Chat & SMS',
      'Call Answering',
      'Basic CRM',
      'Lead Capture',
      'Email Support',
    ],
  },
  fd_core: {
    key: 'fd_core',
    name: 'Core',
    price: 154,
    amountCents: 15400,
    priceId: import.meta.env.VITE_STRIPE_PRICE_CORE || '',
    description: 'MOST POPULAR',
    popular: true,
    features: [
      '24/7 AI Front Desk',
      'SMS & Email Campaigns',
      'Smart Booking System',
      'CRM Dashboard',
      'Priority Support',
    ],
  },
  fd_pro: {
    key: 'fd_pro',
    name: 'Accelerator',
    price: 204,
    amountCents: 20400,
    priceId: import.meta.env.VITE_STRIPE_PRICE_PRO || '',
    description: '',
    features: [
      'Full Automation Suite',
      'Advanced Lead Nurturing AI',
      'Multi-Channel Outreach',
      'Custom Workflows',
      'VIP Support',
    ],
  },
  fd_dfy: {
    key: 'fd_dfy',
    name: 'DFY Setup',
    price: 497,
    amountCents: 49700,
    priceId: import.meta.env.VITE_STRIPE_PRICE_DFY || '',
    description: 'WHITE GLOVE',
    features: [
      'We set everything up for you',
      'Custom workflows + routing',
      'CRM + calendar integration',
      'SMS/email scripts loaded',
      'Priority onboarding',
      'Referral tracking',
    ],
  },
  fd_agency_dfy: {
    key: 'fd_agency_dfy',
    name: 'Agency DFY',
    price: 997,
    amountCents: 99700,
    priceId: import.meta.env.VITE_STRIPE_PRICE_AGENCY_DFY || '',
    description: 'PREMIUM GROWTH',
    features: [
      'Everything in DFY Setup',
      'Ad campaign management',
      'Weekly optimization',
      'Revenue analytics',
      'Growth strategy sessions',
      'Dedicated success manager',
    ],
  },
};

export function getPlanByKey(key: PlanKey): PlanDetails {
  return PLAN_DETAILS[key];
}

export function getAllPlans(): PlanDetails[] {
  return Object.values(PLAN_DETAILS);
}

export function getMainPlans(): PlanDetails[] {
  return [PLAN_DETAILS.fd_starter, PLAN_DETAILS.fd_core, PLAN_DETAILS.fd_pro];
}

export function getDFYPlan(): PlanDetails {
  return PLAN_DETAILS.fd_dfy;
}

export function getDFYPlans(): PlanDetails[] {
  return [PLAN_DETAILS.fd_dfy, PLAN_DETAILS.fd_agency_dfy];
}
