import { useState } from 'react';
import { supabase, Workspace } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';
import { Building2, Phone, Globe, Check } from 'lucide-react';

export function Onboarding({ onComplete }: { onComplete: (workspace: Workspace) => void }) {
  const { user } = useAuth();
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    business_name: '',
    phone: '',
    email: user?.email || '',
    website: '',
    ai_context: '',
    services: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setLoading(true);

    try {
      const aiContext = formData.ai_context ||
        `${formData.business_name} is a professional service business. We specialize in ${formData.services || 'providing quality services to our customers'}. We are committed to excellent customer service and responding to all inquiries promptly.`;

      const { data: workspace, error } = await supabase
        .from('workspaces')
        .insert({
          owner_id: user.id,
          business_name: formData.business_name,
          phone: formData.phone,
          email: formData.email,
          website: formData.website,
          ai_context: aiContext,
          subscription_tier: 'core',
          subscription_status: 'active',
          onboarding_completed: true,
        })
        .select()
        .single();

      if (error) throw error;

      const defaultAutomations = [
        {
          workspace_id: workspace.id,
          name: 'Instant Reply Bot',
          type: 'instant_reply',
          trigger: 'new_lead',
          template: 'Thanks for reaching out! We received your message and will get back to you within the hour. - {business_name}',
          enabled: true,
        },
        {
          workspace_id: workspace.id,
          name: 'Missed Call Text-Back',
          type: 'missed_call',
          trigger: 'missed_call',
          template: 'Hi! We missed your call. How can we help you today? Reply here or call us back at {phone}. - {business_name}',
          enabled: true,
        },
        {
          workspace_id: workspace.id,
          name: 'Review Request',
          type: 'review',
          trigger: 'appointment_complete',
          template: 'Thanks for choosing {business_name}! We would love to hear about your experience. Leave us a review: {review_link}',
          enabled: true,
        },
      ];

      await supabase.from('automations').insert(defaultAutomations);

      onComplete(workspace);
    } catch (error) {
      console.error('Onboarding error:', error);
      alert('Error creating workspace. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const steps = [
    { number: 1, title: 'Business Info', icon: Building2 },
    { number: 2, title: 'Contact Details', icon: Phone },
    { number: 3, title: 'Review & Launch', icon: Check },
  ];

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="max-w-2xl w-full">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-slate-900 mb-2">Welcome to FrontDesk AI Pro!</h1>
            <p className="text-slate-600">Let's set up your 24/7 AI front desk</p>
          </div>

          <div className="flex items-center justify-center mb-8">
            {steps.map((s, i) => (
              <div key={s.number} className="flex items-center">
                <div
                  className={`flex items-center justify-center w-12 h-12 rounded-full ${
                    step >= s.number ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-400'
                  }`}
                >
                  {step > s.number ? (
                    <Check className="w-6 h-6" />
                  ) : (
                    <s.icon className="w-6 h-6" />
                  )}
                </div>
                {i < steps.length - 1 && (
                  <div
                    className={`w-16 h-1 mx-2 ${
                      step > s.number ? 'bg-blue-600' : 'bg-slate-200'
                    }`}
                  />
                )}
              </div>
            ))}
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {step === 1 && (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Business Name *
                  </label>
                  <input
                    type="text"
                    value={formData.business_name}
                    onChange={(e) => setFormData({ ...formData, business_name: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., Joe's Auto Repair"
                    required
                  />
                </div>
                <button
                  type="button"
                  onClick={() => setStep(2)}
                  disabled={!formData.business_name}
                  className="w-full px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition disabled:opacity-50"
                >
                  Continue
                </button>
              </div>
            )}

            {step === 2 && (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Business Phone *
                  </label>
                  <input
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="(555) 123-4567"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Business Email
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="contact@business.com"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Website (optional)
                  </label>
                  <input
                    type="url"
                    value={formData.website}
                    onChange={(e) => setFormData({ ...formData, website: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="https://yourbusiness.com"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    What services do you offer?
                  </label>
                  <input
                    type="text"
                    value={formData.services}
                    onChange={(e) => setFormData({ ...formData, services: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    placeholder="e.g., HVAC repair, plumbing, roofing"
                  />
                  <p className="text-xs text-slate-500 mt-1">This helps train your AI to answer questions accurately</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Business Description (optional)
                  </label>
                  <textarea
                    value={formData.ai_context}
                    onChange={(e) => setFormData({ ...formData, ai_context: e.target.value })}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                    rows={3}
                    placeholder="Tell us about your business, pricing, service areas, etc."
                  />
                  <p className="text-xs text-slate-500 mt-1">The more details you provide, the better your AI will respond</p>
                </div>
                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={() => setStep(1)}
                    className="flex-1 px-6 py-3 bg-slate-200 hover:bg-slate-300 text-slate-700 rounded-lg font-semibold transition"
                  >
                    Back
                  </button>
                  <button
                    type="button"
                    onClick={() => setStep(3)}
                    disabled={!formData.phone}
                    className="flex-1 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition disabled:opacity-50"
                  >
                    Continue
                  </button>
                </div>
              </div>
            )}

            {step === 3 && (
              <div className="space-y-4">
                <div className="bg-slate-50 rounded-lg p-6 space-y-3">
                  <h3 className="font-semibold text-slate-900 mb-4">Review Your Information</h3>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Business Name:</span>
                    <span className="font-medium text-slate-900">{formData.business_name}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-600">Phone:</span>
                    <span className="font-medium text-slate-900">{formData.phone}</span>
                  </div>
                  {formData.email && (
                    <div className="flex justify-between">
                      <span className="text-slate-600">Email:</span>
                      <span className="font-medium text-slate-900">{formData.email}</span>
                    </div>
                  )}
                  {formData.website && (
                    <div className="flex justify-between">
                      <span className="text-slate-600">Website:</span>
                      <span className="font-medium text-slate-900">{formData.website}</span>
                    </div>
                  )}
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <h4 className="font-semibold text-blue-900 mb-2">Your AI Bots Will Be Activated:</h4>
                  <ul className="space-y-2 text-sm text-blue-800">
                    <li className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-blue-600" />
                      Instant Reply Bot (60-second responses)
                    </li>
                    <li className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-blue-600" />
                      Missed Call Text-Back Bot
                    </li>
                    <li className="flex items-center gap-2">
                      <Check className="w-4 h-4 text-blue-600" />
                      Review Request Bot
                    </li>
                  </ul>
                </div>

                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={() => setStep(2)}
                    className="flex-1 px-6 py-3 bg-slate-200 hover:bg-slate-300 text-slate-700 rounded-lg font-semibold transition"
                  >
                    Back
                  </button>
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg font-semibold transition disabled:opacity-50"
                  >
                    {loading ? 'Launching...' : 'Launch My AI Front Desk'}
                  </button>
                </div>
              </div>
            )}
          </form>
        </div>
      </div>
    </div>
  );
}
