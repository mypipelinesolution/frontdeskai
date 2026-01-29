import { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Users, DollarSign, TrendingUp, Check, ExternalLink } from 'lucide-react';

interface Payout {
  id: string;
  order_id: string;
  recipient_type: 'family' | 'employee';
  recipient_id: string;
  recipient_name: string;
  order_amount: number;
  commission_rate: number;
  commission_amount: number;
  status: 'pending' | 'processing' | 'paid' | 'failed';
  payment_method: string | null;
  paid_at: string | null;
  period_start: string;
  period_end: string;
  locallink_sync_status: 'pending' | 'synced' | 'failed';
  locallink_synced_at: string | null;
  notes: string | null;
  created_at: string;
}

interface PayoutSummary {
  recipient_type: string;
  recipient_id: string;
  recipient_name: string;
  total_orders: number;
  total_earned: number;
  total_paid: number;
  total_pending: number;
  last_payment_date: string | null;
}

export default function CommissionPayouts() {
  const [payouts, setPayouts] = useState<Payout[]>([]);
  const [summaries, setSummaries] = useState<PayoutSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'family' | 'employee'>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'paid'>('all');

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      const { data: payoutData } = await supabase
        .from('commission_payouts')
        .select('*')
        .order('created_at', { ascending: false });

      setPayouts(payoutData || []);

      const { data: summaryData } = await supabase
        .from('payout_summary')
        .select('*')
        .order('total_earned', { ascending: false });

      setSummaries(summaryData || []);
    } catch (error) {
      console.error('Error loading payouts:', error);
    } finally {
      setLoading(false);
    }
  }

  async function markAsPaid(payoutId: string) {
    try {
      await supabase
        .from('commission_payouts')
        .update({
          status: 'paid',
          paid_at: new Date().toISOString(),
        })
        .eq('id', payoutId);

      await loadData();
    } catch (error) {
      console.error('Error updating payout:', error);
    }
  }

  async function syncToLocalLink(payoutId: string) {
    try {
      await supabase
        .from('commission_payouts')
        .update({
          locallink_sync_status: 'synced',
          locallink_synced_at: new Date().toISOString(),
        })
        .eq('id', payoutId);

      await loadData();
    } catch (error) {
      console.error('Error syncing to LocalLink:', error);
    }
  }

  const filteredPayouts = payouts.filter(p => {
    if (filter !== 'all' && p.recipient_type !== filter) return false;
    if (statusFilter !== 'all' && p.status !== statusFilter) return false;
    return true;
  });

  const familySummaries = summaries.filter(s => s.recipient_type === 'family');
  const employeeSummaries = summaries.filter(s => s.recipient_type === 'employee');

  const totalFamilyPending = familySummaries.reduce((sum, s) => sum + s.total_pending, 0);
  const totalEmployeePending = employeeSummaries.reduce((sum, s) => sum + s.total_pending, 0);
  const totalFamilyPaid = familySummaries.reduce((sum, s) => sum + s.total_paid, 0);
  const totalEmployeePaid = employeeSummaries.reduce((sum, s) => sum + s.total_paid, 0);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Commission Payouts</h1>
        <p className="text-gray-600">Track and manage family and employee commissions</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-sm p-6 border border-blue-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Family Pending (80%)</p>
              <p className="text-2xl font-bold text-gray-900">
                ${(totalFamilyPending / 100).toFixed(2)}
              </p>
            </div>
            <Users className="h-10 w-10 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-green-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Family Paid</p>
              <p className="text-2xl font-bold text-gray-900">
                ${(totalFamilyPaid / 100).toFixed(2)}
              </p>
            </div>
            <Check className="h-10 w-10 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-orange-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Employee Pending (50%)</p>
              <p className="text-2xl font-bold text-gray-900">
                ${(totalEmployeePending / 100).toFixed(2)}
              </p>
            </div>
            <DollarSign className="h-10 w-10 text-orange-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-teal-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Employee Paid</p>
              <p className="text-2xl font-bold text-gray-900">
                ${(totalEmployeePaid / 100).toFixed(2)}
              </p>
            </div>
            <TrendingUp className="h-10 w-10 text-teal-500" />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
        <div className="p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">Summary by Person</h2>

          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Family Payouts (80%)</h3>
            {familySummaries.length === 0 ? (
              <p className="text-gray-500 text-sm">No payouts yet</p>
            ) : (
              <div className="space-y-3">
                {familySummaries.map(summary => (
                  <div key={summary.recipient_id} className="flex items-center justify-between p-4 bg-blue-50 rounded-lg">
                    <div>
                      <p className="font-medium text-gray-900">{summary.recipient_name}</p>
                      <p className="text-sm text-gray-600">{summary.total_orders} orders</p>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-bold text-gray-900">
                        ${(summary.total_earned / 100).toFixed(2)}
                      </p>
                      <p className="text-sm text-green-600">
                        Paid: ${(summary.total_paid / 100).toFixed(2)}
                      </p>
                      <p className="text-sm text-orange-600">
                        Pending: ${(summary.total_pending / 100).toFixed(2)}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-3">Employee Payouts (50%)</h3>
            {employeeSummaries.length === 0 ? (
              <p className="text-gray-500 text-sm">No payouts yet</p>
            ) : (
              <div className="space-y-3">
                {employeeSummaries.map(summary => (
                  <div key={summary.recipient_id} className="flex items-center justify-between p-4 bg-orange-50 rounded-lg">
                    <div>
                      <p className="font-medium text-gray-900">{summary.recipient_name}</p>
                      <p className="text-sm text-gray-600">{summary.total_orders} orders</p>
                    </div>
                    <div className="text-right">
                      <p className="text-lg font-bold text-gray-900">
                        ${(summary.total_earned / 100).toFixed(2)}
                      </p>
                      <p className="text-sm text-green-600">
                        Paid: ${(summary.total_paid / 100).toFixed(2)}
                      </p>
                      <p className="text-sm text-orange-600">
                        Pending: ${(summary.total_pending / 100).toFixed(2)}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-gray-900">All Transactions</h2>
            <div className="flex gap-4">
              <select
                value={filter}
                onChange={(e) => setFilter(e.target.value as any)}
                className="px-4 py-2 border border-gray-300 rounded-lg"
              >
                <option value="all">All Types</option>
                <option value="family">Family Only</option>
                <option value="employee">Employees Only</option>
              </select>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as any)}
                className="px-4 py-2 border border-gray-300 rounded-lg"
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="paid">Paid</option>
              </select>
            </div>
          </div>

          {filteredPayouts.length === 0 ? (
            <p className="text-gray-500 text-center py-8">No payouts found</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900">Recipient</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900">Type</th>
                    <th className="px-4 py-3 text-right text-sm font-semibold text-gray-900">Order Amount</th>
                    <th className="px-4 py-3 text-right text-sm font-semibold text-gray-900">Rate</th>
                    <th className="px-4 py-3 text-right text-sm font-semibold text-gray-900">Commission</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900">Status</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900">LocalLink</th>
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredPayouts.map(payout => (
                    <tr key={payout.id} className="hover:bg-gray-50">
                      <td className="px-4 py-3 text-sm text-gray-900">{payout.recipient_name}</td>
                      <td className="px-4 py-3">
                        <span className={`px-2 py-1 text-xs font-medium rounded ${
                          payout.recipient_type === 'family'
                            ? 'bg-blue-100 text-blue-700'
                            : 'bg-orange-100 text-orange-700'
                        }`}>
                          {payout.recipient_type}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-right text-gray-900">
                        ${(payout.order_amount / 100).toFixed(2)}
                      </td>
                      <td className="px-4 py-3 text-sm text-right text-gray-900">
                        {(payout.commission_rate * 100).toFixed(0)}%
                      </td>
                      <td className="px-4 py-3 text-sm text-right font-semibold text-gray-900">
                        ${(payout.commission_amount / 100).toFixed(2)}
                      </td>
                      <td className="px-4 py-3">
                        <span className={`px-2 py-1 text-xs font-medium rounded ${
                          payout.status === 'paid'
                            ? 'bg-green-100 text-green-700'
                            : payout.status === 'pending'
                            ? 'bg-yellow-100 text-yellow-700'
                            : 'bg-red-100 text-red-700'
                        }`}>
                          {payout.status}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <span className={`px-2 py-1 text-xs font-medium rounded ${
                          payout.locallink_sync_status === 'synced'
                            ? 'bg-green-100 text-green-700'
                            : payout.locallink_sync_status === 'pending'
                            ? 'bg-gray-100 text-gray-700'
                            : 'bg-red-100 text-red-700'
                        }`}>
                          {payout.locallink_sync_status}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex gap-2">
                          {payout.status === 'pending' && (
                            <button
                              onClick={() => markAsPaid(payout.id)}
                              className="p-1 text-green-600 hover:bg-green-50 rounded"
                              title="Mark as Paid"
                            >
                              <Check className="h-4 w-4" />
                            </button>
                          )}
                          {payout.locallink_sync_status !== 'synced' && (
                            <button
                              onClick={() => syncToLocalLink(payout.id)}
                              className="p-1 text-blue-600 hover:bg-blue-50 rounded"
                              title="Sync to LocalLink"
                            >
                              <ExternalLink className="h-4 w-4" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
