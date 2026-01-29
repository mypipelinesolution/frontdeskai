import React from 'react';
import { useNavigate } from 'react-router-dom';
import { PricingCard } from '../components/PricingCard';
import { STRIPE_PRODUCTS } from '../stripe-config';

export default function Pricing() {
  const navigate = useNavigate();

  const handleCheckout = async (priceId: string) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          priceId,
          successUrl: `${window.location.origin}/success`,
          cancelUrl: `${window.location.origin}/pricing`,
        }),
      });

      const { url } = await response.json();
      
      if (url) {
        window.location.href = url;
      }
    } catch (error) {
      console.error('Checkout error:', error);
    }
  };

  // Separate main plans from add-ons
  const mainPlans = STRIPE_PRODUCTS.filter(product => 
    product.name.includes('FrontDesk AI Pro')
  );
  
  const addOns = STRIPE_PRODUCTS.filter(product => 
    !product.name.includes('FrontDesk AI Pro')
  );

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Choose Your AI Front Desk Plan
          </h1>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Transform your business with 24/7 AI-powered customer service, lead capture, and automation
          </p>
        </div>

        {/* Main Plans */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mb-16">
          {mainPlans.map((product, index) => (
            <PricingCard
              key={product.id}
              product={product}
              featured={index === 2} // Accelerator plan
              onSelect={handleCheckout}
            />
          ))}
        </div>

        {/* Add-ons Section */}
        <div className="border-t border-gray-200 pt-16">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Premium Add-Ons
            </h2>
            <p className="text-lg text-gray-600">
              Supercharge your AI system with specialized bots and advanced features
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {addOns.map((product) => (
              <PricingCard
                key={product.id}
                product={product}
                onSelect={handleCheckout}
              />
            ))}
          </div>
        </div>

        {/* Features Section */}
        <div className="mt-16 bg-white rounded-2xl p-8 shadow-lg">
          <h3 className="text-2xl font-bold text-gray-900 mb-6 text-center">
            All Plans Include
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">🤖</span>
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">AI-Powered</h4>
              <p className="text-gray-600">Advanced AI trained on your business</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">⚡</span>
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">24/7 Availability</h4>
              <p className="text-gray-600">Never miss a lead or customer inquiry</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl">📈</span>
              </div>
              <h4 className="font-semibold text-gray-900 mb-2">Growth Focused</h4>
              <p className="text-gray-600">Designed to increase conversions and revenue</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}