import { useState, useEffect } from 'react';
import { supabase, Workspace } from '../../lib/supabase';
import { Code, Copy, CheckCircle, Eye } from 'lucide-react';

export function WidgetSettings({ workspace }: { workspace: Workspace }) {
  const [settings, setSettings] = useState({
    theme: 'blue',
    position: 'bottom-right',
    greeting: 'Hi! How can we help you today?',
  });
  const [copied, setCopied] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (workspace.widget_settings) {
      const ws = workspace.widget_settings as any;
      setSettings({
        theme: ws.theme || 'blue',
        position: ws.position || 'bottom-right',
        greeting: ws.greeting || 'Hi! How can we help you today?',
      });
    }
  }, [workspace]);

  const handleSave = async () => {
    setSaving(true);
    await supabase
      .from('workspaces')
      .update({ widget_settings: settings })
      .eq('id', workspace.id);
    setSaving(false);
  };

  const embedCode = `<script
  src="${import.meta.env.VITE_APP_URL}/widget.js"
  data-workspace-id="${workspace.id}"
  data-theme="${settings.theme}"
  data-position="${settings.position}"
  data-greeting="${settings.greeting}"
></script>`;

  const handleCopy = () => {
    navigator.clipboard.writeText(embedCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-slate-900">Chat Widget</h1>
        <p className="text-slate-600 mt-1">Customize and embed your AI chatbot</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-6">
          <div className="bg-white rounded-xl shadow-sm p-6 border border-slate-200">
            <h2 className="text-xl font-bold text-slate-900 mb-4">Widget Settings</h2>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">
                  Theme Color
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {['blue', 'green', 'purple', 'orange'].map((color) => (
                    <button
                      key={color}
                      onClick={() => setSettings({ ...settings, theme: color })}
                      className={`px-4 py-2 rounded-lg border-2 transition ${
                        settings.theme === color
                          ? 'border-slate-900 bg-slate-50'
                          : 'border-slate-200 hover:border-slate-300'
                      }`}
                    >
                      <div className={`w-6 h-6 rounded-full mx-auto bg-${color}-500`}></div>
                      <span className="text-xs mt-1 block capitalize">{color}</span>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">
                  Position
                </label>
                <select
                  value={settings.position}
                  onChange={(e) => setSettings({ ...settings, position: e.target.value })}
                  className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                >
                  <option value="bottom-right">Bottom Right</option>
                  <option value="bottom-left">Bottom Left</option>
                  <option value="top-right">Top Right</option>
                  <option value="top-left">Top Left</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-2">
                  Greeting Message
                </label>
                <textarea
                  value={settings.greeting}
                  onChange={(e) => setSettings({ ...settings, greeting: e.target.value })}
                  className="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                  rows={2}
                  placeholder="Hi! How can we help you today?"
                />
              </div>

              <button
                onClick={handleSave}
                disabled={saving}
                className="w-full px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition disabled:opacity-50"
              >
                {saving ? 'Saving...' : 'Save Settings'}
              </button>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-sm p-6 border border-slate-200">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Code className="w-5 h-5 text-slate-700" />
                <h2 className="text-xl font-bold text-slate-900">Embed Code</h2>
              </div>
              <button
                onClick={handleCopy}
                className="flex items-center gap-2 px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition text-sm"
              >
                {copied ? (
                  <>
                    <CheckCircle className="w-4 h-4" />
                    Copied!
                  </>
                ) : (
                  <>
                    <Copy className="w-4 h-4" />
                    Copy Code
                  </>
                )}
              </button>
            </div>

            <div className="bg-slate-900 rounded-lg p-4 overflow-x-auto">
              <pre className="text-green-400 text-xs font-mono">{embedCode}</pre>
            </div>

            <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
              <h3 className="font-semibold text-blue-900 mb-2">Installation Instructions</h3>
              <ol className="text-sm text-blue-800 space-y-1 list-decimal list-inside">
                <li>Copy the embed code above</li>
                <li>Paste it before the closing &lt;/body&gt; tag on your website</li>
                <li>The chat widget will appear on all pages</li>
                <li>Leads will be captured automatically in your inbox</li>
              </ol>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6 border border-slate-200">
          <div className="flex items-center gap-2 mb-4">
            <Eye className="w-5 h-5 text-slate-700" />
            <h2 className="text-xl font-bold text-slate-900">Live Preview</h2>
          </div>

          <div className="border-2 border-slate-200 rounded-lg p-8 bg-slate-50 min-h-[500px] relative">
            <div className="text-center text-slate-500 mb-4">
              <p className="text-sm">Preview of how your widget will appear</p>
            </div>

            <div
              className="absolute"
              style={{
                [settings.position.includes('right') ? 'right' : 'left']: '20px',
                [settings.position.includes('bottom') ? 'bottom' : 'top']: '20px',
              }}
            >
              <div
                className="w-14 h-14 rounded-full shadow-lg flex items-center justify-center cursor-pointer"
                style={{
                  backgroundColor:
                    settings.theme === 'blue' ? '#3b82f6' :
                    settings.theme === 'green' ? '#10b981' :
                    settings.theme === 'purple' ? '#8b5cf6' :
                    '#f97316',
                }}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="white"
                  className="w-7 h-7"
                >
                  <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/>
                </svg>
              </div>
            </div>
          </div>

          <div className="mt-4 p-4 bg-green-50 rounded-lg border border-green-200">
            <h3 className="font-semibold text-green-900 mb-2">Widget Features</h3>
            <ul className="text-sm text-green-800 space-y-1">
              <li>✓ AI-powered responses 24/7</li>
              <li>✓ Automatic lead capture</li>
              <li>✓ Conversation history saved</li>
              <li>✓ Mobile responsive design</li>
              <li>✓ Customizable appearance</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
