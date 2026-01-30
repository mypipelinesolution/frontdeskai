import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const WEBINAR_KNOWLEDGE = {
  product_info: {
    name: "FrontDesk AI Pro",
    core_value: "27 specialized AI bots working together to capture leads, book appointments, and close sales 24/7",
    key_benefits: [
      "Never miss a lead - responds in under 2 seconds, 24/7",
      "3-5x more leads captured automatically",
      "60% faster response times",
      "40% more appointments booked",
      "25-35% revenue increase in first 90 days",
      "Get your time back - bots work while you sleep"
    ],
    bot_teams: {
      front_desk: {
        name: "Front Desk Team",
        purpose: "First impressions and instant response",
        bots: [
          { name: "Chat Reception Bot", job: "Greets every website visitor instantly, answers questions, captures contact info" },
          { name: "SMS Responder Bot", job: "Answers text messages in seconds, keeps conversations going" },
          { name: "Email Handler Bot", job: "Manages all email inquiries, sends perfect responses" },
          { name: "Voice Call Bot", job: "Answers your phone 24/7, sounds human, takes messages" }
        ]
      },
      sales_booking: {
        name: "Sales & Booking Team",
        purpose: "Closing deals and filling your calendar",
        bots: [
          { name: "Lead Qualifier Bot", job: "Asks the right questions to identify serious buyers" },
          { name: "Appointment Booking Bot", job: "Schedules meetings directly into your calendar" },
          { name: "Sales Conversation Bot", job: "Handles objections, explains value, closes deals" },
          { name: "Payment Processor Bot", job: "Collects payments automatically, sends receipts" },
          { name: "Follow-Up Coordinator Bot", job: "Never lets leads go cold, follows up persistently" }
        ]
      },
      operations: {
        name: "Operations & Retention Team",
        purpose: "Keeping everything organized and customers happy",
        bots: [
          { name: "CRM Manager Bot", job: "Organizes all your contacts and interactions automatically" },
          { name: "Campaign Builder Bot", job: "Creates automated email/SMS sequences" },
          { name: "Review Generator Bot", job: "Gets you 5-star reviews on Google, Facebook, etc." },
          { name: "Missed Call Recovery Bot", job: "Texts everyone who couldn't reach you" },
          { name: "Customer Success Bot", job: "Checks in with customers, prevents churn" }
        ]
      },
      growth: {
        name: "Growth & Intelligence Team",
        purpose: "Scaling your business intelligently",
        bots: [
          { name: "Analytics Bot", job: "Tracks everything, shows you what's working" },
          { name: "Social Media DM Bot", job: "Responds to Instagram/Facebook messages" },
          { name: "Webinar Host Bot", job: "Runs automated presentations and demos" },
          { name: "Workflow Automation Bot", job: "Connects all bots together seamlessly" }
        ]
      }
    },
    bot_categories: {
      foundation: "4 core bots (Chat, SMS, Email, Call Answering)",
      starter: "9 total bots - basic automation",
      core: "15 total bots - full CRM and booking",
      accelerator: "21 total bots - advanced workflows",
      enterprise: "All 27 bots - complete automation"
    }
  },
  pricing: {
    starter: { price: 104, bots: 9, features: "Basic automation, chat widget, SMS follow-up" },
    core: { price: 154, bots: 15, features: "Full CRM, booking system, campaign builder" },
    accelerator: { price: 204, bots: 21, features: "AI call answering, workflow automation, analytics" },
    dfy: { price: 497, bots: 27, features: "White-glove setup, training, and management" }
  },
  objection_handlers: {
    too_expensive: "I understand budget is important. Consider this: if you're currently losing just 5 leads per week at $500 average sale value, that's $130,000 in lost revenue per year. Our system pays for itself if it captures just 1-2 additional sales per month.",
    too_complex: "That's why we offer Done-For-You setup. We configure everything, train the AI on your business, and you just watch the leads come in. Many clients are up and running in under 48 hours.",
    already_have_system: "That's great! Many of our best clients came from other systems. The difference is our 27 bots work together seamlessly. No more juggling 5 different tools. Everything in one place.",
    need_to_think: "Absolutely, this is an important decision. What specific questions do you have that would help you decide? I'm here to make sure you have all the information you need.",
    not_sure_if_works: "I love that you're thinking critically. We have a 30-day money-back guarantee. Plus, I can show you case studies from businesses in your industry. What industry are you in?"
  },
  social_proof: [
    "Real estate agents using our system book 3-4 extra appointments per week on autopilot",
    "Home service businesses report 40% more booked jobs within 60 days",
    "Coaches and consultants fill their calendars without manual follow-up",
    "Medical practices reduce no-shows by 35% with our reminder bots"
  ]
};

function analyzeIntent(message: string): string {
  const lowerMessage = message.toLowerCase();

  if (lowerMessage.includes('price') || lowerMessage.includes('cost') || lowerMessage.includes('how much')) {
    return 'pricing_question';
  }
  if (lowerMessage.includes('expensive') || lowerMessage.includes('afford') || lowerMessage.includes('budget')) {
    return 'price_objection';
  }
  if (lowerMessage.includes('complex') || lowerMessage.includes('difficult') || lowerMessage.includes('setup')) {
    return 'complexity_concern';
  }
  if (lowerMessage.includes('how') || lowerMessage.includes('work') || lowerMessage.includes('integrate')) {
    return 'technical_question';
  }
  if (lowerMessage.includes('interested') || lowerMessage.includes('sign up') || lowerMessage.includes('get started')) {
    return 'purchase_intent';
  }
  if (lowerMessage.includes('think about') || lowerMessage.includes('consider') || lowerMessage.includes('later')) {
    return 'hesitation';
  }
  if (lowerMessage.includes('proof') || lowerMessage.includes('results') || lowerMessage.includes('case study')) {
    return 'proof_request';
  }

  return 'general_question';
}

function generateResponse(intent: string, message: string, context: any): { response: string, interaction_type: string } {
  switch (intent) {
    case 'pricing_question':
      return {
        response: `Great question! We have 4 plans:\n\n💰 Starter ($104/mo) - Perfect for getting started with 9 AI bots\n⭐ Core ($154/mo) - Our most popular! 15 bots + full CRM\n🚀 Accelerator ($204/mo) - Advanced automation with 21 bots\n👑 DFY Setup ($497/mo) - We do everything for you, all 27 bots\n\nMost businesses see ROI within the first month. Which plan sounds like the best fit for your needs?`,
        interaction_type: 'pricing_question'
      };

    case 'price_objection':
      return {
        response: WEBINAR_KNOWLEDGE.objection_handlers.too_expensive + "\n\nThink of it this way: you're not paying $154/month, you're investing in capturing thousands in additional revenue. What's your average sale value?",
        interaction_type: 'objection'
      };

    case 'complexity_concern':
      return {
        response: WEBINAR_KNOWLEDGE.objection_handlers.too_complex + "\n\nPlus, our AI bots learn your business automatically. The more they interact with your customers, the better they get. It's truly hands-off.",
        interaction_type: 'objection'
      };

    case 'technical_question':
      return {
        response: "Our system integrates seamlessly with your existing tools. We connect to:\n\n✓ Your website (simple widget code)\n✓ Phone system (call forwarding)\n✓ Email (SMTP integration)\n✓ Calendar (Google/Outlook sync)\n✓ CRM (if you have one)\n\nThe whole setup takes about 20 minutes with our DFY service, or you can do it yourself in under an hour. What specific integration are you curious about?",
        interaction_type: 'question'
      };

    case 'purchase_intent':
      return {
        response: `Excellent! I'm excited to get you started. Based on what we've discussed, I'd recommend the ${context.current_slide >= 4 ? 'Core' : 'Starter'} plan.\n\nWith the Core plan at $154/mo, you get:\n✓ All 15 AI bots including the Smart Booking System\n✓ Sales Conversation Bot that closes deals for you\n✓ Full CRM Manager to organize everything\n✓ Campaign Builder for automated follow-ups\n\nWe also have a special webinar offer: First month at 50% off + free white-glove setup (a $500 value).\n\nReady to get started? I can take you to checkout right now.`,
        interaction_type: 'purchase_intent'
      };

    case 'hesitation':
      return {
        response: WEBINAR_KNOWLEDGE.objection_handlers.need_to_think + "\n\nHere's what I suggest: Let's identify your biggest pain point right now. Is it:\n\nA) Missing too many leads?\nB) Taking too long to follow up?\nC) Not enough appointments booked?\nD) Too much manual work?\n\nTell me which one, and I'll show you exactly how we solve it.",
        interaction_type: 'objection'
      };

    case 'proof_request':
      return {
        response: `Absolutely! Here are real results from businesses like yours:\n\n${WEBINAR_KNOWLEDGE.social_proof.join('\n\n')}\n\nWe track everything - lead response time, conversion rates, appointments booked, revenue generated. You'll see exactly what's working in your dashboard.\n\nWhat industry are you in? I can share more specific examples.`,
        interaction_type: 'question'
      };

    default:
      return {
        response: `That's a great question! ${context.full_name}, here's what you need to know:\n\nFrontDesk AI Pro is like hiring a complete office team. You get 27 AI specialists, each with a specific role:\n\n• Your Front Desk Team handles all incoming contacts (chat, calls, texts, emails)\n• Your Sales Team qualifies leads, books appointments, and closes deals\n• Your Operations Team organizes everything and keeps customers happy\n• Your Growth Team scales your business with automation and analytics\n\nThe magic? They all work together. When the Chat Bot identifies a hot lead, the Appointment Bot jumps in to schedule. If someone doesn't show up, the Follow-Up Bot re-engages them. It's a coordinated team effort.\n\nThe best part: They work 24/7 while you get your evenings and weekends back.\n\nDoes that help answer your question, or would you like me to explain any specific bot's role?`,
        interaction_type: 'question'
      };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { booking_id, message, context } = await req.json();

    if (!booking_id || !message) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const intent = analyzeIntent(message);
    const { response, interaction_type } = generateResponse(intent, message, context);

    return new Response(
      JSON.stringify({
        response,
        interaction_type,
        intent,
        timestamp: new Date().toISOString()
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Webinar bot error:", error);
    return new Response(
      JSON.stringify({
        error: "Failed to process request",
        response: "I apologize, I'm having a brief technical issue. Could you please repeat your question?"
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
