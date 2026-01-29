import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export interface Workspace {
  id: string;
  user_id: string;
  name: string;
  business_name?: string;
  business_type?: string;
  phone?: string;
  website?: string;
  widget_settings?: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface Lead {
  id: string;
  workspace_id: string;
  name: string;
  full_name?: string;
  email?: string;
  phone?: string;
  status: string;
  source?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface Message {
  id: string;
  lead_id: string;
  workspace_id: string;
  content: string;
  body?: string;
  sender: 'user' | 'bot' | 'agent';
  direction?: 'inbound' | 'outbound';
  channel?: string;
  created_at: string;
}

export interface Automation {
  id: string;
  workspace_id: string;
  name: string;
  type: string;
  enabled: boolean;
  template?: string;
  config?: Record<string, unknown>;
  created_at: string;
  updated_at: string;
}

export interface Order {
  id: string;
  user_id: string;
  amount: number;
  status: string;
  plan?: string;
  referred_by?: string;
  created_at: string;
}

export interface InternalPayout {
  id: string;
  amount_due: number;
  status: string;
  created_at: string;
}

export interface FamilyRep {
  id: string;
  name: string;
  email: string;
}

export interface LocalLinkOutbox {
  id: string;
  sync_status: string;
  referral_slug?: string;
  amount?: number;
  sync_attempts?: number;
  created_at: string;
}

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Environment variables check:', {
    VITE_SUPABASE_URL: supabaseUrl ? 'present' : 'MISSING',
    VITE_SUPABASE_ANON_KEY: supabaseAnonKey ? 'present' : 'MISSING',
    allEnvVars: import.meta.env
  });
  throw new Error(
    'Missing Supabase environment variables. ' +
    'Please ensure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are set in your deployment platform.'
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)