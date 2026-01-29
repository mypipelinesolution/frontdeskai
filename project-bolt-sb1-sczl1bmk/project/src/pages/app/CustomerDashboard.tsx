import { useState, useEffect } from 'react';
import { supabase, Lead, Message, Workspace } from '../../lib/supabase';
import { Users, MessageSquare, Calendar, TrendingUp } from 'lucide-react';

export function CustomerDashboard({ workspace }: { workspace: Workspace }) {
  const [stats, setStats] = useState({
    totalLeads: 0,
    newLeads: 0,
    messages: 0,
    conversionRate: 0,
  });
  const [recentLeads, setRecentLeads] = useState<Lead[]>([]);
  const [recentMessages, setRecentMessages] = useState<Message[]>([]);

  useEffect(() => {
    loadDashboardData();
  }, [workspace.id]);

  const loadDashboardData = async () => {
    const { data: leads } = await supabase
      .from('leads')
      .select('*')
      .eq('workspace_id', workspace.id)
      .order('created_at', { ascending: false });

    const { data: messages } = await supabase
      .from('messages')
      .select('*')
      .eq('workspace_id', workspace.id)
      .order('created_at', { ascending: false })
      .limit(5);

    if (leads) {
      const newLeads = leads.filter(l => l.status === 'new');
      const closedLeads = leads.filter(l => l.status === 'closed');
      const conversionRate = leads.length > 0 ? (closedLeads.length / leads.length) * 100 : 0;

      setStats({
        totalLeads: leads.length,
        newLeads: newLeads.length,
        messages: messages?.length || 0,
        conversionRate: Math.round(conversionRate),
      });

      setRecentLeads(leads.slice(0, 5));
    }

    if (messages) {
      setRecentMessages(messages);
    }
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
        <h1 className="text-3xl font-bold text-slate-900 mb-2">Dashboard</h1>
        <p className="text-slate-600">Welcome back to {workspace.business_name}</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          icon={Users}
          label="Total Leads"
          value={stats.totalLeads}
          color="bg-blue-500"
        />
        <StatCard
          icon={MessageSquare}
          label="New Leads"
          value={stats.newLeads}
          color="bg-green-500"
        />
        <StatCard
          icon={Calendar}
          label="Messages Sent"
          value={stats.messages}
          color="bg-purple-500"
        />
        <StatCard
          icon={TrendingUp}
          label="Conversion Rate"
          value={`${stats.conversionRate}%`}
          color="bg-orange-500"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-xl font-bold text-slate-900 mb-4">Recent Leads</h2>
          {recentLeads.length === 0 ? (
            <p className="text-slate-500 text-center py-8">No leads yet</p>
          ) : (
            <div className="space-y-3">
              {recentLeads.map((lead) => (
                <div key={lead.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200">
                  <div className="flex items-start justify-between">
                    <div>
                      <h4 className="font-semibold text-slate-900">{lead.full_name}</h4>
                      <p className="text-sm text-slate-600">{lead.email || lead.phone}</p>
                      <p className="text-xs text-slate-500 mt-1">Source: {lead.source}</p>
                    </div>
                    <span className={`px-2 py-1 rounded text-xs font-medium ${
                      lead.status === 'new' ? 'bg-green-100 text-green-700' :
                      lead.status === 'closed' ? 'bg-blue-100 text-blue-700' :
                      'bg-slate-100 text-slate-700'
                    }`}>
                      {lead.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-xl font-bold text-slate-900 mb-4">Recent Messages</h2>
          {recentMessages.length === 0 ? (
            <p className="text-slate-500 text-center py-8">No messages yet</p>
          ) : (
            <div className="space-y-3">
              {recentMessages.map((message) => (
                <div key={message.id} className="p-3 bg-slate-50 rounded-lg border border-slate-200">
                  <div className="flex items-start justify-between mb-2">
                    <span className={`px-2 py-1 rounded text-xs font-medium ${
                      message.direction === 'inbound' ? 'bg-blue-100 text-blue-700' :
                      'bg-green-100 text-green-700'
                    }`}>
                      {message.direction}
                    </span>
                    <span className="text-xs text-slate-500">{message.channel}</span>
                  </div>
                  <p className="text-sm text-slate-700">{message.body.substring(0, 100)}...</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-8 text-white">
        <h2 className="text-2xl font-bold mb-2">Your AI Front Desk is Live!</h2>
        <p className="text-blue-100 mb-4">
          Leads are being captured and responded to automatically 24/7
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
          <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
            <h3 className="font-semibold mb-1">Instant Replies</h3>
            <p className="text-sm text-blue-100">Under 60 seconds</p>
          </div>
          <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
            <h3 className="font-semibold mb-1">Missed Call Texts</h3>
            <p className="text-sm text-blue-100">Never miss a lead</p>
          </div>
          <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
            <h3 className="font-semibold mb-1">Auto Follow-ups</h3>
            <p className="text-sm text-blue-100">Smart sequences</p>
          </div>
        </div>
      </div>
    </div>
  );
}
