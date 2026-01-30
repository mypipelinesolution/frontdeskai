import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useWorkspace } from '../hooks/useWorkspace';
import { SubscriptionStatus } from '../components/SubscriptionStatus';
import { Button } from '../components/ui/Button';
import { 
  MessageSquare, 
  Users, 
  Calendar,
  Bot,
  TrendingUp,
  Zap,
  Phone,
  Mail,
  CheckCircle,
  ArrowRight,
  Lock
} from 'lucide-react';

const DashboardPage = () => {
  const navigate = useNavigate();
  const { user, signOut } = useAuth();
  const { workspace, loading } = useWorkspace();

  const stats = [
    { name: 'Total Conversations', value: '2,847', icon: MessageSquare, change: '+12%' },
    { name: 'Leads Captured', value: '342', icon: Users, change: '+8%' },
    { name: 'Appointments Booked', value: '89', icon: Calendar, change: '+23%' },
    { name: 'Response Rate', value: '94%', icon: TrendingUp, change: '+2%' },
  ];

  const availableFeatures = [
    { name: '24/7 AI Chat & SMS', icon: MessageSquare, description: 'Never miss a lead with instant responses' },
    { name: 'Smart Booking System', icon: Calendar, description: 'Automated appointment scheduling' },
    { name: 'Call Answering', icon: Phone, description: 'AI answers calls when you\'re busy' },
    { name: 'Email Campaigns', icon: Mail, description: 'Automated follow-up sequences' },
    { name: 'Lead Intelligence', icon: Users, description: 'Track and qualify every lead' },
    { name: 'Multi-Channel Automation', icon: Zap, description: 'Coordinate across all channels' },
  ];

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <Bot className="w-12 h-12 text-blue-600 mx-auto mb-4 animate-pulse" />
          <p className="text-gray-600">Loading your dashboard...</p>
        </div>
      </div>
    );
  }

  // No workspace = no payment yet
  const hasActiveSubscription = workspace && workspace.stripe_subscription_id;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center cursor-pointer" onClick={() => navigate('/')}>
              <Bot className="w-8 h-8 text-blue-600 mr-3" />
              <h1 className="text-xl font-semibold text-gray-900">FrontDesk AI Pro</h1>
            </div>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-gray-700">Welcome, {user?.email}</span>
              <button
                onClick={signOut}
                className="text-sm text-gray-500 hover:text-gray-700"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {hasActiveSubscription ? (
          // ACTIVE SUBSCRIPTION VIEW - Full Dashboard
          <>
            <SubscriptionStatus />

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              {stats.map((stat) => (
                <div key={stat.name} className="bg-white rounded-lg shadow p-6">
                  <div className="flex items-center">
                    <div className="flex-shrink-0">
                      <stat.icon className="h-8 w-8 text-blue-600" />
                    </div>
                    <div className="ml-5 w-0 flex-1">
                      <dl>
                        <dt className="text-sm font-medium text-gray-500 truncate">
                          {stat.name}
                        </dt>
                        <dd className="flex items-baseline">
                          <div className="text-2xl font-semibold text-gray-900">
                            {stat.value}
                          </div>
                          <div className="ml-2 flex items-baseline text-sm font-semibold text-green-600">
                            {stat.change}
                          </div>
                        </dd>
                      </dl>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Quick Actions */}
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Button onClick={() => navigate('/app/conversations')}>
                  View Conversations
                </Button>
                <Button onClick={() => navigate('/app/bots')} variant="outline">
                  Manage Bots
                </Button>
                <Button onClick={() => navigate('/pricing')} variant="outline">
                  Upgrade Plan
                </Button>
              </div>
            </div>
          </>
        ) : (
          // NO SUBSCRIPTION VIEW - Feature Preview
          <>
            <div className="bg-gradient-to-r from-blue-600 to-indigo-600 rounded-2xl shadow-xl p-8 mb-8 text-white">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-3xl font-bold mb-2">Welcome to FrontDesk AI Pro!</h2>
                  <p className="text-blue-100 text-lg">
                    You're one step away from automating your business with AI
                  </p>
                </div>
                <Lock className="w-16 h-16 text-blue-200 opacity-50" />
              </div>
            </div>

            {/* Available Features Preview */}
            <div className="mb-8">
              <h3 className="text-2xl font-bold text-gray-900 mb-6">
                Features You'll Get Access To:
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {availableFeatures.map((feature) => (
                  <div key={feature.name} className="bg-white rounded-lg shadow-lg p-6 border-2 border-gray-100 hover:border-blue-500 transition-colors">
                    <div className="flex items-start">
                      <div className="flex-shrink-0">
                        <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                          <feature.icon className="h-6 w-6 text-blue-600" />
                        </div>
                      </div>
                      <div className="ml-4">
                        <h4 className="text-lg font-semibold text-gray-900 mb-1">
                          {feature.name}
                        </h4>
                        <p className="text-sm text-gray-600">
                          {feature.description}
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* CTA Section */}
            <div className="bg-white rounded-2xl shadow-xl p-8 border-2 border-blue-200">
              <div className="text-center max-w-2xl mx-auto">
                <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
                <h3 className="text-2xl font-bold text-gray-900 mb-4">
                  Ready to Activate Your AI Front Desk?
                </h3>
                <p className="text-gray-600 mb-6 text-lg">
                  Choose a plan and start automating your business today. Cancel anytime.
                </p>
                <div className="flex flex-col sm:flex-row gap-4 justify-center">
                  <Button
                    size="lg"
                    onClick={() => navigate('/pricing')}
                    className="text-lg px-8"
                  >
                    View Pricing Plans
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Button>
                  <Button
                    size="lg"
                    variant="outline"
                    onClick={() => navigate('/webinar')}
                    className="text-lg px-8"
                  >
                    Watch Demo First
                  </Button>
                </div>
                <p className="text-sm text-gray-500 mt-4">
                  Plans start at $104/month • No contracts • Cancel anytime
                </p>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default DashboardPage;