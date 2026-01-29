import React, { useState } from 'react'
import { useAuth } from '../../lib/auth'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Alert } from '../ui/Alert'

interface LoginFormProps {
  onSwitchToSignup: () => void
}

export function LoginForm({ onSwitchToSignup }: LoginFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const { signIn } = useAuth()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const { error } = await signIn(email, password)
    
    if (error) {
      setError(error.message)
    }
    
    setLoading(false)
  }

  return (
    <div className="max-w-md mx-auto">
      <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md py-8 px-6 shadow-xl rounded-lg border border-purple-500/30">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-white">Sign In</h2>
          <p className="mt-2 text-sm text-purple-200">
            Welcome back to FrontDesk AI Pro
          </p>
        </div>

        {error && (
          <div className="mb-4">
            <Alert type="error">{error}</Alert>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoComplete="email"
          />

          <Input
            label="Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            autoComplete="current-password"
          />

          <Button
            type="submit"
            className="w-full"
            loading={loading}
          >
            Sign In
          </Button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-purple-200">
            Don't have an account?{' '}
            <button
              onClick={onSwitchToSignup}
              className="font-medium text-cyan-400 hover:text-cyan-300"
            >
              Sign up
            </button>
          </p>
        </div>
      </div>
    </div>
  )
}