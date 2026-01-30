import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

interface Workspace {
  id: string;
  user_id?: string;
  plan?: string;
  subscription_plan?: string;
  stripe_customer_id?: string;
  stripe_subscription_id?: string;
  subscription_status?: string;
  created_at?: string;
}

export function useWorkspace() {
  const { user } = useAuth();
  const [workspace, setWorkspace] = useState<Workspace | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchWorkspace() {
      if (!user) {
        setWorkspace(null);
        setLoading(false);
        return;
      }

      try {
        // Query profiles table instead of workspaces
        const { data, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

        if (error) {
          console.error('Error fetching profile:', error);
          setWorkspace(null);
        } else {
          // Map profile data to workspace format
          setWorkspace({
            id: data.id,
            user_id: data.id,
            plan: data.subscription_plan,
            subscription_plan: data.subscription_plan,
            stripe_customer_id: data.stripe_customer_id,
            stripe_subscription_id: data.stripe_subscription_id,
            subscription_status: data.subscription_status,
            created_at: data.created_at,
          });
        }
      } catch (err) {
        console.error('Profile fetch error:', err);
        setWorkspace(null);
      } finally {
        setLoading(false);
      }
    }

    fetchWorkspace();
  }, [user]);

  return { workspace, loading };
}
