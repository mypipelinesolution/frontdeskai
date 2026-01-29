import React from 'react';

const Navigation: React.FC = () => {
  const scrollToSection = (sectionId: string) => {
    const section = document.getElementById(sectionId);
    if (section) {
      section.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const scrollToDemo = () => {
    const demoForm = document.querySelector('form');
    if (demoForm) {
      demoForm.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  };

  return (
    <nav className="bg-transparent">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
        <div className="flex items-center justify-between h-24">
          <div className="flex items-center gap-3">
            <img src="/logo.png" alt="FrontDesk AI Pro" className="h-24 w-auto brightness-90 saturate-75" />
            <div className="flex flex-col">
              <h1 className="text-3xl font-bold text-white">FrontDesk AI Pro</h1>
              <p className="text-sm text-green-400 font-medium">Powered by Local-Link</p>
            </div>
          </div>

          <div className="flex items-center gap-8">
            <button
              onClick={() => scrollToSection('features')}
              className="text-gray-300 hover:text-white transition-colors text-base font-medium"
            >
              Features
            </button>
            <button
              onClick={() => scrollToSection('pricing')}
              className="text-gray-300 hover:text-white transition-colors text-base font-medium"
            >
              Pricing
            </button>
            <button
              onClick={scrollToDemo}
              className="text-gray-300 hover:text-white transition-colors text-base font-medium"
            >
              DFY
            </button>
            <button
              onClick={scrollToDemo}
              className="bg-gradient-to-r from-purple-500 via-purple-400 to-cyan-400 hover:from-purple-400 hover:via-purple-300 hover:to-cyan-300 text-white px-6 py-2.5 rounded-lg font-semibold transition-all shadow-lg text-base"
            >
              Get Started
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navigation;
