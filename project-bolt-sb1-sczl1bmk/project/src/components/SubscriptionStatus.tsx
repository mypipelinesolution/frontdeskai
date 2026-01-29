import React, { useEffect, useState } from 'react';
import { Crown, AlertCircle, CheckCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { getProductByPriceId, formatPrice } from '../stripe-config';

interface SubscriptionData {
  subscription_status: string;
  price_id: string;
  current_period_start: number;
  current_period_end: number;
  cancel_at_period_end: boolean;
}

export const SubscriptionStatus: React.FC = () => {
  const { user } = useAuth();
  const [subscription, setSubscription] = useState<SubscriptionData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchSubscription();
    }
  }, [user]);

  const fetchSubscription = async () => {
    try {
      const { data, error } = await supabase
        .from('stripe_user_subscriptions')
        .select('*')
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error fetching subscription:', error);
        return;
      }

      setSubscription(data);
    } catch (error) {
      console.error('Error fetching subscription:', error);
    } finally {
      setLoading(false);
    }
  };

  if (!user || loading) {
    return null;
  }

  if (!subscription) {
    return (
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
        <div className="flex items-center">
          <AlertCircle className="w-5 h-5 text-yellow-600 mr-3" />
          <div>
            <h3 className="text-sm font-medium text-yellow-800">No Active Subscription</h3>
            <p className="text-sm text-yellow-700 mt-1">
              Choose a plan to start using FrontDesk AI Pro
            </p>
          </div>
        </div>
      </div>
    );
  }

  const product = getProductByPriceId(subscription.price_id);
  const isActive = subscription.subscription_status === 'active';
  const willCancel = subscription.cancel_at_period_end;
  const periodEnd = new Date(subscription.current_period_end * 1000);

  const getStatusColor = () => {
    if (!isActive) return 'red';
    if (willCancel) return 'yellow';
    return 'green';
  };

  const getStatusIcon = () => {
    const color = getStatusColor();
    if (color === 'green') return <CheckCircle className="w-5 h-5 text-green-600" />;
    if (color === 'yellow') return <AlertCircle className="w-5 h-5 text-yellow-600" />;
    return <AlertCircle className="w-5 h-5 text-red-600" />;
  };

  const getStatusText = () => {
    if (!isActive) return 'Inactive';
    if (willCancel) return 'Cancelling';
    return 'Active';
  };

  return (
    <div className={`border rounded-lg p-4 mb-6 ${
      getStatusColor() === 'green' ? 'bg-green-50 border-green-200' :
      getStatusColor() === 'yellow' ? 'bg-yellow-50 border-yellow-200' :
      'bg-red-50 border-red-200'
    }`}>
      <div className="flex items-start justify-between">
        <div className="flex items-center">
          <Crown className="w-6 h-6 text-purple-600 mr-3" />
          <div>
            <h3 className="font-semibold text-gray-900">
              {product?.name || 'Unknown Plan'}
            </h3>
            <p className="text-sm text-gray-600">
              {product ? formatPrice(product.price) : ''}/month
            </p>
          </div>
        </div>
        
        <div className="flex items-center">
          {getStatusIcon()}
          <span className={`ml-2 text-sm font-medium ${
            getStatusColor() === 'green' ? 'text-green-800' :
            getStatusColor() === 'yellow' ? 'text-yellow-800' :
            'text-red-800'
          }`}>
            {getStatusText()}
          </span>
        </div>
      </div>

      <div className="mt-3 text-sm text-gray-600">
        {isActive ? (
          willCancel ? (
            <p>Your subscription will end on {periodEnd.toLocaleDateString()}</p>
          ) : (
            <p>Next billing date: {periodEnd.toLocaleDateString()}</p>
          )
        ) : (
          <p>Subscription is not active</p>
        )}
      </div>

      {product?.description && (
        <p className="mt-2 text-sm text-gray-500">
          {product.description}
        </p>
      )}
    </div>
  );
};