import { useState, useEffect } from 'react';
import { supabase, Order, InternalPayout, FamilyRep, LocalLinkOutbox } from '../../lib/supabase';
import { DollarSign, Users, TrendingUp, Send, Package } from 'lucide-react';
import VerticalLicensing from './VerticalLicensing';

type AdminTab = 'overview' | 'verticals';

export function AdminDashboard() {
  const [activeTab, setActiveTab] = useState<AdminTab>('overview');
  const [stats, setStats] = useState({
    mrr: 0,
    totalOrders: 0,
    activeCustomers: 0,
    pendingPayouts: 0,
  });
  const [orders, setOrders] = useState<Order[]>([]);
  const [payouts, setPayouts] = useState<(InternalPayout & { family_reps?: FamilyRep })[]>([]);
  const [outbox, setOutbox] = useState<LocalLinkOutbox[]>([]);

  useEffect(() => {
    loadAdminData();
  }, []);

  const loadAdminData = async () => {
    const { data: ordersData } = await supabase
      .from('orders')
      .select('*')
      .order('created_at', { ascending: false });

    const { data: payoutsData } = await supabase
      .from('internal_payouts')
      .select('*, family_reps(*)')
      .eq('status', 'pending');

    const { data: outboxData } = await supabase
      .from('locallink_outbox')
      .select('*')
      .eq('sync_status', 'pending');

    if (ordersData) {
      const activeOrders = ordersData.filter(o => o.status === 'active');
      const mrr = activeOrders.reduce((sum, o) => sum + o.amount, 0) / 100;

      setStats({
        mrr,
        totalOrders: ordersData.length,
        activeCustomers: activeOrders.length,
        pendingPayouts: payoutsData?.reduce((sum, p) => sum + Number(p.amount_due), 0) || 0,
      });

      setOrders(ordersData.slice(0, 10));
    }

    if (payoutsData) setPayouts(payoutsData);
    if (outboxData) setOutbox(outboxData);
  };

  const markPayoutPaid = async (payoutId: string) => {
    await supabase
      .from('internal_payouts')
      .update({ status: 'paid', paid_at: new Date().toISOString() })
      .eq('id', payoutId);
    await loadAdminData();
  };

  const syncToLocalLink = async (outboxId: string) => {
    await supabase
      .from('locallink_outbox')
      .update({
        sync_status: 'sent',
        synced_at: new Date().toISOString(),
        sync_attempts: 1,
      })
      .eq('id', outboxId);
    await loadAdminData();
    alert('Synced to Local-Link (simulated)');
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

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-slate-900 mb-2">Admin Dashboard</h1>
        <p className="text-slate-600">FrontDesk AI Pro Business Overview</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-2 flex gap-2">
        <button
          onClick={() => setActiveTab('overview')}
          className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg font-medium transition ${
            activeTab === 'overview'
              ? 'bg-blue-600 text-white'
              : 'text-gray-600 hover:bg-gray-100'
          }`}
        >
          <TrendingUp className="h-5 w-5" />
          Overview
        </button>
        <button
          onClick={() => setActiveTab('verticals')}
          className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-lg font-medium transition ${
            activeTab === 'verticals'
              ? 'bg-blue-600 text-white'
              : 'text-gray-600 hover:bg-gray-100'
          }`}
        >
          <Package className="h-5 w-5" />
          Vertical Licensing
        </button>
      </div>

      {activeTab === 'verticals' ? (
        <VerticalLicensing />
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon={DollarSign}
          label="Monthly Recurring Revenue"
          value={`$${stats.mrr.toFixed(0)}`}
          color="bg-green-500"
        />
        <StatCard
          icon={Users}
          label="Active Customers"
          value={stats.activeCustomers}
          color="bg-blue-500"
        />
        <StatCard
          icon={TrendingUp}
          label="Total Orders"
          value={stats.totalOrders}
          color="bg-purple-500"
        />
        <StatCard
          icon={DollarSign}
          label="Pending Payouts"
          value={`$${stats.pendingPayouts.toFixed(0)}`}
          color="bg-orange-500"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-xl font-bold text-slate-900 mb-4">Recent Orders</h2>
          {orders.length === 0 ? (
            <p className="text-slate-500 text-center py-8">No orders yet</p>
          ) : (
            <div className="space-y-3">
              {orders.map((order) => (
                <div key={order.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-semibold text-slate-900">{(order.plan || 'N/A').toUpperCase()}</h4>
                      <p className="text-sm text-slate-600">${(order.amount / 100).toFixed(2)}/mo</p>
                      {order.referred_by && (
                        <p className="text-xs text-blue-600 mt-1">Ref: {order.referred_by}</p>
                      )}
                    </div>
                    <span className={`px-2 py-1 rounded text-xs font-medium ${
                      order.status === 'active' ? 'bg-green-100 text-green-700' :
                      order.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                      'bg-orange-100 text-orange-700'
                    }`}>
                      {order.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-xl font-bold text-slate-900 mb-4">Family Payouts (80%)</h2>
          {payouts.length === 0 ? (
            <p className="text-slate-500 text-center py-8">No pending payouts</p>
          ) : (
            <div className="space-y-3">
              {payouts.map((payout) => (
                <div key={payout.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-semibold text-slate-900">{payout.family_reps?.name}</h4>
                      <p className="text-sm text-slate-600">${Number(payout.amount_due).toFixed(2)}</p>
                      <p className="text-xs text-slate-500 mt-1">Pending</p>
                    </div>
                    <button
                      onClick={() => markPayoutPaid(payout.id)}
                      className="px-3 py-1 bg-green-600 hover:bg-green-700 text-white text-sm rounded transition"
                    >
                      Mark Paid
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm p-6">
        <h2 className="text-xl font-bold text-slate-900 mb-4">Local-Link Sync Queue</h2>
        {outbox.length === 0 ? (
          <p className="text-slate-500 text-center py-8">No pending syncs</p>
        ) : (
          <div className="space-y-3">
            {outbox.map((item) => (
              <div key={item.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200 flex items-center justify-between">
                <div>
                  <h4 className="font-semibold text-slate-900">Referral: {item.referral_slug}</h4>
                  <p className="text-sm text-slate-600">${Number(item.amount).toFixed(2)}</p>
                  <p className="text-xs text-slate-500 mt-1">Attempts: {item.sync_attempts}</p>
                </div>
                <button
                  onClick={() => syncToLocalLink(item.id)}
                  className="flex items-center gap-2 px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white text-sm rounded transition"
                >
                  <Send className="w-4 h-4" />
                  Sync Now
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
        </>
      )}
    </div>
  );
}
