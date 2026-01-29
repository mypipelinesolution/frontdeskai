import React from 'react';
import Navigation from '../components/Navigation';
import HeroSection from '../components/HeroSection';
import PricingSection from '../components/PricingSection';

const HomePage: React.FC = () => {
  return (
    <div className="min-h-screen overflow-x-hidden cosmic-bg">
      <Navigation />
      <HeroSection />
      <PricingSection />
    </div>
  );
};

export default HomePage;
