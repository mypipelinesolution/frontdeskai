import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Calendar, Clock, Video, Zap } from 'lucide-react';
import { supabase } from '../lib/supabase';

export function WebinarBooking() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    phone: '',
    webinar_type: 'product_demo',
    scheduled_for: '',
    duration_minutes: 30,
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: { user } } = await supabase.auth.getUser();

      const bookingData = {
        ...formData,
        user_id: user?.id || null,
        status: 'pending',
        scheduled_for: formData.scheduled_for || new Date().toISOString(),
      };

      const { data, error } = await supabase
        .from('webinar_bookings')
        .insert([bookingData])
        .select()
        .single();

      if (error) throw error;

      navigate(`/webinar/${data.id}`);
    } catch (error) {
      console.error('Error booking webinar:', error);
      alert('Failed to book webinar. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleStartNow = async () => {
    const now = new Date().toISOString();
    setFormData({ ...formData, scheduled_for: now });

    setTimeout(() => {
      const form = document.querySelector('form');
      if (form) {
        form.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true }));
      }
    }, 100);
  };

  const getMinDateTime = () => {
    const now = new Date();
    now.setMinutes(now.getMinutes() + 5);
    return now.toISOString().slice(0, 16);
  };

  return (
    <div className="min-h-screen cosmic-bg">
      <div className="max-w-4xl mx-auto px-4 py-16">
        <div className="text-center mb-12">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-purple-600 to-pink-600 rounded-full mb-6">
            <Video className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Book Your Private AI Demo
          </h1>
          <p className="text-xl text-purple-200 max-w-2xl mx-auto">
            See FrontDesk AI Pro in action. Our AI webinar host will present a personalized demo
            and answer all your questions in real-time.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 mb-12">
          <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30">
            <div className="flex items-start gap-4 mb-6">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-3">
                <Zap className="w-6 h-6 text-cyan-400" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-white mb-2">Instant Demo</h3>
                <p className="text-purple-200 text-sm">
                  Start watching immediately. No waiting, no scheduling hassle.
                </p>
              </div>
            </div>
            <button
              onClick={handleStartNow}
              disabled={!formData.full_name || !formData.email}
              className={`w-full py-4 rounded-xl font-bold text-lg transition-all duration-200 bg-gradient-to-r from-lime-500 via-green-500 to-emerald-600 hover:from-lime-400 hover:via-green-400 hover:to-emerald-500 text-white shadow-lg shadow-lime-500/30 ${
                (!formData.full_name || !formData.email) ? 'opacity-50 cursor-not-allowed' : ''
              }`}
            >
              Start Demo Now
            </button>
            <p className="text-purple-300 text-xs text-center mt-3">
              Fill in your details below first
            </p>
          </div>

          <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30">
            <div className="flex items-start gap-4 mb-6">
              <div className="bg-gradient-to-br from-cyan-500/20 to-purple-500/20 rounded-xl p-3">
                <Calendar className="w-6 h-6 text-cyan-400" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-white mb-2">Schedule for Later</h3>
                <p className="text-purple-200 text-sm">
                  Pick a time that works best for you. We're available 24/7.
                </p>
              </div>
            </div>
            <div className="space-y-4">
              <input
                type="datetime-local"
                min={getMinDateTime()}
                value={formData.scheduled_for}
                onChange={(e) => setFormData({ ...formData, scheduled_for: e.target.value })}
                className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white placeholder-purple-400 focus:outline-none focus:border-cyan-400 transition-colors"
              />
              <button
                type="submit"
                form="booking-form"
                disabled={loading || !formData.full_name || !formData.email || !formData.scheduled_for}
                className={`w-full py-4 rounded-xl font-bold text-lg transition-all duration-200 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 text-white shadow-lg ${
                  (loading || !formData.full_name || !formData.email || !formData.scheduled_for) ? 'opacity-50 cursor-not-allowed' : ''
                }`}
              >
                {loading ? 'Booking...' : 'Schedule Webinar'}
              </button>
            </div>
          </div>
        </div>

        <form id="booking-form" onSubmit={handleSubmit} className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-8 border border-purple-500/30">
          <h2 className="text-2xl font-bold text-white mb-6">Your Information</h2>

          <div className="grid md:grid-cols-2 gap-6 mb-6">
            <div>
              <label className="block text-purple-200 text-sm font-medium mb-2">
                Full Name *
              </label>
              <input
                type="text"
                required
                value={formData.full_name}
                onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white placeholder-purple-400 focus:outline-none focus:border-cyan-400 transition-colors"
                placeholder="John Doe"
              />
            </div>

            <div>
              <label className="block text-purple-200 text-sm font-medium mb-2">
                Email Address *
              </label>
              <input
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white placeholder-purple-400 focus:outline-none focus:border-cyan-400 transition-colors"
                placeholder="john@example.com"
              />
            </div>
          </div>

          <div className="mb-6">
            <label className="block text-purple-200 text-sm font-medium mb-2">
              Phone Number (Optional)
            </label>
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white placeholder-purple-400 focus:outline-none focus:border-cyan-400 transition-colors"
              placeholder="+1 (555) 123-4567"
            />
          </div>

          <div className="mb-6">
            <label className="block text-purple-200 text-sm font-medium mb-2">
              Webinar Type
            </label>
            <select
              value={formData.webinar_type}
              onChange={(e) => setFormData({ ...formData, webinar_type: e.target.value })}
              className="w-full px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white focus:outline-none focus:border-cyan-400 transition-colors"
            >
              <option value="product_demo">Quick Product Demo (15 min)</option>
              <option value="full_presentation">Full Presentation (30 min)</option>
              <option value="custom">Custom Consultation (45 min)</option>
            </select>
          </div>

          <div className="bg-purple-900/30 rounded-xl p-6 border border-purple-500/20">
            <div className="flex items-start gap-3">
              <Clock className="w-5 h-5 text-cyan-400 mt-1 flex-shrink-0" />
              <div>
                <h3 className="text-white font-semibold mb-2">What to Expect</h3>
                <ul className="space-y-2 text-purple-200 text-sm">
                  <li>• Personalized demo of FrontDesk AI Pro features</li>
                  <li>• Live Q&A with our AI webinar host</li>
                  <li>• See real examples of automation in action</li>
                  <li>• Get answers to pricing and setup questions</li>
                  <li>• Special webinar-exclusive offers available</li>
                </ul>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
