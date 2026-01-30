import React from 'react';
import Navigation from '../components/Navigation';
import HeroSection from '../components/HeroSection';
import PricingSection from '../components/PricingSection';
import { ChatWidget } from '../components/ChatWidget';
import { useWorkspace } from '../hooks/useWorkspace';

const HomePage: React.FC = () => {
  const { workspace } = useWorkspace();

  return (
    <div className="min-h-screen overflow-x-hidden cosmic-bg">
      <Navigation />
      <HeroSection />
      <PricingSection />
      <ChatWidget workspaceId={workspace?.id} />
    </div>
  );
};

export default HomePage;
