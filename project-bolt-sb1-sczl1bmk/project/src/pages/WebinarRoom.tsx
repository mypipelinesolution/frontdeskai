import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Send, Video, Mic, MicOff, MessageCircle, Sparkles, Check } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { getCoreProducts } from '../stripe-config';

interface Message {
  id: string;
  role: 'bot' | 'user';
  content: string;
  timestamp: Date;
}

interface WebinarBooking {
  id: string;
  full_name: string;
  email: string;
  webinar_type: string;
  scheduled_for: string;
  status: string;
}

export function WebinarRoom() {
  const { bookingId } = useParams();
  const navigate = useNavigate();
  const [booking, setBooking] = useState<WebinarBooking | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [webinarStarted, setWebinarStarted] = useState(false);
  const [currentSlide, setCurrentSlide] = useState(0);
  const [showProducts, setShowProducts] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const products = getCoreProducts();

  useEffect(() => {
    loadBooking();
  }, [bookingId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const loadBooking = async () => {
    try {
      const { data, error } = await supabase
        .from('webinar_bookings')
        .select('*')
        .eq('id', bookingId)
        .single();

      if (error) throw error;
      setBooking(data);

      if (data.status === 'pending') {
        await supabase
          .from('webinar_bookings')
          .update({ status: 'live', started_at: new Date().toISOString() })
          .eq('id', bookingId);
      }
    } catch (error) {
      console.error('Error loading booking:', error);
      alert('Failed to load webinar. Please check your booking link.');
    }
  };

  const startWebinar = async () => {
    setWebinarStarted(true);

    const welcomeMessage: Message = {
      id: '1',
      role: 'bot',
      content: `Welcome ${booking?.full_name || 'there'}! I'm your AI Webinar Host Bot - one of the 27 specialized bots you're about to get.\n\nHere's what makes this exciting: You're not just buying software. You're hiring an entire AI team that works 24/7 to capture leads, book appointments, and close sales while you get your life back.\n\nIn this demo, I'll introduce you to your new team:\n✓ Your Front Desk Team (handles all incoming contacts)\n✓ Your Sales & Booking Team (closes deals and fills your calendar)\n✓ Your Operations Team (keeps everything organized)\n✓ Your Growth Team (scales your business on autopilot)\n\nEach bot has one job they do perfectly. Together, they're unstoppable.\n\nFeel free to ask questions anytime. Ready to meet your new team?`,
      timestamp: new Date(),
    };

    setMessages([welcomeMessage]);

    setTimeout(() => {
      advancePresentation();
    }, 8000);
  };

  const advancePresentation = () => {
    const presentations = [
      {
        slide: 1,
        message: "Let me show you the core problem most businesses face: 80% of leads are lost because businesses can't respond fast enough. Our AI responds in under 2 seconds, 24/7. No coffee breaks, no sick days, no holidays.\n\nImagine having a team that works around the clock for you. That's exactly what you're about to get."
      },
      {
        slide: 2,
        message: "Let me introduce you to your new AI team. Think of this as hiring 27 specialists, each with one job they do perfectly:\n\n👋 FRONT DESK TEAM (The First Impression):\n• Chat Reception Bot - Greets every website visitor instantly\n• SMS Responder Bot - Answers texts in seconds\n• Email Handler Bot - Manages all email inquiries\n• Voice Call Bot - Answers your phone 24/7\n\nThese four never let a potential customer slip through. While you're sleeping, they're working."
      },
      {
        slide: 3,
        message: "SALES & BOOKING TEAM (The Closers):\n• Lead Qualifier Bot - Asks the right questions\n• Appointment Booking Bot - Fills your calendar\n• Sales Conversation Bot - Handles objections and closes deals\n• Payment Processor Bot - Collects payments automatically\n• Follow-Up Coordinator Bot - Never lets leads go cold\n\nThese bots work together like a trained sales team. When one identifies a hot lead, the others jump in to close the deal. You just show up to the booked appointments."
      },
      {
        slide: 4,
        message: "OPERATIONS & RETENTION TEAM (The Organizers):\n• CRM Manager Bot - Keeps everything organized\n• Campaign Builder Bot - Creates automated follow-up sequences\n• Review Generator Bot - Gets you 5-star reviews\n• Missed Call Recovery Bot - Texts everyone who didn't reach you\n• Customer Success Bot - Keeps clients happy\n\nThese bots handle all the tedious work. No more manually entering data, chasing reviews, or following up with leads. It all happens automatically."
      },
      {
        slide: 5,
        message: "GROWTH & INTELLIGENCE TEAM (The Strategists):\n• Analytics Bot - Tracks everything and tells you what's working\n• Social Media DM Bot - Responds to Instagram/Facebook messages\n• Webinar Host Bot - Runs automated presentations (like this one!)\n• Workflow Automation Bot - Connects everything together\n• And 8 more specialized bots depending on your industry\n\nHere's what this means for YOU: Imagine getting your evenings back. Your weekends free. No more being chained to your phone. Your AI team handles it all while you focus on what you love."
      },
      {
        slide: 6,
        message: "THE RESULTS:\n\nOur clients report:\n• 3-5x more leads captured (because AI never misses anyone)\n• 60% faster response time (2 seconds vs 2 hours)\n• 40% more appointments booked (bots don't forget to follow up)\n• 25-35% revenue increase in first 90 days\n\nBut here's what they really talk about: Getting their TIME back. One client said, 'It's like I hired a whole team for less than minimum wage.' Another told us, 'I took my first real vacation in 5 years because my bots kept the business running.'\n\nThat's what this is really about - buying back your freedom."
      }
    ];

    if (currentSlide < presentations.length) {
      const nextSlide = presentations[currentSlide];
      const botMessage: Message = {
        id: Date.now().toString(),
        role: 'bot',
        content: nextSlide.message,
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, botMessage]);
      setCurrentSlide(prev => prev + 1);

      if (currentSlide === presentations.length - 1) {
        setTimeout(() => {
          setShowProducts(true);
          const finalMessage: Message = {
            id: (Date.now() + 1).toString(),
            role: 'bot',
            content: "Now, I'd love to show you our pricing options. We have plans for every business size and budget. Which plan interests you the most, or do you have any questions about what you've seen so far?",
            timestamp: new Date(),
          };
          setMessages(prev => [...prev, finalMessage]);
        }, 5000);
      }
    }
  };

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/webinar-bot`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({
          booking_id: bookingId,
          message: input,
          context: {
            current_slide: currentSlide,
            full_name: booking?.full_name,
            webinar_type: booking?.webinar_type,
          }
        }),
      });

      const data = await response.json();

      const botMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'bot',
        content: data.response || "I'm here to help! Could you please rephrase your question?",
        timestamp: new Date(),
      };

      setMessages(prev => [...prev, botMessage]);

      await supabase.from('webinar_interactions').insert({
        booking_id: bookingId,
        message: input,
        response: data.response,
        interaction_type: data.interaction_type || 'question',
      });

    } catch (error) {
      console.error('Error sending message:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'bot',
        content: "I apologize, I'm having trouble connecting. Please try again in a moment.",
        timestamp: new Date(),
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const handleProductClick = async (priceId: string, productName: string) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_SUPABASE_URL}/functions/v1/create-checkout`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ price_id: priceId }),
      });

      const data = await response.json();

      if (data.url) {
        await supabase.from('webinar_conversions').insert({
          booking_id: bookingId,
          product_name: productName,
          price_id: priceId,
          converted: false,
        });

        window.location.href = data.url;
      }
    } catch (error) {
      console.error('Error starting checkout:', error);
      alert('Failed to start checkout. Please try again.');
    }
  };

  if (!booking) {
    return (
      <div className="min-h-screen cosmic-bg flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-cyan-400 mx-auto mb-4"></div>
          <p className="text-purple-200">Loading your webinar...</p>
        </div>
      </div>
    );
  }

  if (!webinarStarted) {
    return (
      <div className="min-h-screen cosmic-bg flex items-center justify-center">
        <div className="max-w-2xl mx-auto px-4">
          <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-12 border border-purple-500/30 text-center">
            <div className="inline-flex items-center justify-center w-24 h-24 bg-gradient-to-br from-purple-600 to-pink-600 rounded-full mb-6">
              <Video className="w-12 h-12 text-white" />
            </div>
            <h1 className="text-3xl font-bold text-white mb-4">
              Your Private Demo is Ready
            </h1>
            <p className="text-purple-200 mb-8 text-lg">
              Welcome {booking.full_name}! Your AI webinar host is ready to present.
              This personalized demo will take about {booking.webinar_type === 'product_demo' ? '15' : booking.webinar_type === 'full_presentation' ? '30' : '45'} minutes.
            </p>
            <button
              onClick={startWebinar}
              className="px-8 py-4 bg-gradient-to-r from-lime-500 via-green-500 to-emerald-600 hover:from-lime-400 hover:via-green-400 hover:to-emerald-500 text-white font-bold text-lg rounded-xl shadow-lg shadow-lime-500/30 transition-all"
            >
              Start Webinar
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen cosmic-bg">
      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-3 gap-6 h-[calc(100vh-8rem)]">
          <div className="lg:col-span-2 flex flex-col">
            <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl border border-purple-500/30 flex-1 flex flex-col">
              <div className="p-6 border-b border-purple-500/30">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse"></div>
                    <span className="text-white font-semibold">Live Presentation</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <Sparkles className="w-5 h-5 text-cyan-400" />
                    <span className="text-purple-200 text-sm">AI Host</span>
                  </div>
                </div>
              </div>

              <div className="flex-1 overflow-y-auto p-6">
                <div className="space-y-6">
                  {messages.map((message) => (
                    <div
                      key={message.id}
                      className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
                    >
                      <div
                        className={`max-w-[80%] rounded-2xl px-6 py-4 ${
                          message.role === 'user'
                            ? 'bg-gradient-to-r from-cyan-600 to-purple-600 text-white'
                            : 'bg-purple-900/50 border border-purple-500/30 text-purple-100'
                        }`}
                      >
                        <p className="whitespace-pre-wrap leading-relaxed">{message.content}</p>
                        <span className="text-xs opacity-70 mt-2 block">
                          {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </div>
                    </div>
                  ))}
                  {loading && (
                    <div className="flex justify-start">
                      <div className="bg-purple-900/50 border border-purple-500/30 rounded-2xl px-6 py-4">
                        <div className="flex gap-2">
                          <div className="w-2 h-2 bg-purple-400 rounded-full animate-bounce"></div>
                          <div className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                          <div className="w-2 h-2 bg-purple-400 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                        </div>
                      </div>
                    </div>
                  )}
                  <div ref={messagesEndRef} />
                </div>
              </div>

              <div className="p-6 border-t border-purple-500/30">
                <div className="flex gap-3">
                  <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                    placeholder="Ask a question or share your thoughts..."
                    className="flex-1 px-4 py-3 bg-purple-900/30 border border-purple-500/30 rounded-xl text-white placeholder-purple-400 focus:outline-none focus:border-cyan-400 transition-colors"
                  />
                  <button
                    onClick={sendMessage}
                    disabled={!input.trim() || loading}
                    className="px-6 py-3 bg-gradient-to-r from-cyan-600 to-purple-600 hover:from-cyan-500 hover:to-purple-500 text-white rounded-xl font-semibold transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Send className="w-5 h-5" />
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-6">
            <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-6 border border-purple-500/30">
              <h3 className="text-white font-bold text-lg mb-4 flex items-center gap-2">
                <MessageCircle className="w-5 h-5 text-cyan-400" />
                About This Demo
              </h3>
              <div className="space-y-3 text-purple-200 text-sm">
                <p>✓ Interactive AI presentation</p>
                <p>✓ Ask questions anytime</p>
                <p>✓ See live examples</p>
                <p>✓ Get personalized answers</p>
                <p>✓ Special webinar pricing</p>
              </div>
            </div>

            {showProducts && (
              <div className="bg-gradient-to-br from-purple-900/50 via-purple-800/40 to-purple-900/50 backdrop-blur-sm rounded-2xl p-6 border border-purple-500/30 flex-1 overflow-y-auto">
                <h3 className="text-white font-bold text-lg mb-4">
                  Choose Your Plan
                </h3>
                <div className="space-y-4">
                  {products.map((product) => (
                    <div
                      key={product.id}
                      className="bg-purple-900/30 rounded-xl p-4 border border-purple-500/20 hover:border-cyan-400/40 transition-all cursor-pointer"
                      onClick={() => handleProductClick(product.priceId, product.name)}
                    >
                      <div className="flex items-start justify-between mb-2">
                        <h4 className="text-white font-semibold">
                          {product.name.replace('FrontDesk AI Pro — ', '')}
                        </h4>
                        {product.name.includes('Core') && (
                          <span className="text-xs bg-lime-500 text-white px-2 py-1 rounded-full">
                            Popular
                          </span>
                        )}
                      </div>
                      <p className="text-2xl font-bold text-white mb-2">
                        ${product.price}
                        <span className="text-sm text-purple-300">/mo</span>
                      </p>
                      <p className="text-purple-200 text-xs mb-3">{product.description}</p>
                      <button className="w-full py-2 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 text-white rounded-lg text-sm font-semibold transition-all">
                        Get Started
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
