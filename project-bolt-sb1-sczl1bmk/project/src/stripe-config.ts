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
    id: 'prod_TrbS8veJ0LPplA',
    priceId: 'price_1StsFsPbfTJTNa5AOU7efEPQ',
    name: 'FrontDesk AI Pro — Starter',
    description: '24/7 AI Chat + SMS, Call Answering, Basic CRM',
    price: 104.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrbHoA8X09QtFN',
    priceId: 'price_1Sts4vPbfTJTNa5AGANuefZ8',
    name: 'FrontDesk AI Pro — Core',
    description: 'Full AI Front Desk, SMS + Email Campaigns, Booking Automation',
    price: 154.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrbYUyLQZunmmf',
    priceId: 'price_1StsL9PbfTJTNa5Ao4TJoJnB',
    name: 'FrontDesk AI Pro — Accelerator',
    description: 'Complete AI Growth System with call answering, automation workflows, analytics, and multi-channel outreach.Fully automate sales and operations.',
    price: 204.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TriihtcbpmKSch',
    priceId: 'price_1StzGqPbfTJTNa5AChHmt0EU',
    name: 'FrontDesk AI Pro — DFY Setup',
    description: 'White-glove setup and optimization.We configure, train, launch, and manage your AI system for you.True hands-free automation.',
    price: 497.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjC0WXCwDqUFI',
    priceId: 'price_1StzkPPbfTJTNa5AyvBtyXBe',
    name: 'AI Webinar Host Bot',
    description: 'Runs automated webinars, presents content, answers questions, and sells packages 24/7.',
    price: 97.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjRKcxzfifBtm',
    priceId: 'price_1StzyEPbfTJTNa5Ai6YGlcyO',
    name: 'Advanced Voice Sales Agent',
    description: 'Trained closer Negotiates Books + sells',
    price: 79.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjUYL7DOZIuZw',
    priceId: 'price_1Su01tPbfTJTNa5Ak5vbz9Oz',
    name: 'Social DM Automation Bot',
    description: 'full_automation',
    price: 59.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjgnYAwSFB0N8',
    priceId: 'price_1Su0DJPbfTJTNa5Am0h0tM5I',
    name: 'Local SEO Content Bot',
    description: 'Responds to DMs Qualifies Routes to checkout',
    price: 49.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjZppAoHfmJYD',
    priceId: 'price_1Su06KPbfTJTNa5AxojrMaYC',
    name: 'Review Booster Pro',
    description: 'Multi-platform reviews SMS + email requests GMB sync',
    price: 39.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjcwHQxLJJrre',
    priceId: 'price_1Su09bPbfTJTNa5AFXwxPL4O',
    name: 'White-Label Branding Bot',
    description: 'Custom domain Custom logo Remove FD branding',
    price: 99.00,
    currency: 'usd',
    mode: 'subscription'
  },
  {
    id: 'prod_TrjxL4iSESO5zD',
    priceId: 'price_1Su0TgPbfTJTNa5AIvigKgfT',
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

export const stripeProducts = STRIPE_PRODUCTS;