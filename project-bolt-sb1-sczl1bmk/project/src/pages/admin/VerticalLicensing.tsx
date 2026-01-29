import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { Package, DollarSign, Users, TrendingUp, Plus, Check, X, Building2, Zap } from 'lucide-react';

interface VerticalTemplate {
  id: string;
  name: string;
  slug: string;
  industry: string;
  description: string;
  tagline: string;
  target_customers: string[];
  base_price_monthly: number;
  enabled: boolean;
}

interface VerticalLicense {
  id: string;
  license_key: string;
  business_name: string;
  subdomain: string;
  status: string;
  monthly_price: number;
  mrr_contribution: number;
  total_workspaces: number;
  total_revenue: number;
  activated_at: string;
  vertical_template_id: string;
}

export default function VerticalLicensing() {
  const [templates, setTemplates] = useState<VerticalTemplate[]>([]);
  const [licenses, setLicenses] = useState<VerticalLicense[]>([]);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [selectedTemplate, setSelectedTemplate] = useState<string>('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  async function loadData() {
    try {
      const { data: templatesData } = await supabase
        .from('vertical_templates')
        .select('*')
        .order('industry');

      const { data: licensesData } = await supabase
        .from('vertical_licenses')
        .select('*')
        .order('created_at', { ascending: false });

      setTemplates(templatesData || []);
      setLicenses(licensesData || []);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  }

  const totalMRR = licenses
    .filter(l => l.status === 'active')
    .reduce((sum, l) => sum + l.mrr_contribution, 0);

  const totalRevenue = licenses.reduce((sum, l) => sum + l.total_revenue, 0);

  const activeLicenses = licenses.filter(l => l.status === 'active').length;

  function getTemplateName(templateId: string): string {
    return templates.find(t => t.id === templateId)?.name || 'Unknown';
  }

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
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Vertical Licensing System</h1>
        <p className="text-gray-600">Manage white-label AI companies powered by your bot ecosystem</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Active Licenses</p>
              <p className="text-3xl font-bold text-gray-900">{activeLicenses}</p>
            </div>
            <Package className="h-10 w-10 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Monthly MRR</p>
              <p className="text-3xl font-bold text-gray-900">${(totalMRR / 100).toLocaleString()}</p>
            </div>
            <DollarSign className="h-10 w-10 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Revenue</p>
              <p className="text-3xl font-bold text-gray-900">${(totalRevenue / 100).toLocaleString()}</p>
            </div>
            <TrendingUp className="h-10 w-10 text-purple-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6 border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Verticals</p>
              <p className="text-3xl font-bold text-gray-900">{templates.length}</p>
            </div>
            <Building2 className="h-10 w-10 text-orange-500" />
          </div>
        </div>
      </div>

      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg shadow-sm p-8 mb-8 text-white">
        <div className="flex items-start justify-between">
          <div>
            <h2 className="text-2xl font-bold mb-2">🚀 Revenue Multiplier Strategy</h2>
            <p className="text-blue-100 mb-4 max-w-2xl">
              Create industry-specific AI companies powered by your 38-bot ecosystem.
              Same technology, different packaging. One platform, unlimited verticals.
            </p>
            <div className="grid grid-cols-3 gap-4 mb-4">
              <div className="bg-white/10 rounded-lg p-4">
                <p className="text-sm text-blue-100">Instead of</p>
                <p className="text-2xl font-bold">1 product</p>
                <p className="text-sm text-blue-100">$99/mo</p>
              </div>
              <div className="flex items-center justify-center">
                <Zap className="h-8 w-8" />
              </div>
              <div className="bg-white/10 rounded-lg p-4">
                <p className="text-sm text-blue-100">You get</p>
                <p className="text-2xl font-bold">10 verticals</p>
                <p className="text-sm text-blue-100">$99-$297/mo each</p>
              </div>
            </div>
            <p className="text-sm text-blue-100">
              Examples: CleanDesk AI, VetDesk AI, HomeDesk AI, PawsDesk AI, LegalDesk AI, FitDesk AI, ConstructDesk AI, BeautyDesk AI
            </p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="flex items-center gap-2 px-6 py-3 bg-white text-blue-600 rounded-lg hover:bg-blue-50 transition font-medium"
          >
            <Plus className="h-5 w-5" />
            Create License
          </button>
        </div>
      </div>

      <div className="mb-8">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Available Vertical Templates</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {templates.map(template => {
            const licensesCount = licenses.filter(l => l.vertical_template_id === template.id).length;
            const activeLicensesCount = licenses.filter(l => l.vertical_template_id === template.id && l.status === 'active').length;

            return (
              <div
                key={template.id}
                className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition"
              >
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="text-lg font-bold text-gray-900">{template.name}</h3>
                    <p className="text-sm text-gray-600">{template.industry}</p>
                  </div>
                  <span className={`px-2 py-1 text-xs font-medium rounded ${
                    template.enabled
                      ? 'bg-green-100 text-green-700'
                      : 'bg-gray-100 text-gray-600'
                  }`}>
                    {template.enabled ? 'Active' : 'Disabled'}
                  </span>
                </div>

                <p className="text-sm text-gray-700 mb-4 line-clamp-2">{template.description}</p>

                <div className="flex flex-wrap gap-2 mb-4">
                  {template.target_customers.slice(0, 3).map(customer => (
                    <span
                      key={customer}
                      className="px-2 py-1 bg-blue-50 text-blue-700 text-xs rounded"
                    >
                      {customer}
                    </span>
                  ))}
                </div>

                <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                  <div className="text-sm">
                    <p className="text-gray-600">Base Price</p>
                    <p className="font-bold text-gray-900">${(template.base_price_monthly / 100).toFixed(0)}/mo</p>
                  </div>
                  <div className="text-sm text-right">
                    <p className="text-gray-600">Licenses</p>
                    <p className="font-bold text-gray-900">{activeLicensesCount} / {licensesCount}</p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div>
        <h2 className="text-xl font-bold text-gray-900 mb-4">Active Licenses</h2>
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Business</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vertical</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Subdomain</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">MRR</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Workspaces</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Revenue</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {licenses.map(license => (
                <tr key={license.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{license.business_name}</div>
                    <div className="text-xs text-gray-500">{license.license_key}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {getTemplateName(license.vertical_template_id)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm text-blue-600 font-mono">{license.subdomain}.frontdesk.ai</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs font-medium rounded ${
                      license.status === 'active'
                        ? 'bg-green-100 text-green-700'
                        : 'bg-gray-100 text-gray-600'
                    }`}>
                      {license.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    ${(license.mrr_contribution / 100).toFixed(0)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {license.total_workspaces}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">
                    ${(license.total_revenue / 100).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {licenses.length === 0 && (
            <div className="text-center py-12">
              <Package className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600">No licenses created yet</p>
              <button
                onClick={() => setShowCreateModal(true)}
                className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
              >
                Create First License
              </button>
            </div>
          )}
        </div>
      </div>

      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full p-6">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-gray-900">Create New Vertical License</h3>
              <button
                onClick={() => setShowCreateModal(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Select Vertical Template
                </label>
                <select
                  value={selectedTemplate}
                  onChange={(e) => setSelectedTemplate(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="">Choose a vertical...</option>
                  {templates.map(template => (
                    <option key={template.id} value={template.id}>
                      {template.name} - {template.industry} (${(template.base_price_monthly / 100)}/mo)
                    </option>
                  ))}
                </select>
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <p className="text-sm text-blue-800">
                  <strong>Note:</strong> Creating a license will generate a unique license key and subdomain.
                  The licensee will be able to customize branding, configure bots, and manage their own customers.
                </p>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition"
                >
                  Cancel
                </button>
                <button
                  disabled={!selectedTemplate}
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Create License
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
