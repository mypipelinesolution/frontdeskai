import { useParams, useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { ArrowRight, Check } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { getMainPlans, getDFYPlans } from '../lib/plans';

export default function PartnerPublicPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();

  useEffect(() => {
    if (slug) {
      localStorage.setItem('referral_slug', slug);
    }
  }, [slug]);

  const mainPlans = getMainPlans();
  const dfyPlans = getDFYPlans();

  const handleAction = (path: string) => {
    navigate(`${path}?ref=${slug}`);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-50 to-white">
      {/* Header */}
      <header className="border-b bg-white/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-2xl font-bold text-slate-900">FrontDesk AI Pro</h2>
              <p className="text-sm text-slate-600 mt-1">Powered by {slug}</p>
            </div>
            <Button onClick={() => handleAction('/pricing')} variant="outline">
              View Plans
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-block px-4 py-2 bg-blue-100 text-blue-700 rounded-full text-sm font-medium mb-6">
            Partner Exclusive Access
          </div>
          <h1 className="text-5xl md:text-6xl font-bold text-slate-900 mb-6">
            Your 24/7 AI Front Desk
          </h1>
          <p className="text-xl text-slate-600 mb-8 max-w-2xl mx-auto">
            Never miss a lead again. FrontDesk AI Pro answers calls, texts, and messages
            automatically — even when you're busy or after hours.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" onClick={() => handleAction('/pricing')}>
              Get Started
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
            <Button size="lg" variant="outline" onClick={() => handleAction('/webinar')}>
              Watch Demo
            </Button>
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-12 text-center">
            What FrontDesk AI Pro Does For You
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-2">Capture Every Lead</h3>
              <p className="text-slate-600">
                Answer calls, texts, and messages instantly — 24/7
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-2">Book Appointments</h3>
              <p className="text-slate-600">
                Automated booking system syncs with your calendar
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="h-8 w-8 text-purple-600" />
              </div>
              <h3 className="text-xl font-semibold text-slate-900 mb-2">Follow Up Automatically</h3>
              <p className="text-slate-600">
                Smart campaigns keep leads engaged until they buy
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Plans Section */}
      <section className="py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-4 text-center">
            Choose Your Plan
          </h2>
          <p className="text-slate-600 text-center mb-12 max-w-2xl mx-auto">
            All plans include AI chat, SMS, booking, and CRM. Cancel anytime.
          </p>

          <div className="grid md:grid-cols-3 gap-8 mb-12">
            {mainPlans.map((plan) => (
              <div
                key={plan.key}
                className={`bg-white rounded-xl p-8 border-2 ${
                  plan.popular ? 'border-blue-600 shadow-xl' : 'border-slate-200'
                } hover:shadow-lg transition-all`}
              >
                {plan.popular && (
                  <div className="bg-blue-600 text-white text-sm font-semibold px-3 py-1 rounded-full inline-block mb-4">
                    MOST POPULAR
                  </div>
                )}
                <h3 className="text-2xl font-bold text-slate-900 mb-2">{plan.name}</h3>
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
                  className="w-full"
                  variant={plan.popular ? 'default' : 'outline'}
                  onClick={() => handleAction(`/pricing?plan=${plan.key}`)}
                >
                  Choose {plan.name}
                </Button>
              </div>
            ))}
          </div>

          {/* DFY Section */}
          <div className="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-2xl p-8 text-white">
            <h3 className="text-3xl font-bold mb-4 text-center">Want It Done For You?</h3>
            <p className="text-blue-100 text-center mb-8 max-w-2xl mx-auto">
              Our DFY team configures everything for you — workflows, campaigns, CRM, and more.
            </p>
            <div className="grid md:grid-cols-2 gap-6 max-w-4xl mx-auto">
              {dfyPlans.map((plan) => (
                <div key={plan.key} className="bg-white/10 backdrop-blur rounded-xl p-6 border border-white/20">
                  <h4 className="text-xl font-bold mb-2">{plan.name}</h4>
                  <p className="text-3xl font-bold mb-4">
                    ${plan.price}<span className="text-lg font-normal">/mo</span>
                  </p>
                  <ul className="space-y-2 mb-6">
                    {plan.features.slice(0, 3).map((feature, idx) => (
                      <li key={idx} className="flex items-start gap-2 text-sm">
                        <Check className="h-4 w-4 flex-shrink-0 mt-0.5" />
                        <span>{feature}</span>
                      </li>
                    ))}
                  </ul>
                  <Button
                    variant="outline"
                    className="w-full bg-white text-blue-600 hover:bg-slate-50 border-0"
                    onClick={() => handleAction(`/pricing?plan=${plan.key}`)}
                  >
                    Choose {plan.name}
                  </Button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Industries */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-slate-50">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-slate-900 mb-12 text-center">
            Built For Your Industry
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-5 gap-4">
            {[
              { name: 'Cleaning', path: '/industries/cleaning' },
              { name: 'Tree Service', path: '/industries/tree' },
              { name: 'Med Spa', path: '/industries/medspa' },
              { name: 'Contractors', path: '/industries/contractor' },
              { name: 'Real Estate', path: '/industries/realestate' },
            ].map((industry) => (
              <button
                key={industry.path}
                onClick={() => handleAction(industry.path)}
                className="bg-white rounded-lg p-6 text-center hover:shadow-lg transition-all border border-slate-200 hover:border-blue-600"
              >
                <p className="font-semibold text-slate-900">{industry.name}</p>
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* Footer CTA */}
      <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl font-bold text-slate-900 mb-6">
            Ready to Stop Missing Leads?
          </h2>
          <p className="text-xl text-slate-600 mb-8">
            Join hundreds of businesses using AI to capture more leads and book more appointments
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" onClick={() => handleAction('/pricing')}>
              Get Started Now
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
            <Button size="lg" variant="outline" onClick={() => handleAction('/webinar')}>
              Watch Free Demo
            </Button>
          </div>
          <p className="text-sm text-slate-500 mt-8">
            No contracts • Cancel anytime • Setup in hours
          </p>
        </div>
      </section>
    </div>
  );
}
