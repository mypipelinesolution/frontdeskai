import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { DollarSign, Users, TrendingUp, Link } from 'lucide-react';

interface PartnerStats {
  totalReferrals: number;
  activeSubscriptions: number;
  totalCommissions: number;
  pendingPayouts: number;
}

interface Referral {
  id: string;
  email: string;
  status: string;
  created_at: string;
  subscription_value: number;
}

export default function PartnerDashboard() {
  const { user } = useAuth();
  const [stats, setStats] = useState<PartnerStats>({
    totalReferrals: 0,
    activeSubscriptions: 0,
    totalCommissions: 0,
    pendingPayouts: 0,
  });
  const [referrals, setReferrals] = useState<Referral[]>([]);
  const [referralCode, setReferralCode] = useState<string>('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      loadPartnerData();
    }
  }, [user]);

  const loadPartnerData = async () => {
    try {
      // Get referral code
      const { data: profile } = await supabase
        .from('profiles')
        .select('referral_code')
        .eq('id', user?.id)
        .maybeSingle();

      if (profile?.referral_code) {
        setReferralCode(profile.referral_code);
      }

      // Get referral stats
      const { data: referralData } = await supabase
        .from('referrals')
        .select('*')
        .eq('referrer_id', user?.id);

      if (referralData) {
        const active = referralData.filter(r => r.status === 'active').length;
        setStats({
          totalReferrals: referralData.length,
          activeSubscriptions: active,
          totalCommissions: 0,
          pendingPayouts: 0,
        });
        setReferrals(referralData.slice(0, 10));
      }
    } catch (error) {
      console.error('Error loading partner data:', error);
    } finally {
      setLoading(false);
    }
  };

  const copyReferralLink = () => {
    const link = `${window.location.origin}?ref=${referralCode}`;
    navigator.clipboard.writeText(link);
    alert('Referral link copied to clipboard!');
  };

  const StatCard = ({ icon: Icon, label, value, color }: any) => (
    <div className="bg-white rounded-xl shadow-sm p-6 border border-slate-200">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-slate-600 mb-1">{label}</p>
          <p className="text-3xl font-bold text-slate-900">{value}</p>
        </div>
        <div className={`w-12 h-12 rounded-xl ${color} flex items-center justify-center`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-slate-600">Loading partner dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          <div>
            <h1 className="text-3xl font-bold text-slate-900 mb-2">Partner Dashboard</h1>
            <p className="text-slate-600">Track your referrals and earnings</p>
          </div>

          {/* Referral Link */}
          {referralCode && (
            <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
              <h2 className="text-xl font-bold mb-2">Your Referral Link</h2>
              <p className="text-blue-100 mb-4">Share this link to earn commissions</p>
              <div className="flex gap-3">
                <input
                  type="text"
                  readOnly
                  value={`${window.location.origin}?ref=${referralCode}`}
                  className="flex-1 px-4 py-2 rounded-lg bg-white/10 border border-white/20 text-white placeholder-blue-200"
                />
                <button
                  onClick={copyReferralLink}
                  className="px-6 py-2 bg-white text-blue-600 rounded-lg font-semibold hover:bg-blue-50 transition-colors flex items-center gap-2"
                >
                  <Link className="w-4 h-4" />
                  Copy Link
                </button>
              </div>
            </div>
          )}

          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              icon={Users}
              label="Total Referrals"
              value={stats.totalReferrals}
              color="bg-blue-500"
            />
            <StatCard
              icon={TrendingUp}
              label="Active Subscriptions"
              value={stats.activeSubscriptions}
              color="bg-green-500"
            />
            <StatCard
              icon={DollarSign}
              label="Total Commissions"
              value={`$${stats.totalCommissions}`}
              color="bg-orange-500"
            />
            <StatCard
              icon={DollarSign}
              label="Pending Payouts"
              value={`$${stats.pendingPayouts}`}
              color="bg-purple-500"
            />
          </div>

          {/* Recent Referrals */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h2 className="text-xl font-bold text-slate-900 mb-4">Recent Referrals</h2>
            {referrals.length === 0 ? (
              <div className="text-center py-12">
                <Users className="w-16 h-16 text-slate-300 mx-auto mb-4" />
                <p className="text-slate-500">No referrals yet</p>
                <p className="text-sm text-slate-400 mt-2">
                  Share your referral link to start earning commissions
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-slate-200">
                      <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Email</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Status</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-slate-700">Date</th>
                      <th className="text-right py-3 px-4 text-sm font-semibold text-slate-700">Value</th>
                    </tr>
                  </thead>
                  <tbody>
                    {referrals.map((referral) => (
                      <tr key={referral.id} className="border-b border-slate-100 hover:bg-slate-50">
                        <td className="py-3 px-4 text-sm text-slate-900">{referral.email}</td>
                        <td className="py-3 px-4">
                          <span className={`px-2 py-1 rounded text-xs font-medium ${
                            referral.status === 'active' ? 'bg-green-100 text-green-700' :
                            referral.status === 'pending' ? 'bg-yellow-100 text-yellow-700' :
                            'bg-slate-100 text-slate-700'
                          }`}>
                            {referral.status}
                          </span>
                        </td>
                        <td className="py-3 px-4 text-sm text-slate-600">
                          {new Date(referral.created_at).toLocaleDateString()}
                        </td>
                        <td className="py-3 px-4 text-sm text-slate-900 text-right font-medium">
                          ${referral.subscription_value || 0}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Commission Info */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-6">
            <h3 className="font-semibold text-blue-900 mb-2">How it works</h3>
            <ul className="space-y-2 text-sm text-blue-800">
              <li>• Share your unique referral link with potential customers</li>
              <li>• Earn commission when they subscribe to any plan</li>
              <li>• Get paid monthly for active subscriptions</li>
              <li>• Track all your referrals and earnings in this dashboard</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
