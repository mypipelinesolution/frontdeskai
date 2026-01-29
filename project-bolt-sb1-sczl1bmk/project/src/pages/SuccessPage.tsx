import React, { useEffect, useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { CheckCircle, ArrowRight, Crown, Zap } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { getProductByPriceId } from '../stripe-config';
import { useAuth } from '../contexts/AuthContext';
import OnboardingChat from '../components/OnboardingChat';

const SuccessPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const [orderDetails, setOrderDetails] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [workspace, setWorkspace] = useState<any>(null);
  const [showOnboarding, setShowOnboarding] = useState(false);
  const { user } = useAuth();

  const sessionId = searchParams.get('session_id');

  useEffect(() => {
    if (sessionId) {
      fetchOrderDetails();
    } else {
      setLoading(false);
    }
  }, [sessionId]);

  useEffect(() => {
    if (user) {
      checkWorkspace();
    }
  }, [user]);

  const fetchOrderDetails = async () => {
    try {
      const { data, error } = await supabase
        .from('stripe_user_orders')
        .select('*')
        .eq('checkout_session_id', sessionId)
        .single();

      if (error) {
        console.error('Error fetching order:', error);
        return;
      }

      setOrderDetails(data);
    } catch (error) {
      console.error('Error fetching order details:', error);
    } finally {
      setLoading(false);
    }
  };

  const checkWorkspace = async () => {
    if (!user) return;

    try {
      const { data } = await supabase
        .from('workspaces')
        .select('*')
        .eq('owner_id', user.id)
        .maybeSingle();

      if (data) {
        setWorkspace(data);
        if (!data.ai_training_complete) {
          setShowOnboarding(true);
        }
      } else {
        const product = orderDetails?.price_id ? getProductByPriceId(orderDetails.price_id) : null;
        const tier = product?.name.includes('Starter') ? 'starter' :
                     product?.name.includes('Core') ? 'core' :
                     product?.name.includes('Accelerator') ? 'pro' : 'core';

        const { data: newWorkspace } = await supabase
          .from('workspaces')
          .insert({
            owner_id: user.id,
            business_name: user.email?.split('@')[0] + "'s Business" || 'My Business',
            email: user.email,
            subscription_tier: tier,
            subscription_status: 'active',
            onboarding_completed: false,
            ai_training_complete: false,
          })
          .select()
          .single();

        if (newWorkspace) {
          setWorkspace(newWorkspace);
          setShowOnboarding(true);
        }
      }
    } catch (error) {
      console.error('Error checking workspace:', error);
    }
  };

  const handleOnboardingComplete = async () => {
    setShowOnboarding(false);
    await checkWorkspace();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  const product = orderDetails?.price_id ? getProductByPriceId(orderDetails.price_id) : null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      {showOnboarding && workspace && user && (
        <OnboardingChat
          workspaceId={workspace.id}
          userName={user.email?.split('@')[0] || 'there'}
          onComplete={handleOnboardingComplete}
        />
      )}
      <div className="max-w-4xl mx-auto px-4 py-16">
        <div className="text-center mb-12">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-green-100 rounded-full mb-6">
            <CheckCircle className="w-12 h-12 text-green-600" />
          </div>
          
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Welcome to FrontDesk AI Pro! 🎉
          </h1>
          
          <p className="text-xl text-gray-600 mb-8">
            Your payment was successful and your AI front desk is being set up.
          </p>
        </div>

        {/* Order Summary */}
        {orderDetails && (
          <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
              <Crown className="w-6 h-6 text-purple-600 mr-3" />
              Order Summary
            </h2>
            
            <div className="border-b border-gray-200 pb-6 mb-6">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">
                    {product?.name || 'FrontDesk AI Pro'}
                  </h3>
                  {product?.description && (
                    <p className="text-gray-600 mt-1">{product.description}</p>
                  )}
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-gray-900">
                    ${(orderDetails.amount_total / 100).toFixed(2)}
                  </p>
                  <p className="text-sm text-gray-500">
                    {orderDetails.currency.toUpperCase()}
                  </p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-sm">
              <div>
                <p className="text-gray-500">Order ID</p>
                <p className="font-mono text-gray-900">{orderDetails.order_id}</p>
              </div>
              <div>
                <p className="text-gray-500">Payment Status</p>
                <p className="font-semibold text-green-600 capitalize">
                  {orderDetails.payment_status}
                </p>
              </div>
              <div>
                <p className="text-gray-500">Order Date</p>
                <p className="text-gray-900">
                  {new Date(orderDetails.order_date).toLocaleDateString()}
                </p>
              </div>
              <div>
                <p className="text-gray-500">Billing Cycle</p>
                <p className="text-gray-900">Monthly</p>
              </div>
            </div>
          </div>
        )}

        {/* Next Steps */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <Zap className="w-6 h-6 text-blue-600 mr-3" />
            What Happens Next?
          </h2>
          
          <div className="space-y-6">
            <div className="flex items-start">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                <span className="text-blue-600 font-semibold">1</span>
              </div>
              <div>
                <h3 className="font-semibold text-gray-900 mb-1">
                  Account Setup (2-5 minutes)
                </h3>
                <p className="text-gray-600">
                  Your AI bots are being activated and configured for your subscription tier.
                </p>
              </div>
            </div>

            <div className="flex items-start">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                <span className="text-blue-600 font-semibold">2</span>
              </div>
              <div>
                <h3 className="font-semibold text-gray-900 mb-1">
                  Welcome Email
                </h3>
                <p className="text-gray-600">
                  Check your inbox for setup instructions and your login credentials.
                </p>
              </div>
            </div>

            <div className="flex items-start">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                <span className="text-blue-600 font-semibold">3</span>
              </div>
              <div>
                <h3 className="font-semibold text-gray-900 mb-1">
                  Start Building
                </h3>
                <p className="text-gray-600">
                  Access your dashboard and begin configuring your AI front desk system.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* CTA Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link
            to="/dashboard"
            className="inline-flex items-center justify-center px-8 py-3 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-colors"
          >
            Go to Dashboard
            <ArrowRight className="w-5 h-5 ml-2" />
          </Link>
          
          <Link
            to="/support"
            className="inline-flex items-center justify-center px-8 py-3 bg-gray-100 text-gray-700 font-semibold rounded-lg hover:bg-gray-200 transition-colors"
          >
            Get Help
          </Link>
        </div>

        {/* Support Info */}
        <div className="mt-12 text-center">
          <p className="text-gray-600 mb-2">
            Need help getting started?
          </p>
          <p className="text-sm text-gray-500">
            Email us at{' '}
            <a href="mailto:support@frontdeskaipro.com" className="text-blue-600 hover:underline">
              support@frontdeskaipro.com
            </a>
            {' '}or check out our{' '}
            <Link to="/docs" className="text-blue-600 hover:underline">
              documentation
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default SuccessPage;