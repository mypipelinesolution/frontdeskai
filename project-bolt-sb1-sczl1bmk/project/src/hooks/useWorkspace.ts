import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

interface Workspace {
  id: string;
  user_id: string;
  plan: string;
  stripe_customer_id?: string;
  stripe_subscription_id?: string;
  created_at: string;
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
        const { data, error } = await supabase
          .from('workspaces')
          .select('*')
          .eq('user_id', user.id)
          .single();

        if (error) {
          console.error('Error fetching workspace:', error);
          setWorkspace(null);
        } else {
          setWorkspace(data);
        }
      } catch (err) {
        console.error('Workspace fetch error:', err);
        setWorkspace(null);
      } finally {
        setLoading(false);
      }
    }

    fetchWorkspace();
  }, [user]);

  return { workspace, loading };
}
