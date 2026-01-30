import React from 'react';
import { useNavigate } from 'react-router-dom';
import { PricingSection } from '../components/PricingSection';
import { supabase } from '../lib/supabase';

export function PricingPage() {
  const navigate = useNavigate();

  const handleSelectPlan = async (priceId: string) => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      
      if (!user) {
        navigate('/auth');
        return;
      }

      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          priceId,
          userId: user.id,
          successUrl: `${window.location.origin}/success`,
          cancelUrl: `${window.location.origin}/pricing`,
        }),
      });

      const { url } = await response.json();
      
      if (url) {
        window.location.href = url;
      }
    } catch (error) {
      console.error('Error creating checkout session:', error);
    }
  };

  return (
    <div className="min-h-screen cosmic-bg">
      <div className="py-16">
        <div className="max-w-4xl mx-auto text-center px-4">
          <h1 className="text-4xl md:text-5xl font-bold text-white mb-6">
            Transform Your Business with AI
          </h1>
          <p className="text-xl text-purple-200 mb-8">
            Never miss a lead again. Our AI handles calls, chats, and bookings 24/7.
          </p>
        </div>
      </div>

      <PricingSection onSelectPlan={handleSelectPlan} />
    </div>
  );
}