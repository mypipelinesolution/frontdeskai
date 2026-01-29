import React from 'react';
import { useAuth } from '../hooks/useAuth';
import SubscriptionStatus from '../components/SubscriptionStatus';
import { 
  BarChart3, 
  MessageSquare, 
  Users, 
  Calendar,
  Settings,
  Bot,
  Phone,
  Mail,
  TrendingUp
} from 'lucide-react';

const DashboardPage: React.FC = () => {
  const { user, signOut } = useAuth();

  const stats = [
    { name: 'Total Conversations', value: '2,847', icon: MessageSquare, change: '+12%' },
    { name: 'Leads Captured', value: '342', icon: Users, change: '+8%' },
    { name: 'Appointments Booked', value: '89', icon: Calendar, change: '+23%' },
    { name: 'Response Rate', value: '94%', icon: TrendingUp, change: '+2%' },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
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
        {/* Subscription Status */}
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
      </div>
    </div>
  );
};

export default DashboardPage;