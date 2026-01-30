import { useNavigate, useSearchParams } from 'react-router-dom';
import { Check, ArrowRight } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { getPlanByKey, getDFYPlans } from '../lib/plans';
import { useEffect } from 'react';

interface IndustryConfig {
  industry: string;
  headline: string;
  subhead: string;
  benefits: string[];
  useCase: {
    scenario: string;
    flow: string[];
  };
  botTeam: string;
  recommendedPlan: 'fd_starter' | 'fd_core' | 'fd_pro';
  dfyDescription: string;
}

const industryConfigs: Record<string, IndustryConfig> = {
  cleaning: {
    industry: 'Cleaning Services',
    headline: 'Never Miss Another Cleaning Job Again',
    subhead: 'Let your AI receptionist answer, book, and follow up with every lead — automatically.',
    benefits: [
      'Answers calls & messages 24/7',
      'Books recurring cleanings',
      'Sends reminders',
      'Follows up on quotes',
      'Requests reviews',
    ],
    useCase: {
      scenario: 'When someone messages "How much for a deep clean?"',
      flow: [
        'AI responds instantly',
        'Collects details',
        'Books estimate',
      ],
    },
    botTeam: 'Chat • SMS • Booking • Follow-Up • Reviews',
    recommendedPlan: 'fd_core',
    dfyDescription: 'We set up your pricing, zones, and schedules for you.',
  },
  tree: {
    industry: 'Tree Services',
    headline: 'Capture Emergency Tree Jobs — Even After Hours',
    subhead: 'Your AI answers urgent calls and books estimates 24/7.',
    benefits: [
      'Emergency call handling',
      'Storm job intake',
      'Photo upload forms',
      'Estimate scheduling',
      'Missed call recovery',
    ],
    useCase: {
      scenario: '"Tree fell on my fence!"',
      flow: [
        'AI collects address + photos',
        'Books priority visit',
      ],
    },
    botTeam: 'Voice • Intake • Booking • Priority Routing',
    recommendedPlan: 'fd_pro',
    dfyDescription: 'We configure emergency workflows.',
  },
  medspa: {
    industry: 'Med Spa / Beauty',
    headline: 'Turn Social DMs Into Booked Appointments',
    subhead: 'Convert Instagram and Facebook messages into paying clients.',
    benefits: [
      'IG/FB auto replies',
      'Treatment qualification',
      'Booking automation',
      'Reminder texts',
      'Upsell packages',
    ],
    useCase: {
      scenario: '"Do you do lip filler?"',
      flow: [
        'AI explains',
        'Shows availability',
        'Books consult',
      ],
    },
    botTeam: 'Social DM • Booking • Sales • Upsell',
    recommendedPlan: 'fd_core',
    dfyDescription: 'We connect socials and scripts.',
  },
  contractor: {
    industry: 'Contractors',
    headline: 'Stop Losing Jobs to Faster Competitors',
    subhead: 'Instant replies and automated estimates win more projects.',
    benefits: [
      'Quote follow-ups',
      'Photo intake',
      'Appointment routing',
      'CRM updates',
      'Lead scoring',
    ],
    useCase: {
      scenario: '"Can you give me a quote?"',
      flow: [
        'AI gathers photos',
        'Schedules visit',
      ],
    },
    botTeam: 'Chat • Intake • CRM • Follow-Up • Routing',
    recommendedPlan: 'fd_core',
    dfyDescription: 'We build your estimating funnel.',
  },
  realestate: {
    industry: 'Real Estate',
    headline: 'Respond to New Leads in Under 10 Seconds',
    subhead: 'AI that qualifies buyers and sellers instantly.',
    benefits: [
      'Zillow/Facebook lead follow-up',
      'Buyer qualification',
      'Showing scheduling',
      'Long-term nurturing',
      'CRM sync',
    ],
    useCase: {
      scenario: '"I\'m interested in this home"',
      flow: [
        'AI qualifies',
        'Books showing',
      ],
    },
    botTeam: 'Lead Intelligence • Booking • Nurture • CRM',
    recommendedPlan: 'fd_pro',
    dfyDescription: 'We connect MLS + lead feeds.',
  },
};

export default function IndustryLanding({ industryKey }: { industryKey: string }) {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const config = industryConfigs[industryKey];

  const referralSlug = searchParams.get('ref');

  useEffect(() => {
    if (referralSlug) {
      localStorage.setItem('referral_slug', referralSlug);
    }
  }, [referralSlug]);

  if (!config) {
    navigate('/');
    return null;
  }

  const recommendedPlan = getPlanByKey(config.recommendedPlan);
  const dfyPlans = getDFYPlans();

  const handlePlanSelect = (planKey: string) => {
    const slug = localStorage.getItem('referral_slug');
    const url = `/pricing?plan=${planKey}${slug ? `&ref=${slug}` : ''}`;
    navigate(url);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <h2 className="text-2xl font-bold text-slate-900">FrontDesk AI Pro</h2>
            <Button onClick={() => navigate('/pricing')} variant="outline">
              View All Plans
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-block px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-medium mb-6">
            {config.industry}
          </div>
          <h1 className="text-5xl font-bold text-slate-900 mb-6">
            {config.headline}
          </h1>
          <p className="text-xl text-slate-600 mb-8">
            {config.subhead}
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button
              size="lg"
              onClick={() => handlePlanSelect(recommendedPlan.key)}
            >
              Start My AI Front Desk
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
            <Button
              size="lg"
              variant="outline"
              onClick={() => navigate('/webinar')}
            >
              Watch Demo
            </Button>
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-12 text-center">
            What Your AI Front Desk Does
          </h2>
          <div className="grid md:grid-cols-2 gap-6">
            {config.benefits.map((benefit, idx) => (
              <div key={idx} className="flex items-start gap-3">
                <Check className="h-6 w-6 text-green-600 flex-shrink-0 mt-1" />
                <span className="text-lg text-slate-700">{benefit}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Use Case */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-8 text-center">
            How It Works
          </h2>
          <div className="bg-white rounded-2xl shadow-lg p-8 border border-slate-200">
            <p className="text-lg font-semibold text-slate-900 mb-6">
              {config.useCase.scenario}
            </p>
            <div className="space-y-4">
              {config.useCase.flow.map((step, idx) => (
                <div key={idx} className="flex items-center gap-4">
                  <div className="flex-shrink-0 w-8 h-8 bg-blue-600 text-white rounded-full flex items-center justify-center font-bold">
                    {idx + 1}
                  </div>
                  <span className="text-slate-700">{step}</span>
                </div>
              ))}
            </div>
            <div className="mt-8 pt-8 border-t border-slate-200">
              <p className="text-sm font-medium text-slate-500 mb-2">YOUR BOT TEAM</p>
              <p className="text-slate-900 font-semibold">{config.botTeam}</p>
            </div>
          </div>
        </div>
      </section>

      {/* Recommended Plan */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-4 text-center">
            Recommended For {config.industry}
          </h2>
          <p className="text-slate-600 text-center mb-12">
            Most {config.industry.toLowerCase()} businesses choose {recommendedPlan.name}
          </p>

          <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl p-8 border-2 border-blue-600 shadow-xl">
            <div className="flex justify-between items-start mb-6">
              <div>
                <h3 className="text-2xl font-bold text-slate-900">{recommendedPlan.name}</h3>
                {recommendedPlan.description && (
                  <p className="text-blue-700 font-semibold mt-1">{recommendedPlan.description}</p>
                )}
              </div>
              <div className="text-right">
                <p className="text-4xl font-bold text-slate-900">${recommendedPlan.price}</p>
                <p className="text-slate-600">/month</p>
              </div>
            </div>

            <ul className="space-y-3 mb-8">
              {recommendedPlan.features.map((feature, idx) => (
                <li key={idx} className="flex items-start gap-3">
                  <Check className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                  <span className="text-slate-700">{feature}</span>
                </li>
              ))}
            </ul>

            <Button
              size="lg"
              className="w-full"
              onClick={() => handlePlanSelect(recommendedPlan.key)}
            >
              Get Started with {recommendedPlan.name}
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
          </div>
        </div>
      </section>

      {/* DFY Section */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-4 text-center">
            Or Go Hands-Free with DFY Setup
          </h2>
          <p className="text-slate-600 text-center mb-12">
            {config.dfyDescription}
          </p>

          <div className="grid md:grid-cols-2 gap-6">
            {dfyPlans.map((plan) => (
              <div
                key={plan.key}
                className="bg-white rounded-xl p-8 border-2 border-slate-200 hover:border-blue-600 transition-colors shadow-lg"
              >
                <h3 className="text-2xl font-bold text-slate-900 mb-2">{plan.name}</h3>
                {plan.description && (
                  <p className="text-slate-600 font-semibold mb-4">{plan.description}</p>
                )}
                <p className="text-4xl font-bold text-slate-900 mb-6">
                  ${plan.price}<span className="text-lg font-normal text-slate-600">/mo</span>
                </p>

                <ul className="space-y-3 mb-8">
                  {plan.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start gap-3">
                      <Check className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                      <span className="text-slate-700 text-sm">{feature}</span>
                    </li>
                  ))}
                </ul>

                <Button
                  size="lg"
                  variant="outline"
                  className="w-full"
                  onClick={() => handlePlanSelect(plan.key)}
                >
                  Choose {plan.name}
                </Button>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Trust Section */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-slate-50">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-2xl font-bold text-slate-900 mb-8">
            Why FrontDesk AI Pro?
          </h2>
          <div className="grid sm:grid-cols-2 md:grid-cols-4 gap-6">
            <div>
              <Check className="h-8 w-8 text-green-600 mx-auto mb-2" />
              <p className="font-semibold text-slate-900">No contracts</p>
            </div>
            <div>
              <Check className="h-8 w-8 text-green-600 mx-auto mb-2" />
              <p className="font-semibold text-slate-900">Cancel anytime</p>
            </div>
            <div>
              <Check className="h-8 w-8 text-green-600 mx-auto mb-2" />
              <p className="font-semibold text-slate-900">Setup in hours</p>
            </div>
            <div>
              <Check className="h-8 w-8 text-green-600 mx-auto mb-2" />
              <p className="font-semibold text-slate-900">24/7 support</p>
            </div>
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-blue-600 to-indigo-600 text-white">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl font-bold mb-6">
            Ready to Automate Your Front Desk?
          </h2>
          <p className="text-xl mb-8 text-blue-100">
            Join businesses using AI to capture more leads and book more appointments
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button
              size="lg"
              variant="outline"
              className="bg-white text-blue-600 hover:bg-slate-50"
              onClick={() => handlePlanSelect(recommendedPlan.key)}
            >
              Start Now
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="border-white text-white hover:bg-blue-700"
              onClick={() => navigate('/webinar')}
            >
              Watch Demo
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
}
