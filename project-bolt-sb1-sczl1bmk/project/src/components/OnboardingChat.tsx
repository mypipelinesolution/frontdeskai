import React, { useState, useRef, useEffect } from 'react';
import { X, Send, Bot, Loader2 } from 'lucide-react';

interface OnboardingChatProps {
  workspaceId: string;
  userName: string;
  onComplete: () => void;
}

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

const OnboardingChat: React.FC<OnboardingChatProps> = ({ workspaceId, userName, onComplete }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [trainingComplete, setTrainingComplete] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    const startConversation = async () => {
      setLoading(true);
      try {
        const response = await fetch(
          `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/onboarding-bot`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
            },
            body: JSON.stringify({
              workspaceId,
              userName,
              message: 'Hello',
              conversationHistory: [],
            }),
          }
        );

        const data = await response.json();
        setMessages([{ role: 'assistant', content: data.response }]);
      } catch (error) {
        console.error('Error starting onboarding:', error);
        setMessages([{
          role: 'assistant',
          content: "Hi! I'm your AI Setup Bot. Let me learn about your business so I can train your AI team. What type of business are you in?"
        }]);
      } finally {
        setLoading(false);
      }
    };

    startConversation();
  }, [workspaceId, userName]);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || loading) return;

    const userMessage = input.trim();
    setInput('');
    setMessages(prev => [...prev, { role: 'user', content: userMessage }]);
    setLoading(true);

    try {
      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/onboarding-bot`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
          },
          body: JSON.stringify({
            workspaceId,
            userName,
            message: userMessage,
            conversationHistory: messages,
          }),
        }
      );

      const data = await response.json();
      setMessages(prev => [...prev, { role: 'assistant', content: data.response }]);

      if (data.trainingComplete) {
        setTrainingComplete(true);
        setTimeout(() => {
          onComplete();
        }, 3000);
      }
    } catch (error) {
      console.error('Error sending message:', error);
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: 'Sorry, I had trouble processing that. Could you try again?'
      }]);
    } finally {
      setLoading(false);
      setTimeout(() => inputRef.current?.focus(), 100);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl h-[600px] flex flex-col">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-6 py-4 rounded-t-2xl flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
              <Bot className="w-6 h-6" />
            </div>
            <div>
              <h3 className="font-bold text-lg">AI Setup Bot</h3>
              <p className="text-xs text-blue-100">Training your AI team...</p>
            </div>
          </div>
          {trainingComplete && (
            <div className="text-sm bg-green-500 px-3 py-1 rounded-full">
              ✓ Training Complete
            </div>
          )}
        </div>

        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {messages.map((msg, idx) => (
            <div
              key={idx}
              className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-3 ${
                  msg.role === 'user'
                    ? 'bg-blue-600 text-white'
                    : 'bg-slate-100 text-slate-900'
                }`}
              >
                <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
              </div>
            </div>
          ))}
          {loading && (
            <div className="flex justify-start">
              <div className="bg-slate-100 rounded-2xl px-4 py-3">
                <Loader2 className="w-5 h-5 animate-spin text-slate-600" />
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        <form onSubmit={sendMessage} className="p-4 border-t border-slate-200">
          <div className="flex gap-2">
            <input
              ref={inputRef}
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={trainingComplete ? "Training complete!" : "Type your response..."}
              disabled={loading || trainingComplete}
              className="flex-1 px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none disabled:bg-slate-100 disabled:cursor-not-allowed"
            />
            <button
              type="submit"
              disabled={loading || !input.trim() || trainingComplete}
              className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
            >
              <Send className="w-5 h-5" />
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default OnboardingChat;
