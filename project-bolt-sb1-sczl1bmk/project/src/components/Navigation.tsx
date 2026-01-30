import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

const Navigation: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();

  const scrollToSection = (sectionId: string) => {
    const section = document.getElementById(sectionId);
    if (section) {
      section.scrollIntoView({ behavior: 'smooth' });
    } else {
      // If section doesn't exist, navigate to home first
      navigate('/', { state: { scrollTo: sectionId } });
    }
  };

  const scrollToDemo = () => {
    const demoForm = document.querySelector('form');
    if (demoForm) {
      demoForm.scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
      navigate('/', { state: { scrollTo: 'demo' } });
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/');
  };

  return (
    <nav className="bg-transparent">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6">
        <div className="flex items-center justify-between h-24">
          <div className="flex items-center gap-3 cursor-pointer" onClick={() => navigate('/')}>
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
            
            {user ? (
              <div className="flex items-center gap-6">
                <button
                  onClick={() => navigate('/dashboard')}
                  className="text-gray-300 hover:text-white transition-colors text-base font-medium"
                >
                  Dashboard
                </button>
                <button
                  onClick={() => navigate('/pricing')}
                  className="text-gray-300 hover:text-white transition-colors text-base font-medium"
                >
                  Upgrade
                </button>
                <div className="flex items-center gap-3 px-4 py-2 bg-white/10 rounded-lg">
                  <div className="w-8 h-8 bg-gradient-to-r from-purple-500 to-cyan-400 rounded-full flex items-center justify-center">
                    <span className="text-white text-sm font-bold">
                      {user.email?.charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <button
                    onClick={handleLogout}
                    className="text-gray-300 hover:text-white transition-colors text-sm font-medium"
                  >
                    Logout
                  </button>
                </div>
              </div>
            ) : (
              <div className="flex items-center gap-4">
                <button
                  onClick={() => navigate('/login')}
                  className="text-gray-300 hover:text-white transition-colors text-base font-medium"
                >
                  Login
                </button>
                <button
                  onClick={() => navigate('/signup')}
                  className="bg-gradient-to-r from-purple-500 via-purple-400 to-cyan-400 hover:from-purple-400 hover:via-purple-300 hover:to-cyan-300 text-white px-6 py-2.5 rounded-lg font-semibold transition-all shadow-lg text-base"
                >
                  Get Started
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navigation;
