import { useState, useEffect } from 'react';
import { CheckCircle2, ArrowRight } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { supabase } from '../lib/supabase';

const TIERS = {
  regional: {
    name: 'Regional Operator',
    setupFee: 250000,
    monthlyFee: 49900,
    perUnitFee: 4900,
    unitLabel: 'location',
    features: [
      'Full white-label branding',
      'Custom domain setup',
      'Up to 50 locations',
      '40+ AI Bot ecosystem',
      'Multi-location dashboard',
      'Standard support',
      'Email & SMS automation',
      'CRM integration',
    ],
  },
  agency: {
    name: 'Agency Network',
    setupFee: 500000,
    monthlyFee: 99700,
    perUnitFee: 2500,
    unitLabel: 'client',
    features: [
      'Everything in Regional',
      'Unlimited clients',
      'Priority support',
      'Dedicated account manager',
      'White-label client portals',
      'Advanced analytics',
      'Custom bot training',
      'API access',
    ],
    popular: true,
  },
  custom: {
    name: 'Enterprise Custom',
    setupFee: 1000000,
    monthlyFee: 150000,
    perUnitFee: 0,
    unitLabel: 'custom',
    features: [
      'Everything in Agency',
      'Custom bot development',
      'Dedicated infrastructure',
      'White-glove onboarding',
      'Unlimited everything',
      'Custom integrations',
      'Private AI models',
      'Enterprise SLA',
    ],
  },
};

export default function EnterpriseOffer() {
  const [selectedTier, setSelectedTier] = useState<'regional' | 'agency' | 'custom'>('agency');
  const [isProcessing, setIsProcessing] = useState(false);
  const [partnerSlug, setPartnerSlug] = useState<string | null>(null);

  useEffect(() => {
    const stored = localStorage.getItem('enterprise_partner_slug');
    if (stored) setPartnerSlug(stored);
  }, []);

  const formatPrice = (cents: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(cents / 100);
  };

  const handleCheckout = async () => {
    setIsProcessing(true);

    try {
      const tier = TIERS[selectedTier];

      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/enterprise-checkout`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          },
          body: JSON.stringify({
            tier: selectedTier,
            partner_slug: partnerSlug,
            setup_fee_cents: tier.setupFee,
            monthly_fee_cents: tier.monthlyFee,
            per_unit_fee_cents: tier.perUnitFee,
          }),
        }
      );

      if (!response.ok) throw new Error('Failed to create checkout');

      const { url } = await response.json();
      window.location.href = url;
    } catch (error) {
      console.error('Checkout error:', error);
      alert('Failed to start checkout. Please try again or contact support.');
      setIsProcessing(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-50">
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold mb-4">
              Secure Your Enterprise License
            </h1>
            <p className="text-xl text-slate-600">
              Choose the tier that fits your business and launch your branded AI platform
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6 mb-12">
            {Object.entries(TIERS).map(([key, tier]) => {
              const isSelected = selectedTier === key;
              const tierKey = key as 'regional' | 'agency' | 'custom';

              return (
                <div
                  key={key}
                  onClick={() => setSelectedTier(tierKey)}
                  className={`
                    relative bg-white rounded-xl shadow-xl p-8 cursor-pointer transition-all
                    ${isSelected ? 'ring-4 ring-blue-600 scale-105' : 'hover:shadow-2xl'}
                    ${tier.popular ? 'border-4 border-blue-600' : ''}
                  `}
                >
                  {tier.popular && (
                    <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white px-4 py-1 rounded-full text-sm font-bold">
                      MOST POPULAR
                    </div>
                  )}

                  <div className="text-center mb-6">
                    <h3 className="text-2xl font-bold mb-2">{tier.name}</h3>
                    <div className="text-4xl font-bold text-blue-600 mb-1">
                      {formatPrice(tier.setupFee)}
                    </div>
                    <div className="text-sm text-slate-600 mb-3">Setup Fee</div>
                    <div className="text-3xl font-bold mb-1">
                      {formatPrice(tier.monthlyFee)}
                      <span className="text-lg font-normal text-slate-600">/mo</span>
                    </div>
                    {tier.perUnitFee > 0 && (
                      <div className="text-sm text-slate-600">
                        + {formatPrice(tier.perUnitFee)} per {tier.unitLabel}
                      </div>
                    )}
                    {tier.perUnitFee === 0 && key === 'custom' && (
                      <div className="text-sm text-slate-600">
                        Custom pricing
                      </div>
                    )}
                  </div>

                  <ul className="space-y-3 mb-6">
                    {tier.features.map((feature, i) => (
                      <li key={i} className="flex gap-2 text-sm">
                        <CheckCircle2 className="w-5 h-5 text-green-600 flex-shrink-0" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>

                  {isSelected && (
                    <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 bg-green-600 text-white px-4 py-1 rounded-full text-sm font-bold">
                      SELECTED
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="bg-white rounded-xl shadow-xl p-8 max-w-3xl mx-auto">
            <h2 className="text-3xl font-bold mb-6 text-center">
              Ready to Launch Your Enterprise Platform?
            </h2>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
              <h3 className="font-bold mb-3">You've Selected: {TIERS[selectedTier].name}</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span>Setup Fee:</span>
                  <span className="font-bold">{formatPrice(TIERS[selectedTier].setupFee)}</span>
                </div>
                <div className="flex justify-between">
                  <span>Monthly License:</span>
                  <span className="font-bold">{formatPrice(TIERS[selectedTier].monthlyFee)}</span>
                </div>
                {TIERS[selectedTier].perUnitFee > 0 && (
                  <div className="flex justify-between">
                    <span>Per {TIERS[selectedTier].unitLabel}:</span>
                    <span className="font-bold">{formatPrice(TIERS[selectedTier].perUnitFee)}</span>
                  </div>
                )}
                <div className="border-t border-blue-300 pt-2 mt-2 flex justify-between text-lg">
                  <span className="font-bold">Due at Signing:</span>
                  <span className="font-bold text-blue-600">
                    {formatPrice(TIERS[selectedTier].setupFee + TIERS[selectedTier].monthlyFee)}
                  </span>
                </div>
              </div>
            </div>

            <div className="space-y-4 mb-6">
              <h3 className="font-bold">What Happens After Checkout:</h3>
              <div className="space-y-3">
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <span className="font-bold text-blue-600 text-sm">1</span>
                  </div>
                  <div>
                    <div className="font-semibold">Contract Signing</div>
                    <div className="text-sm text-slate-600">E-sign your license agreement</div>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <span className="font-bold text-blue-600 text-sm">2</span>
                  </div>
                  <div>
                    <div className="font-semibold">Onboarding Kickoff</div>
                    <div className="text-sm text-slate-600">Meet your dedicated account manager</div>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <span className="font-bold text-blue-600 text-sm">3</span>
                  </div>
                  <div>
                    <div className="font-semibold">Platform Setup</div>
                    <div className="text-sm text-slate-600">Branding, domain, and configuration</div>
                  </div>
                </div>
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <CheckCircle2 className="w-5 h-5 text-green-600" />
                  </div>
                  <div>
                    <div className="font-semibold">Go Live</div>
                    <div className="text-sm text-slate-600">Launch your branded AI platform in 30 days</div>
                  </div>
                </div>
              </div>
            </div>

            <Button
              onClick={handleCheckout}
              disabled={isProcessing}
              className="w-full py-4 text-lg"
            >
              {isProcessing ? (
                'Processing...'
              ) : (
                <>
                  Proceed to Secure Checkout
                  <ArrowRight className="w-5 h-5 ml-2" />
                </>
              )}
            </Button>

            <p className="text-sm text-slate-500 text-center mt-4">
              Secure payment processing via Stripe. 12-month minimum term.
            </p>
          </div>

          <div className="mt-12 text-center">
            <p className="text-slate-600 mb-2">
              Have questions or need a custom quote?
            </p>
            <a
              href="mailto:enterprise@frontdeskaipro.com"
              className="text-blue-600 hover:underline font-semibold"
            >
              Contact our Enterprise team
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
