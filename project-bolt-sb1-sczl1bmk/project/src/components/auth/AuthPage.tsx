import React, { useState } from 'react'
import { LoginForm } from './LoginForm'
import { SignupForm } from './SignupForm'

export function AuthPage() {
  const [isLogin, setIsLogin] = useState(true)

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-purple-950 to-black flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-purple-600/20 via-transparent to-transparent"></div>
      <div className="absolute top-20 right-20 w-96 h-96 bg-purple-600 rounded-full mix-blend-screen filter blur-3xl opacity-20 animate-pulse"></div>
      <div className="absolute bottom-20 left-20 w-96 h-96 bg-cyan-500 rounded-full mix-blend-screen filter blur-3xl opacity-20 animate-pulse" style={{ animationDelay: '2s' }}></div>

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-white">FrontDesk AI Pro</h1>
          <p className="mt-2 text-purple-200">Your 24/7 AI-Powered Business Assistant</p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        {isLogin ? (
          <LoginForm onSwitchToSignup={() => setIsLogin(false)} />
        ) : (
          <SignupForm onSwitchToLogin={() => setIsLogin(true)} />
        )}
      </div>
    </div>
  )
}