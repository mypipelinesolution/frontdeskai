export interface StripeProduct {
  id: string;
  priceId: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  mode: 'subscription' | 'payment';
}

export const STRIPE_PRODUCTS: StripeProduct[] = [
  {
    id: 'prod_TsRz1hRADSpysT',
    priceId: 'price_1Suh5hBVIKlJaihH4SC447x7',
    name: 'FrontDesk AI Pro — Starter',
    description: '24/7 AI Chat + SMS, Call Answering, Basic CRM',
    price: 104.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzcq3DK1J9uV',
    priceId: 'price_1Suh5mBVIKlJaihHgBIc1xrg',
    name: 'FrontDesk AI Pro — Core',
    description: 'Full AI Front Desk, SMS + Email Campaigns, Booking Automation',
    price: 154.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzRQm19UY9SW',
    priceId: 'price_1Suh5eBVIKlJaihHzpdlw7lt',
    name: 'FrontDesk AI Pro — Accelerator',
    description: 'Complete AI Growth System with call answering, automation workflows, analytics, and multi-channel outreach.Fully automate sales and operations.',
    price: 204.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzmA0KPmxB2d',
    priceId: 'price_1Suh5ZBVIKlJaihH2XccbctA',
    name: 'FrontDesk AI Pro — DFY Setup',
    description: 'White-glove setup and optimization.We configure, train, launch, and manage your AI system for you.True hands-free automation.',
    price: 497.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzTglVXwZ8nc',
    priceId: 'price_1Suh5IBVIKlJaihHLWCA4Cbp',
    name: 'AI Webinar Host Bot',
    description: 'Runs automated webinars, presents content, answers questions, and sells packages 24/7.',
    price: 97.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzECbu7yGBIX',
    priceId: 'price_1Suh5FBVIKlJaihH8n2gdDmp',
    name: 'Advanced Voice Sales Agent',
    description: 'Trained closer Negotiates Books + sells',
    price: 79.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzsEzLAlWAFq',
    priceId: 'price_1Suh5ABVIKlJaihHFWwObEo3',
    name: 'Social DM Automation Bot',
    description: 'full_automation',
    price: 59.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRyDmBHXDkCsk',
    priceId: 'price_1Suh4xBVIKlJaihHwDbyaehd',
    name: 'Local SEO Content Bot',
    description: 'Responds to DMs Qualifies Routes to checkout',
    price: 49.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRzpy2dZP4O3L',
    priceId: 'price_1Suh56BVIKlJaihHEKekrtTL',
    name: 'Review Booster Pro',
    description: 'Multi-platform reviews SMS + email requests GMB sync',
    price: 39.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRyTexcQxJSkf',
    priceId: 'price_1Suh50BVIKlJaihH3DfD0Bya',
    name: 'White-Label Branding Bot',
    description: 'Custom domain Custom logo Remove FD branding',
    price: 99.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TsRy3hsmSedGMg',
    priceId: 'price_1Suh4uBVIKlJaihHnwrUnExy',
    name: 'Partner Referral Manager',
    description: 'Manages referrals Tracks commissions Pays out',
    price: 29.00,
    currency: 'usd',
    mode: 'subscription'
  }
];

export const getProductByPriceId = (priceId: string): StripeProduct | undefined => {
  return STRIPE_PRODUCTS.find(product => product.priceId === priceId);
};

export const getProductById = (id: string): StripeProduct | undefined => {
  return STRIPE_PRODUCTS.find(product => product.id === id);
};

export const formatPrice = (price: number, currency: string = 'usd'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency.toUpperCase(),
  }).format(price);
};

export const getProductsByCategory = (category: 'plan' | 'addon'): StripeProduct[] => {
  const planNames = ['Starter', 'Core', 'Accelerator', 'DFY Setup'];

  if (category === 'plan') {
    return STRIPE_PRODUCTS.filter(product =>
      planNames.some(name => product.name.includes(name))
    );
  } else {
    return STRIPE_PRODUCTS.filter(product =>
      !planNames.some(name => product.name.includes(name))
    );
  }
};

export const getCoreProducts = (): StripeProduct[] => {
  return STRIPE_PRODUCTS.filter(product =>
    product.name.includes('Starter') || 
    product.name.includes('Core') || 
    product.name.includes('Accelerator')
  );
};

export const stripeProducts = STRIPE_PRODUCTS;