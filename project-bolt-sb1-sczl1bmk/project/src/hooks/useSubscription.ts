import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { getProductByPriceId } from '../stripe-config';

interface SubscriptionData {
  subscriptionId: string | null;
  priceId: string | null;
  status: string | null;
  planName: string | null;
  currentPeriodEnd: number | null;
  cancelAtPeriodEnd: boolean;
}

export const useSubscription = () => {
  const [subscription, setSubscription] = useState<SubscriptionData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchSubscription = async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        
        if (!user) {
          setSubscription(null);
          setLoading(false);
          return;
        }

        const { data, error } = await supabase
          .from('stripe_user_subscriptions')
          .select('*')
          .single();

        if (error && error.code !== 'PGRST116') {
          throw error;
        }

        if (data) {
          const product = getProductByPriceId(data.price_id);
          setSubscription({
            subscriptionId: data.subscription_id,
            priceId: data.price_id,
            status: data.subscription_status,
            planName: product?.name || 'Unknown Plan',
            currentPeriodEnd: data.current_period_end,
            cancelAtPeriodEnd: data.cancel_at_period_end || false,
          });
        } else {
          setSubscription(null);
        }
      } catch (err) {
        console.error('Error fetching subscription:', err);
        setError(err instanceof Error ? err.message : 'Failed to fetch subscription');
      } finally {
        setLoading(false);
      }
    };

    fetchSubscription();
  }, []);

  return { subscription, loading, error };
};