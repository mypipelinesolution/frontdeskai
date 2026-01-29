import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import DemoChat from './DemoChat';

const HeroSection: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitMessage, setSubmitMessage] = useState('');
  const [showDemoChat, setShowDemoChat] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitMessage('');

    try {
      const { error } = await supabase
        .from('demo_requests')
        .insert([
          {
            name: formData.name,
            email: formData.email,
            phone: formData.phone
          }
        ]);

      if (error) throw error;

      setShowDemoChat(true);
    } catch (error) {
      console.error('Error submitting demo request:', error);
      setSubmitMessage('Something went wrong. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-16 pb-16 relative z-10">
        <div>
          <div>
            <h1 className="text-5xl lg:text-6xl font-bold mb-8 leading-tight">
              <span className="text-white">Your 24/7 FrontDesk AI Pro Team </span>
              <span className="text-green-400">For Local Businesses</span>
            </h1>

            <p className="text-xl text-gray-300 mb-12">
              Capture Leads, Book Appointments & Never Miss a customer — All on Autopilot
            </p>

            {/* Demo Form and AI Bot Team Image */}
            <div className="grid lg:grid-cols-2 gap-8 items-start">
              {/* Demo Form */}
              <div className="bg-black/40 backdrop-blur-md rounded-2xl p-8 border border-purple-500/20">
                <h3 className="text-2xl font-bold text-white mb-6">Get Your Free Demo</h3>

                <form onSubmit={handleSubmit} className="space-y-4">
                  <input
                    type="text"
                    placeholder="Name"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    required
                    className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-purple-400 transition-colors"
                  />

                  <input
                    type="email"
                    placeholder="Email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    required
                    className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-purple-400 transition-colors"
                  />

                  <input
                    type="tel"
                    placeholder="Phone"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    required
                    className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:border-purple-400 transition-colors"
                  />

                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="w-full py-4 bg-gradient-to-r from-green-500 via-emerald-500 to-purple-500 hover:from-green-400 hover:via-emerald-400 hover:to-purple-400 text-white font-semibold rounded-lg transition-all shadow-lg disabled:opacity-50"
                  >
                    {isSubmitting ? 'Submitting...' : 'Request Demo'}
                  </button>
                </form>

                {submitMessage && (
                  <p className={`mt-4 text-sm text-center ${submitMessage.includes('Thanks') ? 'text-green-400' : 'text-red-400'}`}>
                    {submitMessage}
                  </p>
                )}

                <p className="text-gray-400 text-sm mt-4 text-center">
                  No contracts. Cancel anytime.
                </p>
              </div>

              {/* AI Bot Team Image */}
              <div className="flex flex-col gap-4">
                <div className="rounded-2xl overflow-hidden">
                  <img
                    src="/ai_bot_team.png"
                    alt="AI Bot Team"
                    className="w-full h-full object-cover"
                  />
                </div>
                <h2 className="text-2xl font-bold text-white text-center">
                  Your Personal AI Sales + Support Team
                </h2>
                <p className="text-green-400 text-center font-semibold">
                  38 AI Bots Working 24/7 For Your Business
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {showDemoChat && (
        <DemoChat
          userName={formData.name}
          userEmail={formData.email}
          onClose={() => {
            setShowDemoChat(false);
            setFormData({ name: '', email: '', phone: '' });
          }}
        />
      )}
    </div>
  );
};

export default HeroSection;
