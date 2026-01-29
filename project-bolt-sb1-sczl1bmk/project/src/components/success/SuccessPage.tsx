import { CheckCircle } from 'lucide-react'
import { Button } from '../ui/Button'

export function SuccessPage() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-6 shadow rounded-lg text-center">
          <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100 mb-4">
            <CheckCircle className="h-6 w-6 text-green-600" />
          </div>
          
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Payment Successful!
          </h2>
          
          <p className="text-gray-600 mb-6">
            Thank you for your purchase. Your subscription has been activated and you can now access all features.
          </p>
          
          <div className="space-y-3">
            <Button 
              onClick={() => window.location.href = '/dashboard'}
              className="w-full"
            >
              Go to Dashboard
            </Button>
            
            <Button 
              onClick={() => window.location.href = '/pricing'}
              variant="outline"
              className="w-full"
            >
              View More Plans
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}