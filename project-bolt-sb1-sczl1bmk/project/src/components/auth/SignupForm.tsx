import React, { useState } from 'react'
import { useAuth } from '../../lib/auth'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Alert } from '../ui/Alert'

interface SignupFormProps {
  onSwitchToLogin: () => void
}

export function SignupForm({ onSwitchToLogin }: SignupFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)
  const { signUp } = useAuth()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setSuccess(false)

    if (password !== confirmPassword) {
      setError('Passwords do not match')
      setLoading(false)
      return
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters')
      setLoading(false)
      return
    }

    const { error } = await signUp(email, password)
    
    if (error) {
      setError(error.message)
    } else {
      setSuccess(true)
    }
    
    setLoading(false)
  }

  if (success) {
    return (
      <div className="max-w-md mx-auto">
        <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md py-8 px-6 shadow-xl rounded-lg border border-purple-500/30">
          <Alert type="success" title="Account Created!">
            Your account has been created successfully. You can now sign in.
          </Alert>
          <div className="mt-4">
            <Button onClick={onSwitchToLogin} className="w-full">
              Sign In
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-md mx-auto">
      <div className="bg-gradient-to-br from-purple-900/30 via-fuchsia-900/20 to-purple-900/30 backdrop-blur-md py-8 px-6 shadow-xl rounded-lg border border-purple-500/30">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-white">Create Account</h2>
          <p className="mt-2 text-sm text-purple-200">
            Get started with FrontDesk AI Pro
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
            autoComplete="new-password"
          />

          <Input
            label="Confirm Password"
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            required
            autoComplete="new-password"
          />

          <Button
            type="submit"
            className="w-full"
            loading={loading}
          >
            Create Account
          </Button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-purple-200">
            Already have an account?{' '}
            <button
              onClick={onSwitchToLogin}
              className="font-medium text-cyan-400 hover:text-cyan-300"
            >
              Sign in
            </button>
          </p>
        </div>
      </div>
    </div>
  )
}