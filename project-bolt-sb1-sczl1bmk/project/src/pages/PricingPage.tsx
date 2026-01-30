import { PricingSection } from '../components/PricingSection';
import { ChatWidget } from '../components/ChatWidget';

export function PricingPage() {
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

      <PricingSection />
      <ChatWidget />
    </div>
  );
}