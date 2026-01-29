import { useState, useEffect } from 'react';
import { supabase, Automation, Workspace } from '../../lib/supabase';
import { Bot, Plus, Edit2, Trash2, Power } from 'lucide-react';

export function Automations({ workspace }: { workspace: Workspace }) {
  const [automations, setAutomations] = useState<Automation[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAutomations();
  }, [workspace.id]);

  const loadAutomations = async () => {
    setLoading(true);
    const { data } = await supabase
      .from('automations')
      .select('*')
      .eq('workspace_id', workspace.id)
      .order('created_at', { ascending: false });

    if (data) setAutomations(data);
    setLoading(false);
  };

  const toggleAutomation = async (id: string, currentState: boolean) => {
    await supabase
      .from('automations')
      .update({ enabled: !currentState })
      .eq('id', id);

    await loadAutomations();
  };

  const botTypeInfo: Record<string, { name: string; description: string; color: string; icon: string }> = {
    instant_reply: {
      name: 'Instant Reply Bot',
      description: 'Responds to new leads within 60 seconds via SMS/email',
      color: 'bg-blue-100 text-blue-700',
      icon: '⚡',
    },
    missed_call: {
      name: 'Missed Call Bot',
      description: 'Sends automatic text-back when you miss a call',
      color: 'bg-green-100 text-green-700',
      icon: '📞',
    },
    booking: {
      name: 'Booking Bot',
      description: 'Sends booking link and appointment reminders',
      color: 'bg-purple-100 text-purple-700',
      icon: '📅',
    },
    review: {
      name: 'Review Booster Bot',
      description: 'Requests reviews after completed appointments',
      color: 'bg-orange-100 text-orange-700',
      icon: '⭐',
    },
    reactivation: {
      name: 'Reactivation Bot',
      description: 'Re-engages old leads with follow-up messages',
      color: 'bg-pink-100 text-pink-700',
      icon: '🔄',
    },
    estimate: {
      name: 'Estimate Bot',
      description: 'Collects job details and photo links for quotes',
      color: 'bg-cyan-100 text-cyan-700',
      icon: '💰',
    },
    faq: {
      name: 'FAQ Bot',
      description: 'Answers common questions with saved templates',
      color: 'bg-indigo-100 text-indigo-700',
      icon: '💬',
    },
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-900">AI Automations</h1>
          <p className="text-slate-600 mt-1">Manage your AI bots and automation templates</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
          <Plus className="w-5 h-5" />
          Create Custom Bot
        </button>
      </div>

      <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-xl p-6 text-white">
        <div className="flex items-center gap-3 mb-2">
          <Bot className="w-8 h-8" />
          <h2 className="text-2xl font-bold">Your AI Front Desk is Active</h2>
        </div>
        <p className="text-blue-100">
          {automations.filter(a => a.enabled).length} of {automations.length} bots are running 24/7
        </p>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="text-slate-600 mt-4">Loading automations...</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {automations.map((automation) => {
            const botInfo = botTypeInfo[automation.type] || {
              name: automation.name,
              description: 'Custom automation',
              color: 'bg-slate-100 text-slate-700',
              icon: '🤖',
            };

            return (
              <div
                key={automation.id}
                className={`bg-white rounded-xl border-2 p-6 transition ${
                  automation.enabled ? 'border-blue-200' : 'border-slate-200 opacity-60'
                }`}
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className={`text-3xl w-12 h-12 rounded-lg flex items-center justify-center ${botInfo.color}`}>
                      {botInfo.icon}
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-900">{botInfo.name}</h3>
                      <p className="text-sm text-slate-600">{botInfo.description}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => toggleAutomation(automation.id, automation.enabled)}
                    className={`p-2 rounded-lg transition ${
                      automation.enabled
                        ? 'bg-green-100 text-green-700 hover:bg-green-200'
                        : 'bg-slate-100 text-slate-400 hover:bg-slate-200'
                    }`}
                  >
                    <Power className="w-5 h-5" />
                  </button>
                </div>

                <div className="bg-slate-50 rounded-lg p-4 mb-4">
                  <p className="text-xs text-slate-600 mb-2">Template Message:</p>
                  <p className="text-sm text-slate-800">{automation.template}</p>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <span className={`px-3 py-1 rounded-full font-medium ${
                    automation.enabled ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-600'
                  }`}>
                    {automation.enabled ? 'Active' : 'Disabled'}
                  </span>
                  <div className="flex gap-2">
                    <button className="p-2 hover:bg-slate-100 rounded-lg transition">
                      <Edit2 className="w-4 h-4 text-slate-600" />
                    </button>
                    <button className="p-2 hover:bg-red-100 rounded-lg transition">
                      <Trash2 className="w-4 h-4 text-red-600" />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {automations.length === 0 && !loading && (
        <div className="bg-white rounded-xl shadow-sm p-12 text-center">
          <Bot className="w-16 h-16 text-slate-400 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-slate-900 mb-2">No Automations Yet</h3>
          <p className="text-slate-600 mb-6">
            Create your first automation to start capturing and converting leads automatically
          </p>
          <button className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition">
            Create Your First Bot
          </button>
        </div>
      )}
    </div>
  );
}
