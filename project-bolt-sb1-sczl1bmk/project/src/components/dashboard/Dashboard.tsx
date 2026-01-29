import React, { useEffect, useState } from 'react'
import { useAuth } from '../../lib/auth'
import { getUserSubscription } from '../../lib/stripe'
import { getProductByPriceId } from '../../stripe-config'
import { Button } from '../ui/Button'
import { Alert } from '../ui/Alert'
import { User, CreditCard, Settings, LogOut } from 'lucide-react'

export function Dashboard() {
  const { user, signOut } = useAuth()
  const [subscription, setSubscription] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    loadSubscription()
  }, [])

  const loadSubscription = async () => {
    try {
      const data = await getUserSubscription()
      setSubscription(data)
    } catch (err: any) {
      setError(err.message || 'Failed to load subscription')
    } finally {
      setLoading(false)
    }
  }

  const getSubscriptionStatus = () => {
    if (!subscription) return 'No active subscription'
    
    const product = getProductByPriceId(subscription.price_id)
    if (product) {
      return `${product.name} - ${subscription.subscription_status}`
    }
    
    return `Active subscription - ${subscription.subscription_status}`
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-purple-950 to-black">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-900/50 to-fuchsia-900/50 backdrop-blur-md shadow-lg border-b border-purple-500/30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-2xl font-bold text-white">FrontDesk AI Pro</h1>
              <p className="text-purple-200">Welcome back, {user?.email}</p>
            </div>
            <Button onClick={signOut} variant="outline">
              <LogOut className="h-4 w-4 mr-2" />
              Sign Out
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {error && (
          <div className="mb-6">
            <Alert type="error">{error}</Alert>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Account Info */}
          <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md rounded-lg shadow-lg border border-purple-500/30 p-6">
            <div className="flex items-center mb-4">
              <User className="h-5 w-5 text-cyan-400 mr-2" />
              <h2 className="text-lg font-medium text-white">Account</h2>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-purple-300">Email</p>
              <p className="font-medium text-white">{user?.email}</p>
            </div>
          </div>

          {/* Subscription Info */}
          <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md rounded-lg shadow-lg border border-purple-500/30 p-6">
            <div className="flex items-center mb-4">
              <CreditCard className="h-5 w-5 text-cyan-400 mr-2" />
              <h2 className="text-lg font-medium text-white">Subscription</h2>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-purple-300">Status</p>
              {loading ? (
                <p className="text-sm text-purple-400">Loading...</p>
              ) : (
                <p className="font-medium text-white">{getSubscriptionStatus()}</p>
              )}
            </div>
          </div>

          {/* Quick Actions */}
          <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md rounded-lg shadow-lg border border-purple-500/30 p-6">
            <div className="flex items-center mb-4">
              <Settings className="h-5 w-5 text-cyan-400 mr-2" />
              <h2 className="text-lg font-medium text-white">Quick Actions</h2>
            </div>
            <div className="space-y-3">
              <Button variant="outline" className="w-full justify-start">
                View Billing
              </Button>
              <Button variant="outline" className="w-full justify-start">
                Manage Subscription
              </Button>
              <Button variant="outline" className="w-full justify-start">
                Support
              </Button>
            </div>
          </div>
        </div>

        {/* Main Dashboard Content */}
        <div className="mt-8">
          <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md rounded-lg shadow-lg border border-purple-500/30">
            <div className="px-6 py-4 border-b border-purple-500/30">
              <h2 className="text-lg font-medium text-white">Dashboard</h2>
            </div>
            <div className="p-6">
              <div className="text-center py-12">
                <h3 className="text-lg font-medium text-white mb-2">
                  Welcome to FrontDesk AI Pro
                </h3>
                <p className="text-purple-200 mb-6">
                  Your AI-powered business assistant is ready to help you automate and grow your business.
                </p>
                {!subscription && (
                  <Button onClick={() => window.location.href = '/pricing'}>
                    Choose a Plan
                  </Button>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}