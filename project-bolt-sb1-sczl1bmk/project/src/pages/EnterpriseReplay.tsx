import { useState, useEffect } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { CheckCircle2, Clock, Lock, AlertCircle } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { supabase } from '../lib/supabase';

export default function EnterpriseReplay() {
  const [searchParams] = useSearchParams();
  const [tokenStatus, setTokenStatus] = useState<'loading' | 'valid' | 'invalid' | 'expired'>('loading');
  const [leadData, setLeadData] = useState<any>(null);
  const [watchProgress, setWatchProgress] = useState(0);
  const [tokenExpiry, setTokenExpiry] = useState<Date | null>(null);

  useEffect(() => {
    const token = searchParams.get('t');
    if (!token) {
      setTokenStatus('invalid');
      return;
    }

    verifyToken(token);
  }, [searchParams]);

  const verifyToken = async (token: string) => {
    try {
      const { data: tokenData, error } = await supabase
        .from('enterprise_access_tokens')
        .select(`
          *,
          enterprise_leads (*)
        `)
        .eq('token', token)
        .gt('expires_at', new Date().toISOString())
        .single();

      if (error || !tokenData) {
        setTokenStatus(tokenData ? 'expired' : 'invalid');
        return;
      }

      setTokenStatus('valid');
      setLeadData(tokenData.enterprise_leads);
      setTokenExpiry(new Date(tokenData.expires_at));

      await supabase
        .from('enterprise_access_tokens')
        .update({
          last_accessed_at: new Date().toISOString(),
          access_count: (tokenData.access_count || 0) + 1,
        })
        .eq('id', tokenData.id);

      const { data: viewData } = await supabase
        .from('enterprise_webinar_views')
        .select('*')
        .eq('lead_id', tokenData.lead_id)
        .eq('token_id', tokenData.id)
        .single();

      if (viewData) {
        setWatchProgress(viewData.completion_percentage || 0);
      } else {
        await supabase.from('enterprise_webinar_views').insert({
          lead_id: tokenData.lead_id,
          token_id: tokenData.id,
          webinar_type: 'main_demo',
        });
      }
    } catch (error) {
      console.error('Token verification error:', error);
      setTokenStatus('invalid');
    }
  };

  const handleCTAClick = async (ctaType: string) => {
    const token = searchParams.get('t');
    if (!token || !leadData) return;

    const { data: tokenData } = await supabase
      .from('enterprise_access_tokens')
      .select('id, lead_id')
      .eq('token', token)
      .single();

    if (tokenData) {
      const { data: viewData } = await supabase
        .from('enterprise_webinar_views')
        .select('*')
        .eq('lead_id', tokenData.lead_id)
        .eq('token_id', tokenData.id)
        .single();

      if (viewData) {
        const clicks = viewData.cta_clicks || [];
        clicks.push({ type: ctaType, timestamp: new Date().toISOString() });

        await supabase
          .from('enterprise_webinar_views')
          .update({ cta_clicks: clicks })
          .eq('id', viewData.id);
      }
    }
  };

  if (tokenStatus === 'loading') {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-slate-600">Verifying your access...</p>
        </div>
      </div>
    );
  }

  if (tokenStatus === 'invalid') {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="max-w-md mx-auto text-center p-8">
          <div className="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Lock className="w-12 h-12 text-red-600" />
          </div>
          <h1 className="text-3xl font-bold mb-4">Invalid Access Link</h1>
          <p className="text-slate-600 mb-6">
            This replay link is not valid. Please register to receive your personal access link.
          </p>
          <Link to="/enterprise">
            <Button>Register for Access</Button>
          </Link>
        </div>
      </div>
    );
  }

  if (tokenStatus === 'expired') {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center">
        <div className="max-w-md mx-auto text-center p-8">
          <div className="w-20 h-20 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <Clock className="w-12 h-12 text-orange-600" />
          </div>
          <h1 className="text-3xl font-bold mb-4">Link Expired</h1>
          <p className="text-slate-600 mb-6">
            Your replay access has expired. Register again to receive a new access link.
          </p>
          <Link to="/enterprise">
            <Button>Get New Access Link</Button>
          </Link>
        </div>
      </div>
    );
  }

  const daysRemaining = tokenExpiry
    ? Math.ceil((tokenExpiry.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24))
    : 0;

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="bg-blue-600 text-white py-3">
        <div className="container mx-auto px-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Clock className="w-5 h-5" />
            <span className="text-sm">
              Access expires in <strong>{daysRemaining} day{daysRemaining !== 1 ? 's' : ''}</strong>
            </span>
          </div>
          {leadData?.partner_slug && (
            <div className="text-sm opacity-80">
              Partner: {leadData.partner_slug}
            </div>
          )}
        </div>
      </div>

      <div className="container mx-auto px-4 py-12">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold mb-4">
              Enterprise Demo Replay
            </h1>
            <p className="text-xl text-slate-600">
              Welcome back, {leadData?.name || 'there'}! Watch the full 45-minute platform demo.
            </p>
          </div>

          {watchProgress > 0 && (
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div>
                  <div className="font-semibold text-blue-900 mb-1">Resume where you left off</div>
                  <div className="text-sm text-blue-700">
                    You've watched {watchProgress}% of the demo
                  </div>
                  <div className="mt-2 bg-blue-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full transition-all"
                      style={{ width: `${watchProgress}%` }}
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          <div className="bg-white rounded-xl shadow-xl overflow-hidden mb-8">
            <div className="aspect-video bg-slate-900 flex items-center justify-center">
              <div className="text-center text-white p-8">
                <p className="text-xl mb-4">Enterprise Demo Video Player</p>
                <p className="text-slate-400">
                  [Video player would be embedded here - YouTube, Vimeo, or custom player]
                </p>
                <p className="text-sm text-slate-500 mt-4">
                  Showing: Full Platform Walkthrough (45 minutes)
                </p>
              </div>
            </div>

            <div className="p-6 bg-slate-50 border-t border-slate-200">
              <h3 className="font-bold mb-2">What You'll See:</h3>
              <ul className="grid md:grid-cols-2 gap-2 text-sm text-slate-600">
                <li>• Platform Architecture Overview</li>
                <li>• 40+ AI Bot Ecosystem Demo</li>
                <li>• White-Label Branding System</li>
                <li>• Multi-Client Management</li>
                <li>• Revenue Model Breakdown</li>
                <li>• Real Customer Case Studies</li>
                <li>• Implementation Timeline</li>
                <li>• Pricing & Tier Comparison</li>
              </ul>
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-6 mb-8">
            <Link
              to="/enterprise/offer"
              onClick={() => handleCTAClick('view_offer')}
              className="block"
            >
              <div className="bg-blue-600 text-white rounded-xl p-8 hover:bg-blue-700 transition-colors cursor-pointer h-full">
                <h3 className="text-2xl font-bold mb-3">View Enterprise Tiers</h3>
                <p className="mb-4">
                  See detailed pricing for Regional, Agency, and Custom tiers
                </p>
                <div className="flex items-center gap-2 text-blue-100">
                  <span className="font-semibold">View Pricing</span>
                  <span>→</span>
                </div>
              </div>
            </Link>

            <Link
              to="/enterprise/apply"
              onClick={() => handleCTAClick('apply')}
              className="block"
            >
              <div className="bg-green-600 text-white rounded-xl p-8 hover:bg-green-700 transition-colors cursor-pointer h-full">
                <h3 className="text-2xl font-bold mb-3">Apply for Enterprise</h3>
                <p className="mb-4">
                  Start your application and schedule a strategy call
                </p>
                <div className="flex items-center gap-2 text-green-100">
                  <span className="font-semibold">Apply Now</span>
                  <span>→</span>
                </div>
              </div>
            </Link>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-8">
            <h2 className="text-2xl font-bold mb-6">What Happens Next</h2>
            <div className="space-y-4">
              <div className="flex gap-4">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="font-bold text-blue-600">1</span>
                </div>
                <div>
                  <h3 className="font-bold mb-1">Watch the Full Demo</h3>
                  <p className="text-slate-600">Take your time understanding the platform capabilities</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="font-bold text-blue-600">2</span>
                </div>
                <div>
                  <h3 className="font-bold mb-1">Review Pricing Options</h3>
                  <p className="text-slate-600">Choose the tier that fits your business size</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="font-bold text-blue-600">3</span>
                </div>
                <div>
                  <h3 className="font-bold mb-1">Submit Your Application</h3>
                  <p className="text-slate-600">Tell us about your business and goals</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="font-bold text-blue-600">4</span>
                </div>
                <div>
                  <h3 className="font-bold mb-1">Strategy Call</h3>
                  <p className="text-slate-600">We'll review your fit and answer questions</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                  <CheckCircle2 className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h3 className="font-bold mb-1">Launch Your Platform</h3>
                  <p className="text-slate-600">Go live in 30 days with your branded AI system</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
