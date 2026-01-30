import { useState, useEffect } from 'react';
import { Building2, CheckCircle2, Users, Shield, Zap, TrendingUp } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { supabase } from '../lib/supabase';

export default function EnterpriseLanding() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    company: '',
    size_clients: '',
    current_crm: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [partnerSlug, setPartnerSlug] = useState<string | null>(null);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const p = params.get('p') || params.get('ref');

    if (p) {
      setPartnerSlug(p);
      localStorage.setItem('enterprise_partner_slug', p);
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + 30);
      document.cookie = `enterprise_partner_slug=${p}; expires=${expiryDate.toUTCString()}; path=/`;
    } else {
      const stored = localStorage.getItem('enterprise_partner_slug');
      if (stored) setPartnerSlug(stored);
    }

    const utmSource = params.get('utm_source');
    const utmCampaign = params.get('utm_campaign');
    const utmMedium = params.get('utm_medium');

    if (utmSource) localStorage.setItem('enterprise_utm_source', utmSource);
    if (utmCampaign) localStorage.setItem('enterprise_utm_campaign', utmCampaign);
    if (utmMedium) localStorage.setItem('enterprise_utm_medium', utmMedium);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const utmSource = localStorage.getItem('enterprise_utm_source');
      const utmCampaign = localStorage.getItem('enterprise_utm_campaign');
      const utmMedium = localStorage.getItem('enterprise_utm_medium');

      const { data: lead, error } = await supabase
        .from('enterprise_leads')
        .insert({
          name: formData.name,
          email: formData.email,
          phone: formData.phone,
          company: formData.company,
          size_clients: formData.size_clients ? parseInt(formData.size_clients) : null,
          current_crm: formData.current_crm,
          partner_slug: partnerSlug,
          utm_source: utmSource,
          utm_campaign: utmCampaign,
          utm_medium: utmMedium,
          status: 'registered',
        })
        .select()
        .single();

      if (error) throw error;

      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/enterprise-register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({
          lead_id: lead.id,
          email: formData.email,
          name: formData.name,
        }),
      });

      if (!response.ok) throw new Error('Failed to send access link');

      setSubmitted(true);
    } catch (error) {
      console.error('Error submitting registration:', error);
      alert('Failed to register. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-50">
        <div className="container mx-auto px-4 py-20">
          <div className="max-w-2xl mx-auto text-center">
            <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <CheckCircle2 className="w-12 h-12 text-green-600" />
            </div>
            <h1 className="text-4xl font-bold mb-4">Check Your Email</h1>
            <p className="text-xl text-slate-600 mb-8">
              We've sent your Enterprise Demo replay link and offer access to <strong>{formData.email}</strong>
            </p>
            <div className="bg-white rounded-lg shadow-lg p-8 text-left">
              <h2 className="text-2xl font-bold mb-4">What's Next:</h2>
              <ul className="space-y-4">
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Check your email for your personal replay link (expires in 7 days)</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Watch the full 45-minute Enterprise Demo at your convenience</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Review the Enterprise Tiers and pricing options</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Apply for your Enterprise License when ready</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-50">
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold mb-4">
              Own Your Own AI-Powered Operations Platform
            </h1>
            <p className="text-2xl text-slate-600 mb-2">
              Without Building One
            </p>
            <p className="text-xl text-slate-500 max-w-3xl mx-auto">
              Launch a fully branded AI sales, support, and automation system for your agency,
              network, or multi-location business.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 mb-16">
            <div className="bg-white rounded-xl shadow-xl p-8">
              <h2 className="text-3xl font-bold mb-6">Reserve Your Demo Access</h2>
              <form onSubmit={handleSubmit} className="space-y-4">
                <Input
                  label="Full Name"
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="John Smith"
                />
                <Input
                  label="Email"
                  type="email"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="john@company.com"
                />
                <Input
                  label="Phone"
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  placeholder="(555) 123-4567"
                />
                <Input
                  label="Company Name"
                  type="text"
                  required
                  value={formData.company}
                  onChange={(e) => setFormData({ ...formData, company: e.target.value })}
                  placeholder="ABC Agency"
                />
                <Input
                  label="Number of Locations/Clients"
                  type="number"
                  value={formData.size_clients}
                  onChange={(e) => setFormData({ ...formData, size_clients: e.target.value })}
                  placeholder="10"
                />
                <Input
                  label="Current CRM (optional)"
                  type="text"
                  value={formData.current_crm}
                  onChange={(e) => setFormData({ ...formData, current_crm: e.target.value })}
                  placeholder="Salesforce, HubSpot, etc."
                />
                <Button
                  type="submit"
                  className="w-full"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Sending...' : 'Get Instant Access'}
                </Button>
                <p className="text-sm text-slate-500 text-center">
                  You'll receive a personal replay link via email instantly
                </p>
              </form>
            </div>

            <div className="space-y-6">
              <div className="bg-white rounded-xl shadow-lg p-6">
                <h3 className="text-2xl font-bold mb-4">What You Get</h3>
                <ul className="space-y-3">
                  {[
                    'Custom Domain & Branding',
                    'Private Admin Dashboard',
                    'Full 40+ Bot Ecosystem',
                    'Multi-Location Management',
                    'Enterprise Reporting',
                    'Priority Infrastructure',
                    'Dedicated Onboarding',
                  ].map((item, i) => (
                    <li key={i} className="flex gap-3">
                      <CheckCircle2 className="w-6 h-6 text-green-600 flex-shrink-0" />
                      <span className="text-slate-700">{item}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div className="bg-blue-600 text-white rounded-xl shadow-lg p-6">
                <h3 className="text-2xl font-bold mb-4">Perfect For</h3>
                <ul className="space-y-2">
                  {[
                    'Marketing Agencies',
                    'Multi-Location Businesses',
                    'Regional Operators',
                    'Service Networks',
                    'Healthcare Groups',
                    'Real Estate Brokerages',
                  ].map((item, i) => (
                    <li key={i} className="flex gap-2">
                      <span>•</span>
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-xl p-8 mb-12">
            <h2 className="text-3xl font-bold mb-8 text-center">Enterprise Tiers</h2>
            <div className="grid md:grid-cols-3 gap-6">
              <div className="border-2 border-slate-200 rounded-lg p-6">
                <h3 className="text-xl font-bold mb-2">Regional Operator</h3>
                <p className="text-slate-600 mb-4">Perfect for growing operators</p>
                <div className="mb-6">
                  <div className="text-3xl font-bold mb-1">$2,500</div>
                  <div className="text-sm text-slate-600">Setup Fee</div>
                  <div className="text-2xl font-bold mt-3">$499<span className="text-base font-normal">/mo</span></div>
                  <div className="text-sm text-slate-600">+ $49 per location</div>
                </div>
                <ul className="space-y-2 text-sm">
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Full white-label branding</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Up to 50 locations</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Standard support</span>
                  </li>
                </ul>
              </div>

              <div className="border-4 border-blue-600 rounded-lg p-6 relative">
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white px-4 py-1 rounded-full text-sm font-bold">
                  MOST POPULAR
                </div>
                <h3 className="text-xl font-bold mb-2">Agency Network</h3>
                <p className="text-slate-600 mb-4">Scale your agency clients</p>
                <div className="mb-6">
                  <div className="text-3xl font-bold mb-1">$5,000</div>
                  <div className="text-sm text-slate-600">Setup Fee</div>
                  <div className="text-2xl font-bold mt-3">$997<span className="text-base font-normal">/mo</span></div>
                  <div className="text-sm text-slate-600">+ $25 per client</div>
                </div>
                <ul className="space-y-2 text-sm">
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Everything in Regional</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Unlimited clients</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Priority support</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Dedicated account manager</span>
                  </li>
                </ul>
              </div>

              <div className="border-2 border-slate-200 rounded-lg p-6">
                <h3 className="text-xl font-bold mb-2">Enterprise Custom</h3>
                <p className="text-slate-600 mb-4">Tailored for your needs</p>
                <div className="mb-6">
                  <div className="text-3xl font-bold mb-1">$10,000+</div>
                  <div className="text-sm text-slate-600">Setup Fee</div>
                  <div className="text-2xl font-bold mt-3">$1,500+<span className="text-base font-normal">/mo</span></div>
                  <div className="text-sm text-slate-600">Custom pricing</div>
                </div>
                <ul className="space-y-2 text-sm">
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Everything in Agency</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Custom bot development</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>Dedicated infrastructure</span>
                  </li>
                  <li className="flex gap-2">
                    <CheckCircle2 className="w-4 h-4 text-green-600 flex-shrink-0 mt-0.5" />
                    <span>White-glove everything</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div className="grid md:grid-cols-3 gap-8 mb-12">
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Zap className="w-8 h-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-bold mb-2">Proven System</h3>
              <p className="text-slate-600">
                Battle-tested AI infrastructure that converts
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Shield className="w-8 h-8 text-green-600" />
              </div>
              <h3 className="text-xl font-bold mb-2">Full Compliance</h3>
              <p className="text-slate-600">
                US-based, SOC-ready, data isolation
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <TrendingUp className="w-8 h-8 text-purple-600" />
              </div>
              <h3 className="text-xl font-bold mb-2">Scale Fast</h3>
              <p className="text-slate-600">
                Launch in 30 days, grow without limits
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
