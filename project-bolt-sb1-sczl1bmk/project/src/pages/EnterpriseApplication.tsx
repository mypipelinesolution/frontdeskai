import { useState, useEffect } from 'react';
import { CheckCircle2 } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { supabase } from '../lib/supabase';

export default function EnterpriseApplication() {
  const [formData, setFormData] = useState({
    company_name: '',
    contact_name: '',
    contact_email: '',
    contact_phone: '',
    num_locations: '',
    num_clients: '',
    current_systems: '',
    monthly_ad_spend: '',
    growth_goals: '',
    tier_interest: 'agency',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [partnerSlug, setPartnerSlug] = useState<string | null>(null);

  useEffect(() => {
    const stored = localStorage.getItem('enterprise_partner_slug');
    if (stored) setPartnerSlug(stored);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const { data: lead } = await supabase
        .from('enterprise_leads')
        .select('id')
        .eq('email', formData.contact_email)
        .single();

      const { error } = await supabase
        .from('enterprise_applications')
        .insert({
          lead_id: lead?.id,
          partner_slug: partnerSlug,
          company_name: formData.company_name,
          contact_name: formData.contact_name,
          contact_email: formData.contact_email,
          contact_phone: formData.contact_phone,
          num_locations: formData.num_locations ? parseInt(formData.num_locations) : null,
          num_clients: formData.num_clients ? parseInt(formData.num_clients) : null,
          current_systems: formData.current_systems,
          monthly_ad_spend: formData.monthly_ad_spend,
          growth_goals: formData.growth_goals,
          tier_interest: formData.tier_interest,
          status: 'submitted',
        });

      if (error) throw error;

      if (lead) {
        await supabase
          .from('enterprise_leads')
          .update({ status: 'applied' })
          .eq('id', lead.id);
      }

      setSubmitted(true);
    } catch (error) {
      console.error('Error submitting application:', error);
      alert('Failed to submit application. Please try again.');
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
            <h1 className="text-4xl font-bold mb-4">Application Submitted!</h1>
            <p className="text-xl text-slate-600 mb-8">
              Thank you for your interest in FrontDesk AI Pro Enterprise.
            </p>
            <div className="bg-white rounded-lg shadow-lg p-8 text-left">
              <h2 className="text-2xl font-bold mb-4">What Happens Next:</h2>
              <ul className="space-y-4">
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Our team will review your application within 24 hours</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>You'll receive an email to schedule your strategy call</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>We'll discuss your specific needs and customize a proposal</span>
                </li>
                <li className="flex gap-3">
                  <CheckCircle2 className="w-6 h-6 text-blue-600 flex-shrink-0" />
                  <span>Qualified applicants can launch within 30 days</span>
                </li>
              </ul>
            </div>
            <div className="mt-8">
              <p className="text-slate-600">
                Questions? Email us at <a href="mailto:enterprise@frontdeskaipro.com" className="text-blue-600 hover:underline">enterprise@frontdeskaipro.com</a>
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-50">
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold mb-4">
              Enterprise License Application
            </h1>
            <p className="text-xl text-slate-600">
              Tell us about your business and we'll customize a solution for you
            </p>
          </div>

          <div className="bg-white rounded-xl shadow-xl p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <h2 className="text-2xl font-bold mb-4">Company Information</h2>
                <div className="space-y-4">
                  <Input
                    label="Company Name"
                    type="text"
                    required
                    value={formData.company_name}
                    onChange={(e) => setFormData({ ...formData, company_name: e.target.value })}
                    placeholder="ABC Marketing Agency"
                  />
                  <Input
                    label="Your Name"
                    type="text"
                    required
                    value={formData.contact_name}
                    onChange={(e) => setFormData({ ...formData, contact_name: e.target.value })}
                    placeholder="John Smith"
                  />
                  <Input
                    label="Email"
                    type="email"
                    required
                    value={formData.contact_email}
                    onChange={(e) => setFormData({ ...formData, contact_email: e.target.value })}
                    placeholder="john@company.com"
                  />
                  <Input
                    label="Phone"
                    type="tel"
                    required
                    value={formData.contact_phone}
                    onChange={(e) => setFormData({ ...formData, contact_phone: e.target.value })}
                    placeholder="(555) 123-4567"
                  />
                </div>
              </div>

              <div className="border-t pt-6">
                <h2 className="text-2xl font-bold mb-4">Business Details</h2>
                <div className="space-y-4">
                  <Input
                    label="Number of Locations (if applicable)"
                    type="number"
                    value={formData.num_locations}
                    onChange={(e) => setFormData({ ...formData, num_locations: e.target.value })}
                    placeholder="5"
                  />
                  <Input
                    label="Number of Clients You Manage"
                    type="number"
                    required
                    value={formData.num_clients}
                    onChange={(e) => setFormData({ ...formData, num_clients: e.target.value })}
                    placeholder="25"
                  />
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      Current Systems/Tools
                    </label>
                    <textarea
                      className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      rows={3}
                      required
                      value={formData.current_systems}
                      onChange={(e) => setFormData({ ...formData, current_systems: e.target.value })}
                      placeholder="e.g., Salesforce, HubSpot, HighLevel, etc."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      Monthly Ad Spend Range
                    </label>
                    <select
                      className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      required
                      value={formData.monthly_ad_spend}
                      onChange={(e) => setFormData({ ...formData, monthly_ad_spend: e.target.value })}
                    >
                      <option value="">Select range...</option>
                      <option value="0-5k">$0 - $5,000</option>
                      <option value="5k-10k">$5,000 - $10,000</option>
                      <option value="10k-25k">$10,000 - $25,000</option>
                      <option value="25k-50k">$25,000 - $50,000</option>
                      <option value="50k+">$50,000+</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      Growth Goals (Next 12 Months)
                    </label>
                    <textarea
                      className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                      rows={4}
                      required
                      value={formData.growth_goals}
                      onChange={(e) => setFormData({ ...formData, growth_goals: e.target.value })}
                      placeholder="What are your main business goals? What problems are you trying to solve?"
                    />
                  </div>
                </div>
              </div>

              <div className="border-t pt-6">
                <h2 className="text-2xl font-bold mb-4">Tier Selection</h2>
                <div className="space-y-3">
                  <label className="flex items-start gap-3 p-4 border-2 border-slate-200 rounded-lg cursor-pointer hover:border-blue-300 transition-colors">
                    <input
                      type="radio"
                      name="tier"
                      value="regional"
                      checked={formData.tier_interest === 'regional'}
                      onChange={(e) => setFormData({ ...formData, tier_interest: e.target.value })}
                      className="mt-1"
                    />
                    <div>
                      <div className="font-bold">Regional Operator</div>
                      <div className="text-sm text-slate-600">$2,500 setup + $499/mo + $49/location</div>
                    </div>
                  </label>
                  <label className="flex items-start gap-3 p-4 border-2 border-blue-300 rounded-lg cursor-pointer hover:border-blue-400 transition-colors bg-blue-50">
                    <input
                      type="radio"
                      name="tier"
                      value="agency"
                      checked={formData.tier_interest === 'agency'}
                      onChange={(e) => setFormData({ ...formData, tier_interest: e.target.value })}
                      className="mt-1"
                    />
                    <div>
                      <div className="font-bold flex items-center gap-2">
                        Agency Network
                        <span className="text-xs bg-blue-600 text-white px-2 py-0.5 rounded">RECOMMENDED</span>
                      </div>
                      <div className="text-sm text-slate-600">$5,000 setup + $997/mo + $25/client</div>
                    </div>
                  </label>
                  <label className="flex items-start gap-3 p-4 border-2 border-slate-200 rounded-lg cursor-pointer hover:border-blue-300 transition-colors">
                    <input
                      type="radio"
                      name="tier"
                      value="custom"
                      checked={formData.tier_interest === 'custom'}
                      onChange={(e) => setFormData({ ...formData, tier_interest: e.target.value })}
                      className="mt-1"
                    />
                    <div>
                      <div className="font-bold">Enterprise Custom</div>
                      <div className="text-sm text-slate-600">$10,000+ setup + $1,500+/mo (Custom pricing)</div>
                    </div>
                  </label>
                </div>
              </div>

              <div className="pt-6">
                <Button
                  type="submit"
                  className="w-full"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Submitting Application...' : 'Submit Application'}
                </Button>
                <p className="text-sm text-slate-500 text-center mt-3">
                  We'll review your application and contact you within 24 hours
                </p>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
