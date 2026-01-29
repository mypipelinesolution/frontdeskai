import React, { useState, useEffect, useRef } from 'react';
import { X, Send, Minimize2, Maximize2 } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

interface DemoChatProps {
  userName: string;
  userEmail: string;
  onClose: () => void;
}

export default function DemoChat({ userName, userEmail, onClose }: DemoChatProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [isMinimized, setIsMinimized] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const welcomeMessage: Message = {
      id: '1',
      role: 'assistant',
      content: `Hi ${userName}! 👋 I'm your AI Demo Guide. I'm excited to show you how FrontDesk AI Pro can transform your business with our 38-bot AI workforce!\n\nI can walk you through:\n• How our AI bots work 24/7 to capture leads\n• Live appointment booking\n• Automated follow-ups\n• Sales automation\n• And much more!\n\nWhat would you like to learn about first?`,
      timestamp: new Date(),
    };
    setMessages([welcomeMessage]);
  }, [userName]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  async function sendMessage(e: React.FormEvent) {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/ai-chat`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          },
          body: JSON.stringify({
            message: input,
            context: {
              mode: 'demo',
              botType: 'webinar_host',
              userName,
              userEmail,
              conversationHistory: messages.slice(-5).map((m) => ({
                role: m.role,
                content: m.content,
              })),
            },
          }),
        }
      );

      if (response.ok) {
        const data = await response.json();
        const assistantMessage: Message = {
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: data.response || "I'd love to tell you more! What specific features interest you?",
          timestamp: new Date(),
        };
        setMessages((prev) => [...prev, assistantMessage]);
      } else {
        throw new Error('Failed to get response');
      }
    } catch (error) {
      console.error('Chat error:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: "I'm here to help! Let me tell you about our key features:\n\n✅ 24/7 Lead Capture - Never miss another customer\n✅ Smart Appointment Booking - Syncs with your calendar\n✅ Automated Follow-ups - Keep leads engaged\n✅ Sales Automation - Close more deals\n\nWhat would you like to explore?",
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  }

  if (isMinimized) {
    return (
      <div className="fixed bottom-6 right-6 z-50">
        <button
          onClick={() => setIsMinimized(false)}
          className="bg-gradient-to-r from-purple-600 to-green-500 text-white px-6 py-3 rounded-full shadow-2xl hover:shadow-green-500/50 transition flex items-center gap-2 font-semibold"
        >
          <Maximize2 className="w-5 h-5" />
          Continue Demo Chat
        </button>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
      <div className="bg-slate-900 rounded-2xl shadow-2xl w-full max-w-2xl h-[600px] flex flex-col border border-purple-500/30">
        <div className="bg-gradient-to-r from-purple-600 to-green-500 p-4 rounded-t-2xl flex items-center justify-between">
          <div>
            <h3 className="text-white font-bold text-lg">FrontDesk AI Pro Demo</h3>
            <p className="text-white/80 text-sm">AI Webinar Host Bot</p>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setIsMinimized(true)}
              className="p-2 hover:bg-white/20 rounded-lg transition"
            >
              <Minimize2 className="w-5 h-5 text-white" />
            </button>
            <button
              onClick={onClose}
              className="p-2 hover:bg-white/20 rounded-lg transition"
            >
              <X className="w-5 h-5 text-white" />
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                  message.role === 'user'
                    ? 'bg-gradient-to-r from-purple-600 to-green-500 text-white'
                    : 'bg-slate-800 text-white border border-purple-500/20'
                }`}
              >
                <p className="text-sm whitespace-pre-wrap leading-relaxed">{message.content}</p>
                <p className="text-xs opacity-60 mt-1">
                  {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </p>
              </div>
            </div>
          ))}
          {loading && (
            <div className="flex justify-start">
              <div className="bg-slate-800 text-white border border-purple-500/20 rounded-2xl px-4 py-3">
                <div className="flex gap-1">
                  <span className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                  <span className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                  <span className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                </div>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        <div className="p-4 border-t border-slate-800">
          <form onSubmit={sendMessage} className="flex gap-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask me anything about FrontDesk AI..."
              className="flex-1 bg-slate-800 border border-purple-500/20 rounded-xl px-4 py-3 text-white placeholder-slate-400 focus:outline-none focus:border-purple-500/50"
              disabled={loading}
            />
            <button
              type="submit"
              disabled={loading || !input.trim()}
              className="bg-gradient-to-r from-purple-600 to-green-500 text-white px-6 py-3 rounded-xl font-semibold hover:opacity-90 disabled:opacity-50 transition flex items-center gap-2"
            >
              <Send className="w-5 h-5" />
            </button>
          </form>
          <div className="mt-3 flex items-center justify-between text-xs text-slate-400">
            <p>Powered by AI Webinar Host Bot (Bot A1)</p>
            <button
              onClick={() => window.location.href = '/pricing'}
              className="text-green-400 hover:text-green-300 font-semibold"
            >
              View Pricing →
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
