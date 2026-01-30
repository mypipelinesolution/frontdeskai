import { useState } from 'react';
import { Check, Zap, Star, Crown, MessageCircle, Mail, Phone, Calendar } from 'lucide-react';
import { getProductsByCategory, formatPrice } from '../stripe-config';

const PricingSection = () => {
  const [loading, setLoading] = useState<string | null>(null);

  const plans = getProductsByCategory('plan');
  const addons = getProductsByCategory('addon');

  const handleCheckout = async (priceId: string, productName: string) => {
    setLoading(priceId);

    try {
      console.log('=== CHECKOUT DEBUG START ===');
      console.log('Price ID:', priceId);
      console.log('Product:', productName);
      console.log('Supabase URL:', import.meta.env.VITE_SUPABASE_URL);
      console.log('Supabase Anon Key exists:', !!import.meta.env.VITE_SUPABASE_ANON_KEY);
      console.log('Supabase Anon Key (first 20 chars):', import.meta.env.VITE_SUPABASE_ANON_KEY?.substring(0, 20));
      console.log('Full endpoint:', `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout`);

      const requestBody = { price_id: priceId };
      console.log('Request body:', requestBody);

      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify(requestBody)
      });

      console.log('Response status:', response.status);
      console.log('Response headers:', Object.fromEntries(response.headers.entries()));

      const responseText = await response.text();
      console.log('Response text:', responseText);

      let data;
      try {
        data = JSON.parse(responseText);
        console.log('Parsed response data:', data);
      } catch (e) {
        console.error('Failed to parse response as JSON:', e);
        throw new Error(`Server returned invalid JSON: ${responseText.substring(0, 100)}`);
      }

      if (!response.ok) {
        console.error('ERROR - Response not OK');
        console.error('Error data:', data);
        throw new Error(data.error || `HTTP ${response.status}: ${responseText}`);
      }

      if (data?.error) {
        console.error('ERROR in response data:', data.error);
        throw new Error(data.error);
      }

      if (data?.url) {
        console.log('SUCCESS - Got checkout URL:', data.url);
        console.log('Session ID:', data.sessionId);
        console.log('Redirecting now...');
        window.location.href = data.url;
      } else {
        console.error('ERROR - No URL in response');
        console.error('Full response:', data);
        throw new Error('No checkout URL received from server');
      }
    } catch (error) {
      console.error('=== CHECKOUT ERROR ===');
      console.error('Error type:', error instanceof Error ? error.constructor.name : typeof error);
      console.error('Error message:', error instanceof Error ? error.message : String(error));
      console.error('Full error:', error);
      console.error('=== CHECKOUT DEBUG END ===');

      alert(`CHECKOUT FAILED\n\n${error instanceof Error ? error.message : 'Unknown error'}\n\nCheck console (F12) for details`);
    } finally {
      setLoading(null);
    }
  };

  const getPlanIcon = (name: string) => {
    if (name.includes('Starter')) return <Zap className="w-8 h-8 text-cyan-400" />;
    if (name.includes('Core')) return <Star className="w-8 h-8 text-purple-400" />;
    if (name.includes('Accelerator')) return <Crown className="w-8 h-8 text-lime-400" />;
    if (name.includes('DFY')) return <Crown className="w-8 h-8 text-lime-400" />;
    return <Zap className="w-8 h-8 text-gray-400" />;
  };

  const getPlanFeatures = (name: string) => {
    if (name.includes('Starter')) {
      return [
        '4 Core Foundation Bots',
        '5 Starter Plan Bots',
        '24/7 AI Chat Widget',
        'Missed Call Text Bot',
        'Basic Follow-Up Sequences',
        'Simple Reporting Dashboard'
      ];
    }
    if (name.includes('Core')) {
      return [
        'Everything in Starter',
        '6 Additional Core Tier Bots',
        'Smart Booking System',
        'Sales Conversation Bot',
        'CRM Manager Bot',
        'Campaign Builder',
        'Reputation Monitor'
      ];
    }
    if (name.includes('Accelerator')) {
      return [
        'Everything in Core',
        '6 Additional Accelerator Bots',
        'AI Call Answering Bot',
        'Lead Nurture Engine',
        'Workflow Automation',
        'Analytics & Revenue Bot',
        'Multi-Channel Orchestrator'
      ];
    }
    if (name.includes('DFY')) {
      return [
        'Complete Done-For-You Setup',
        'White-glove configuration',
        'AI training on your business',
        'Campaign launch & optimization',
        'Ad integration setup',
        'Ongoing optimization coaching'
      ];
    }
    return [];
  };

  const getAddonFeatures = (name: string) => {
    if (name.includes('Webinar')) {
      return [
        'webinar hosting',
        'presentation',
        'qa handling'
      ];
    }
    if (name.includes('Voice Sales')) {
      return [
        'voice sales',
        'negotiation',
        'advanced closing'
      ];
    }
    if (name.includes('Social DM') || name.includes('DM Automation')) {
      return [
        'fb messenger',
        'instagram dm',
        'social qualification'
      ];
    }
    if (name.includes('Review Booster')) {
      return [
        'multi platform reviews',
        'automated requests',
        'gmb integration'
      ];
    }
    if (name.includes('White-Label') || name.includes('Branding')) {
      return [
        'custom domain',
        'custom branding',
        'white label'
      ];
    }
    if (name.includes('SEO Content') || name.includes('Local SEO')) {
      return [
        'content generation',
        'blog posts',
        'seo optimization'
      ];
    }
    return [];
  };

  return (
    <div id="pricing" className="pt-8 pb-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        {/* Features Section */}
        <div className="text-center mb-20">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-6">
            What Can FrontDesk AI Pro Do For You?
          </h2>
          <p className="text-xl text-purple-200 max-w-3xl mx-auto mb-16">
            Pick a plan — the bots do the selling, follow-up, booking and reminders.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
            <div className="bg-gradient-to-br from-purple-900/40 via-purple-800/30 to-purple-900/40 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30 transition-all duration-300 hover:border-cyan-400/40 hover:shadow-xl hover:shadow-cyan-400/10">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-4 w-16 h-16 flex items-center justify-center mb-6">
                <MessageCircle className="w-8 h-8 text-cyan-400" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">24/7 Live Chatbot</h3>
              <p className="text-purple-200 text-sm leading-relaxed">Instant replies + lead capture</p>
            </div>

            <div className="bg-gradient-to-br from-purple-900/40 via-purple-800/30 to-purple-900/40 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30 transition-all duration-300 hover:border-cyan-400/40 hover:shadow-xl hover:shadow-cyan-400/10">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Mail className="w-8 h-8 text-cyan-400" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">Automated SMS & Email</h3>
              <p className="text-purple-200 text-sm leading-relaxed">Nurture leads automatically</p>
            </div>

            <div className="bg-gradient-to-br from-purple-900/40 via-purple-800/30 to-purple-900/40 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30 transition-all duration-300 hover:border-cyan-400/40 hover:shadow-xl hover:shadow-cyan-400/10">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Phone className="w-8 h-8 text-cyan-400" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">AI Call Answering</h3>
              <p className="text-purple-200 text-sm leading-relaxed">Capture calls & messages</p>
            </div>

            <div className="bg-gradient-to-br from-purple-900/40 via-purple-800/30 to-purple-900/40 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30 transition-all duration-300 hover:border-cyan-400/40 hover:shadow-xl hover:shadow-cyan-400/10">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-4 w-16 h-16 flex items-center justify-center mb-6">
                <Calendar className="w-8 h-8 text-cyan-400" />
              </div>
              <h3 className="text-xl font-bold text-white mb-3">Smart Appointment Booking</h3>
              <p className="text-purple-200 text-sm leading-relaxed">Fill your calendar</p>
            </div>
          </div>
        </div>

        {/* Pricing Section */}
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-white mb-4">
            Simple, Transparent Pricing
          </h2>
          <p className="text-xl text-purple-200 max-w-3xl mx-auto">
            From basic automation to complete AI-powered business management.
            Scale your customer service without scaling your team.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
          {plans.map((plan) => (
            <div
              key={plan.id}
              className={`relative bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl shadow-2xl border transition-all duration-300 ${
                plan.name.includes('Core')
                  ? 'border-cyan-400/40 ring-2 ring-cyan-400/30'
                  : 'border-purple-500/30'
              }`}
            >
              <div className="p-6">
                {plan.name.includes('Core') && (
                  <div className="flex justify-center mb-4">
                    <span className="bg-gradient-to-r from-lime-500 to-emerald-500 text-white px-4 py-1.5 rounded-full text-xs font-bold tracking-wider shadow-lg shadow-lime-500/30 uppercase">
                      Most Popular
                    </span>
                  </div>
                )}
                <div className="flex items-center justify-center mb-3">
                  {getPlanIcon(plan.name)}
                </div>

                <h3 className="text-xl font-bold text-white text-center mb-4">
                  {plan.name.replace('FrontDesk AI Pro — ', '')}
                </h3>

                <div className="text-center mb-4">
                  <span className="text-4xl font-bold text-white">
                    {formatPrice(plan.price)}
                  </span>
                  <span className="text-purple-300 text-sm">/month</span>
                </div>

                <p className="text-purple-200 text-center text-sm mb-6 min-h-[2.5rem] leading-tight">
                  {plan.description}
                </p>

                <ul className="space-y-2.5 mb-6">
                  {getPlanFeatures(plan.name).map((feature, index) => (
                    <li key={index} className="flex items-start">
                      <Check className="w-4 h-4 text-cyan-400 mr-2 mt-0.5 flex-shrink-0" />
                      <span className="text-purple-100 text-xs leading-relaxed">{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => handleCheckout(plan.priceId, plan.name)}
                  disabled={loading === plan.priceId}
                  className={`w-full py-3 px-6 rounded-xl font-bold text-sm transition-all duration-200 ${
                    plan.name.includes('Core')
                      ? 'bg-gradient-to-r from-lime-500 via-green-500 to-emerald-600 hover:from-lime-400 hover:via-green-400 hover:to-emerald-500 text-white shadow-lg shadow-lime-500/30'
                      : 'bg-gradient-to-r from-emerald-500 to-purple-600 hover:from-emerald-400 hover:to-purple-500 text-white shadow-lg'
                  } ${loading === plan.priceId ? 'opacity-70 cursor-not-allowed' : ''}`}
                >
                  {loading === plan.priceId ? 'Processing...' : 'Get Started'}
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Add-on Products */}
        <div className="border-t border-purple-500/30 pt-16">
          <div className="text-center mb-12">
            <h3 className="text-3xl font-bold text-white mb-4">
              Premium Add-Ons
            </h3>
            <p className="text-lg text-purple-200">
              Supercharge your AI system with specialized bots and advanced features
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {addons.map((addon) => (
              <div
                key={addon.id}
                className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md rounded-xl shadow-lg border border-purple-500/40 hover:border-cyan-400/60 hover:shadow-xl hover:shadow-purple-500/30 transition-all duration-300 p-6"
              >
                <div className="flex items-start gap-4 mb-4">
                  <div className="bg-purple-600/40 rounded-xl p-3 flex-shrink-0">
                    <Zap className="w-6 h-6 text-purple-300" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-xl font-bold text-white mb-1">
                      {addon.name}
                    </h4>
                    <span className="text-lg font-bold text-purple-300">
                      {formatPrice(addon.price)}
                      <span className="text-sm text-purple-400">/month</span>
                    </span>
                  </div>
                </div>

                <p className="text-purple-200 mb-4 text-sm">
                  {addon.description}
                </p>

                <ul className="space-y-2 mb-6">
                  {getAddonFeatures(addon.name).map((feature, index) => (
                    <li key={index} className="flex items-start">
                      <Check className="w-4 h-4 text-purple-300 mr-2 mt-0.5 flex-shrink-0" />
                      <span className="text-purple-200 text-sm">{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => handleCheckout(addon.priceId, addon.name)}
                  disabled={loading === addon.priceId}
                  className={`w-full py-3 px-4 rounded-xl font-semibold transition-all duration-200 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 text-white shadow-lg shadow-purple-500/30 ${
                    loading === addon.priceId ? 'opacity-50 cursor-not-allowed' : ''
                  }`}
                >
                  {loading === addon.priceId ? 'Processing...' : 'Add to Plan'}
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Enterprise CTA */}
        <div className="mt-16 text-center">
          <div className="bg-gradient-to-r from-purple-900/50 to-fuchsia-900/50 rounded-2xl p-8 text-white shadow-2xl shadow-purple-500/30 border border-purple-400/40 backdrop-blur-md">
            <h3 className="text-2xl font-bold mb-4">
              Launch Your AI Marketing Empire in 1 Click
            </h3>
            <p className="text-lg mb-6 text-purple-200">
              Don't Miss Out! Get it all set up for you — Enterprise plans with custom integrations and white-label options available.
            </p>
            <button
              onClick={() => {
                const demoSection = document.querySelector('form');
                if (demoSection) {
                  demoSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }}
              className="bg-gradient-to-r from-lime-500 via-emerald-500 to-green-600 text-white px-8 py-3 rounded-xl font-semibold hover:from-lime-400 hover:via-emerald-400 hover:to-green-500 transition-all shadow-lg shadow-lime-500/50"
            >
              Get Your Free Demo
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export { PricingSection };
export default PricingSection;