import { useState, useEffect } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { supabase } from '../../lib/supabase';
import { Bot, Check, X, Zap, TrendingUp, Activity, AlertCircle } from 'lucide-react';

interface BotType {
  id: string;
  bot_number: string;
  name: string;
  category: string;
  description: string;
  capabilities: string[];
  enabled: boolean;
}

interface WorkspaceBot {
  id: string;
  bot_type_id: string;
  enabled: boolean;
  last_executed_at: string | null;
  execution_count: number;
}

interface BotExecution {
  bot_type_id: string;
  bot_name: string;
  total_executions: number;
  success_rate: number;
}

export default function BotsDashboard() {
  const { user } = useAuth();
  const [workspace, setWorkspace] = useState<any>(null);
  const [botTypes, setBotTypes] = useState<BotType[]>([]);
  const [workspaceBots, setWorkspaceBots] = useState<WorkspaceBot[]>([]);
  const [botExecutions, setBotExecutions] = useState<BotExecution[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  useEffect(() => {
    loadData();
  }, [user]);

  async function loadData() {
    if (!user) {
      setLoading(false);
      return;
    }

    try {
      const { data: workspaceData, error: workspaceError } = await supabase
        .from('workspaces')
        .select('*')
        .eq('owner_id', user.id)
        .maybeSingle();

      if (workspaceError) {
        console.error('Error loading workspace:', workspaceError);
        setLoading(false);
        return;
      }

      setWorkspace(workspaceData);

      if (workspaceData) {
        const { data: botTypesData } = await supabase
          .from('bot_types')
          .select('*')
          .eq('enabled', true)
          .order('sort_order');

        setBotTypes(botTypesData || []);

        const { data: workspaceBotsData } = await supabase
          .from('workspace_bots')
          .select('*')
          .eq('workspace_id', workspaceData.id);

        setWorkspaceBots(workspaceBotsData || []);

        const { data: executionStats } = await supabase
          .from('bot_execution_logs')
          .select('bot_type_id, status')
          .eq('workspace_id', workspaceData.id);

        if (executionStats) {
          const statsMap = new Map<string, { total: number; success: number }>();

          executionStats.forEach((log: any) => {
            const current = statsMap.get(log.bot_type_id) || { total: 0, success: 0 };
            current.total++;
            if (log.status === 'success') current.success++;
            statsMap.set(log.bot_type_id, current);
          });

          const executions = Array.from(statsMap.entries()).map(([botTypeId, stats]) => {
            const bot = botTypesData?.find(b => b.id === botTypeId);
            return {
              bot_type_id: botTypeId,
              bot_name: bot?.name || 'Unknown',
              total_executions: stats.total,
              success_rate: (stats.success / stats.total) * 100,
            };
          });

          setBotExecutions(executions);
        }
      }
    } catch (error) {
      console.error('Error loading bots:', error);
    } finally {
      setLoading(false);
    }
  }

  async function toggleBot(botTypeId: string, currentlyEnabled: boolean) {
    if (!workspace) return;

    try {
      const workspaceBot = workspaceBots.find(wb => wb.bot_type_id === botTypeId);

      if (workspaceBot) {
        await supabase
          .from('workspace_bots')
          .update({ enabled: !currentlyEnabled })
          .eq('id', workspaceBot.id);
      } else {
        await supabase
          .from('workspace_bots')
          .insert({
            workspace_id: workspace.id,
            bot_type_id: botTypeId,
            enabled: true,
          });
      }

      await loadData();
    } catch (error) {
      console.error('Error toggling bot:', error);
    }
  }

  function isBotEnabled(botTypeId: string): boolean {
    const workspaceBot = workspaceBots.find(wb => wb.bot_type_id === botTypeId);
    return workspaceBot?.enabled || false;
  }

  function getBotStats(botTypeId: string) {
    const workspaceBot = workspaceBots.find(wb => wb.bot_type_id === botTypeId);
    const execution = botExecutions.find(ex => ex.bot_type_id === botTypeId);

    return {
      executions: workspaceBot?.execution_count || 0,
      lastRun: workspaceBot?.last_executed_at,
      successRate: execution?.success_rate || 0,
    };
  }

  const categories = [
    { value: 'all', label: 'All Bots', count: botTypes.length },
    { value: 'CORE', label: 'Core Foundation', count: botTypes.filter(b => b.category === 'CORE').length },
    { value: 'STARTER', label: 'Receptionist', count: botTypes.filter(b => b.category === 'STARTER').length },
    { value: 'CORE_TIER', label: 'Sales Assistant', count: botTypes.filter(b => b.category === 'CORE_TIER').length },
    { value: 'ACCELERATOR', label: 'Growth Machine', count: botTypes.filter(b => b.category === 'ACCELERATOR').length },
    { value: 'DFY', label: 'Done For You', count: botTypes.filter(b => b.category === 'DFY').length },
    { value: 'ADD_ON', label: 'Premium Add-Ons', count: botTypes.filter(b => b.category === 'ADD_ON').length },
  ];

  const filteredBots = selectedCategory === 'all'
    ? botTypes
    : botTypes.filter(b => b.category === selectedCategory);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!workspace) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="max-w-md text-center">
          <AlertCircle className="h-16 w-16 text-yellow-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">No Workspace Found</h2>
          <p className="text-gray-600 mb-4">
            Your workspace is being set up. This happens automatically after payment is processed.
          </p>
          <p className="text-sm text-gray-500">
            If you just completed checkout, please wait a moment and refresh the page.
          </p>
        </div>
      </div>
    );
  }

  const totalExecutions = workspaceBots.reduce((sum, wb) => sum + wb.execution_count, 0);
  const activeBots = workspaceBots.filter(wb => wb.enabled).length;
  const avgSuccessRate = botExecutions.length > 0
    ? botExecutions.reduce((sum, ex) => sum + ex.success_rate, 0) / botExecutions.length
    : 0;

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="mb-8 relative rounded-2xl overflow-hidden bg-gradient-to-r from-purple-900/40 to-blue-900/40 border border-purple-500/20">
        <div className="p-8">
          <h1 className="text-4xl font-bold text-white mb-2">AI Bot Team Dashboard</h1>
          <p className="text-white/90 text-lg">Manage your 38-bot AI workforce</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Active Bots</p>
              <p className="text-3xl font-bold text-gray-900">{activeBots}</p>
            </div>
            <Bot className="h-10 w-10 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Executions</p>
              <p className="text-3xl font-bold text-gray-900">{totalExecutions.toLocaleString()}</p>
            </div>
            <Zap className="h-10 w-10 text-yellow-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Success Rate</p>
              <p className="text-3xl font-bold text-gray-900">{avgSuccessRate.toFixed(1)}%</p>
            </div>
            <TrendingUp className="h-10 w-10 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Bot Health</p>
              <p className="text-3xl font-bold text-gray-900">Excellent</p>
            </div>
            <Activity className="h-10 w-10 text-purple-500" />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-6 p-4">
        <div className="flex flex-wrap gap-2">
          {categories.map(cat => (
            <button
              key={cat.value}
              onClick={() => setSelectedCategory(cat.value)}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                selectedCategory === cat.value
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              {cat.label} ({cat.count})
            </button>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredBots.map(bot => {
          const enabled = isBotEnabled(bot.id);
          const stats = getBotStats(bot.id);

          return (
            <div
              key={bot.id}
              className={`bg-white rounded-lg shadow-sm border-2 p-6 transition-all ${
                enabled ? 'border-green-500' : 'border-gray-200'
              }`}
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-start gap-3">
                  <div className={`p-2 rounded-lg ${
                    enabled ? 'bg-green-100' : 'bg-gray-100'
                  }`}>
                    <Bot className={`h-6 w-6 ${
                      enabled ? 'text-green-600' : 'text-gray-400'
                    }`} />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h3 className="text-lg font-bold text-gray-900">
                        #{bot.bot_number} {bot.name}
                      </h3>
                      {enabled && (
                        <span className="px-2 py-1 bg-green-100 text-green-700 text-xs font-medium rounded">
                          Active
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-gray-600 mt-1">{bot.description}</p>
                  </div>
                </div>
                <button
                  onClick={() => toggleBot(bot.id, enabled)}
                  className={`p-2 rounded-lg transition-colors ${
                    enabled
                      ? 'bg-green-100 text-green-600 hover:bg-green-200'
                      : 'bg-gray-100 text-gray-400 hover:bg-gray-200'
                  }`}
                >
                  {enabled ? <Check className="h-5 w-5" /> : <X className="h-5 w-5" />}
                </button>
              </div>

              <div className="flex flex-wrap gap-2 mb-4">
                {bot.capabilities.slice(0, 4).map(cap => (
                  <span
                    key={cap}
                    className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded"
                  >
                    {cap.replace(/_/g, ' ')}
                  </span>
                ))}
                {bot.capabilities.length > 4 && (
                  <span className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded">
                    +{bot.capabilities.length - 4} more
                  </span>
                )}
              </div>

              {enabled && (
                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <div className="text-sm">
                    <p className="text-gray-600">Executions</p>
                    <p className="font-bold text-gray-900">{stats.executions}</p>
                  </div>
                  <div className="text-sm">
                    <p className="text-gray-600">Success Rate</p>
                    <p className="font-bold text-gray-900">{stats.successRate.toFixed(0)}%</p>
                  </div>
                  <div className="text-sm">
                    <p className="text-gray-600">Last Run</p>
                    <p className="font-bold text-gray-900">
                      {stats.lastRun ? new Date(stats.lastRun).toLocaleDateString() : 'Never'}
                    </p>
                  </div>
                </div>
              )}

              {!enabled && bot.category === 'ADD_ON' && (
                <div className="flex items-center gap-2 pt-4 border-t border-gray-200">
                  <AlertCircle className="h-4 w-4 text-blue-500" />
                  <p className="text-sm text-blue-600">
                    Premium add-on available for purchase
                  </p>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
