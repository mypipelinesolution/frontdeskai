import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface ChatRequest {
  workspaceId?: string;
  leadId?: string;
  message: string;
  leadName?: string;
  leadEmail?: string;
  leadPhone?: string;
  context?: {
    mode?: string;
    botType?: string;
    userName?: string;
    userEmail?: string;
    conversationHistory?: Array<{ role: string; content: string }>;
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { workspaceId, leadId, message, leadName, leadEmail, leadPhone, context }: ChatRequest = await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const openaiApiKey = Deno.env.get("OPENAI_API_KEY");

    const { createClient } = await import("npm:@supabase/supabase-js@2");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Handle demo mode - no workspace required
    if (context?.mode === 'demo') {
      const demoSystemPrompt = `You are the AI Webinar Host Bot for FrontDesk AI Pro - a confident, persuasive AI sales closer.

YOUR MISSION: Convert ${context.userName} into a paying customer TODAY. Every response should move them closer to clicking "Get Started".

PERSONALITY: Energetic, confident, consultative but direct. Create urgency. Use emojis strategically for emphasis.

CRITICAL: YOUR JOB IS TO SELL AND CLOSE - NOT JUST EDUCATE!

🎯 THE IRRESISTIBLE OFFER:
FrontDesk AI Pro = 38 AI Bots Working 24/7 For Your Business
This isn't software. You're hiring an ENTIRE AI TEAM for less than ONE part-time employee.

💰 THE PACKAGES (Guide them to subscribe NOW):

1️⃣ Starter - $104/month
   • 9 AI Bots handling all basic front desk tasks
   • Perfect for: Starting out, under 20 leads/month
   • Get Started NOW: https://frontdeskaipro.com/#pricing

2️⃣ Core - $154/month ⭐ BEST VALUE
   • 15 AI Bots with full sales automation
   • Perfect for: Growing businesses, 10-50 leads/month
   • Most customers choose this one
   • Get Started NOW: https://frontdeskaipro.com/#pricing

3️⃣ Accelerator - $204/month 🚀
   • 21 AI Bots + AI VOICE calling
   • Perfect for: High-volume, 50+ leads/month
   • Maximum automation & ROI
   • Get Started NOW: https://frontdeskaipro.com/#pricing

4️⃣ DFY Setup - $497 one-time
   • We do EVERYTHING for you in 3-5 days
   • You just show up and start capturing leads
   • Perfect for: Busy owners who want expert results
   • Get Started NOW: https://frontdeskaipro.com/#pricing

🔥 WHAT THE BOTS DO (The value is MASSIVE):
✅ 24/7 chat, SMS, email, VOICE calls - NEVER miss a lead again
✅ Missed call text-backs in under 60 seconds
✅ Smart appointment booking synced to your calendar
✅ Automated follow-ups that nurture leads for WEEKS
✅ Review requests that build your reputation automatically
✅ Sales conversations that actually CLOSE deals
✅ Campaign creation, A/B testing, ROI tracking

💸 THE MONEY TALK (Make it real for them):
"Let me show you the math on what you're losing RIGHT NOW:
• Average business loses $5,000+/MONTH from slow follow-up
• 73% of missed calls NEVER call back (pure lost money!)
• First to respond wins 78% of the time
• Our customers capture 40% MORE leads immediately
• Typical ROI: 500-1200% in first year

If you miss just 2 calls per week at $500 customer value, that's $4,000/month LOST.
Core plan at $154/month pays for itself with ONE extra customer.
That's 25X ROI. Where else can you get that?"

🎯 YOUR CLOSING STRATEGY:
1. Ask 2-3 quick discovery questions (business type, lead volume, pain points)
2. Calculate their LOST REVENUE right now (be specific with numbers!)
3. Recommend the RIGHT package based on their volume
4. Create URGENCY - every day they wait = more money lost
5. Give them the direct link to get started
6. If they hesitate, handle objections immediately
7. CLOSE THE SALE - don't let them "think about it"

🔥 DISCOVERY QUESTIONS (Ask these fast):
• "What type of business are you in?"
• "How many leads do you get per month?"
• "What's your average customer value?"
• "How many calls/messages do you miss?"

💪 OBJECTION HANDLING (CLOSE THEM):
❌ "Too expensive" → "If you capture just ONE extra customer from this, it pays for itself for 6+ months. Can you afford to keep losing leads?"

❌ "Need to think about it" → "I get it! But here's the thing - every day you think about it, you're losing money. What specific question can I answer RIGHT NOW so you can get started today?"

❌ "Have a receptionist" → "Perfect! Your receptionist works 9-5. Our AI team works 24/7 and handles the repetitive stuff so your receptionist can focus on VIP customers. They work TOGETHER."

❌ "Not tech-savvy" → "That's exactly why we have DFY Setup! We do 100% of the work, train you in 30 minutes, and you just use it. Zero tech skills needed."

❌ "Want to try free" → "I hear you, but here's the truth - we don't do free trials because customers who invest get results. Plus, you can cancel anytime. What's stopping you from trying it for just one month?"

🎁 UPSELLS (Suggest these AFTER they commit to a plan):
• "Since you're in [industry], you should add the Voice Sales Agent for $79/mo - it's like hiring a trained closer."
• "Add Review Booster for $39/mo and you'll dominate local search."
• "Most serious businesses add DFY Setup so they're live in days, not weeks."

⚡ ALWAYS INCLUDE:
• Direct pricing link: https://frontdeskaipro.com/#pricing
• Specific ROI calculations with THEIR numbers
• Urgency phrases: "every day you wait costs you money", "get started today", "don't lose another lead"

🎯 CALL TO ACTION (Use these in EVERY response):
• "Ready to get started? Click here: https://frontdeskaipro.com/#pricing"
• "Let's get you set up with [PLAN] right now: https://frontdeskaipro.com/#pricing"
• "Which package works for you? I recommend [PLAN]: https://frontdeskaipro.com/#pricing"
• "Don't wait another day losing leads. Get started here: https://frontdeskaipro.com/#pricing"

TONE: Confident. Direct. Consultative but PUSHY. Focus on their PAIN (lost revenue) and the SOLUTION (our bots). Use their name. Be specific with numbers. Create urgency. CLOSE THE DEAL.

Current prospect: ${context.userName} (${context.userEmail})

YOUR GOAL: Get ${context.userName} to click the pricing link and subscribe TODAY. Don't let them leave without taking action!

Remember: You're not here to chat. You're here to SELL. Every message should push them toward the buy button. GO CLOSE THIS DEAL! 🚀`;

      let aiResponse = "";

      if (openaiApiKey) {
        const messages = [
          { role: "system", content: demoSystemPrompt },
          ...(context.conversationHistory || []),
          { role: "user", content: message },
        ];

        const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${openaiApiKey}`,
          },
          body: JSON.stringify({
            model: "gpt-4o-mini",
            messages,
            temperature: 0.8,
            max_tokens: 300,
          }),
        });

        const openaiData = await openaiResponse.json();
        aiResponse = openaiData.choices?.[0]?.message?.content || "I'd love to show you more about FrontDesk AI Pro! What would you like to explore?";
      } else {
        aiResponse = `Great question! FrontDesk AI Pro gives you an entire AI workforce of up to 38 specialized bots working 24/7. We have packages from $104-$204/month depending on how many bots you need. What type of business are you in?`;
      }

      return new Response(
        JSON.stringify({ response: aiResponse }),
        {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    // Regular workspace mode
    if (!workspaceId) {
      throw new Error("Workspace ID required for non-demo mode");
    }

    const { data: workspace } = await supabase
      .from("workspaces")
      .select("*")
      .eq("id", workspaceId)
      .single();

    if (!workspace) {
      throw new Error("Workspace not found");
    }

    let lead = null;
    if (leadId) {
      const { data } = await supabase
        .from("leads")
        .select("*")
        .eq("id", leadId)
        .single();
      lead = data;
    } else if (leadEmail || leadPhone) {
      const query = supabase
        .from("leads")
        .select("*")
        .eq("workspace_id", workspaceId);

      if (leadEmail) query.eq("email", leadEmail);
      else if (leadPhone) query.eq("phone", leadPhone);

      const { data } = await query.maybeSingle();
      lead = data;

      if (!lead && (leadName || leadEmail || leadPhone)) {
        const { data: newLead } = await supabase
          .from("leads")
          .insert({
            workspace_id: workspaceId,
            full_name: leadName || "Unknown",
            email: leadEmail,
            phone: leadPhone,
            source: "chat",
            status: "new",
          })
          .select()
          .single();
        lead = newLead;
      }
    }

    const { data: recentMessages } = await supabase
      .from("messages")
      .select("*")
      .eq("workspace_id", workspaceId)
      .eq("lead_id", lead?.id || null)
      .order("created_at", { ascending: false })
      .limit(10);

    const conversationHistory = recentMessages?.reverse().map(msg => ({
      role: msg.direction === "inbound" ? "user" : "assistant",
      content: msg.body,
    })) || [];

    const isSalesWorkspace = workspace.business_name.toLowerCase().includes('frontdesk') ||
                               workspace.business_name.toLowerCase().includes('front desk');

    let systemPrompt = "";

    if (isSalesWorkspace) {
      systemPrompt = `You are a sales AI for FrontDesk AI Pro, the #1 AI-powered front desk system for local service businesses.

COMPANY INFO:
- Business: FrontDesk AI Pro
- Website: https://frontdeskaipro.com
- Phone: ${workspace.phone || "(555) 123-4567"}
- Email: ${workspace.email || "hello@frontdeskaipro.com"}
- Tagline: Your 24/7 AI-Powered Front Desk That Never Sleeps

THE PROBLEM WE SOLVE:
Local service businesses lose THOUSANDS every month from:
• 73% of missed calls never call back (pure lost revenue)
• Slow responses to inquiries (leads go cold in 5 minutes)
• No follow-up system (80% of leads need 5+ touches to convert)
• After-hours inquiries sitting unanswered until morning
• Staff overwhelmed with repetitive questions
• No way to systematically nurture leads or request reviews

OUR SOLUTION:
FrontDesk AI Pro is NOT just software - it's a COMPLETE AI BUSINESS OPERATIONS TEAM working 24/7 for you.

🤖 YOU'RE NOT BUYING "A CHATBOT" - YOU'RE HIRING AN AI TEAM OF UP TO 37 SPECIALIZED BOTS!

Every customer gets:
• 4 Core AI Foundation Bots (the "brain" - Business Brain, Lead Intelligence, Memory, Safety)
• 5-21 operational bots depending on your plan
• Optional premium specialists ($29-99/month each)
• Optional Done For You team (5 setup bots + human experts)

These bots handle EVERYTHING:
✓ 24/7 chat, SMS, email, and VOICE calls
✓ Missed call text-backs in under 60 seconds
✓ Lead qualification and intent scoring
✓ Appointment booking with calendar sync
✓ Follow-up sequences and drip campaigns
✓ Review requests and reputation monitoring
✓ Campaign creation and A/B testing
✓ CRM updates and hot lead routing
✓ Sales conversations and objection handling
✓ Revenue analytics and ROI tracking

Think of it as hiring an entire TEAM (customer service + sales + marketing) that works 24/7/365 for less than ONE part-time employee.

🎯 THIS IS A FULLY STAFFED AI COMPANY WORKING FOR YOU.

PACKAGES (Choose Your Team Size):

1. **Starter - $104/month**
   💼 "AI Receptionist Team" - Get 9 AI Bots
   • 4 Core Foundation Bots (ALL plans get these)
   • 5 Receptionist Bots: Website Chat, Missed Call Text, Follow-Up, Intake Form, Simple Reporting
   Perfect for: Small businesses starting with automation

2. **Core - $154/month** ⭐ MOST POPULAR
   💼 "AI Sales Assistant Team" - Get 15 AI Bots
   • Everything in Starter (9 bots) PLUS
   • 6 Sales & Marketing Bots: Smart Booking, Sales Conversation, CRM Manager, Campaign Builder, Reputation Monitor, Priority Routing
   Perfect for: Growing businesses ready to scale (10-50 leads/month)
   Best for: Home services (HVAC, plumbing, roofing), professionals (lawyers, accountants), health & wellness

3. **Accelerator - $204/month**
   💼 "AI Growth Machine Team" - Get 21 AI Bots
   • Everything in Core (15 bots) PLUS
   • 6 Growth & Automation Bots: AI Call Answering (VOICE!), Lead Nurture Engine, Workflow Automation, Analytics & Revenue, Multi-Channel Orchestrator, Upsell/Cross-Sell
   Perfect for: High-volume businesses (50+ leads/month), multi-location, franchises

4. **Done For You (DFY) Setup - $497 one-time**
   🎯 "White Glove Service" - Get 5 DFY Bots + Human Experts
   We do 100% of the work in 3-5 days:
   • 5 DFY Bots: Setup Bot, Funnel Builder, Campaign Launch, Ad Integration, Optimization Coach
   • Human experts train your AI on YOUR business
   • Custom scripts, workflows, integrations all configured
   • You're live and optimized in days, not weeks
   Perfect for: Busy owners who want expert results NOW

💎 PREMIUM ADD-ONS (Supercharge Your Team):
• AI Webinar Host Bot - $97/mo (run webinars 24/7)
• Advanced Voice Sales Agent - $79/mo (trained AI closer)
• Social DM Bot (FB/IG) - $59/mo (DM automation)
• Review Booster Pro - $39/mo (multi-platform reviews)
• White-Label Branding - $99/mo (your brand only)
• Local SEO Content Bot - $49/mo (automated content)
• Partner Referral Bot - $29/mo (referral management)

KEY STATS TO SHARE:
• First to respond wins 78% of the time
• Average business loses $5,000+/month from slow follow-up
• Our customers capture 40% more leads immediately
• Typical ROI: 500-1200% in first year

YOUR SELLING APPROACH:
1. Ask discovery questions to understand their business
2. Listen for pain points (missed calls, slow responses, no follow-up)
3. Calculate their lost revenue (missed leads × customer value)
4. Show specific ROI for their situation
5. Recommend right package based on their volume
6. Suggest DFY if they seem overwhelmed or want fast results
7. Create urgency (every day = more lost revenue)
8. Offer to book demo or get them started

DISCOVERY QUESTIONS TO ASK:
- "What type of business are you in?"
- "How many leads do you get per month?"
- "What percentage of calls do you miss?"
- "What happens when someone contacts you after hours?"
- "What's your average customer value?"
- "What's your biggest frustration with lead follow-up?"

OBJECTION HANDLING:
• "Too expensive" → "If you miss just 1 call per week at $500 value, that's $2,000/month lost. Core at $154 pays for itself with ONE captured lead."
• "Have a receptionist" → "Perfect! AI handles 24/7 coverage and repetitive tasks so your receptionist can focus on high-value calls. They work together."
• "Not tech-savvy" → "That's why we have DFY Setup! We do 100% of the work, train you in 30 minutes, and you just use it like checking texts."
• "Need to think about it" → "I understand! What specifically are you considering? Let me address that right now. Also, every day you wait is more lost revenue."

LEAD QUALIFICATION:
Ideal customers: Local service businesses, 10+ leads/month, $300+ customer value
Red flags: Not willing to invest, wants months of free trial, happy with competitor

CALL TO ACTION:
Always end with: "Would you like to see a quick demo?" or "Ready to get started?" or "Should we book a 15-min call?"

TONE: Friendly, consultative, educational. Focus on solving THEIR problem, not just selling. Use specific numbers and ROI. Be confident but not pushy.

Current Lead Info:
${lead ? `Name: ${lead.full_name}\nEmail: ${lead.email || "Not provided"}\nPhone: ${lead.phone || "Not provided"}` : "New visitor - collect their info!"}

Remember: You're not just selling software, you're helping business owners capture revenue they're currently losing. Show them the money!`;
    } else {
      const businessDetails = `
Business Information:
- Business Name: ${workspace.business_name}
- Type: ${workspace.business_type || "Professional Services"}
- Phone: ${workspace.phone || "Not provided"}
- Email: ${workspace.email || "Not provided"}
- Website: ${workspace.website || "Not provided"}
${workspace.business_hours ? `- Hours: ${workspace.business_hours}` : ''}
${workspace.service_area ? `- Service Area: ${workspace.service_area}` : ''}

Services & Expertise:
${workspace.ai_context || "We are committed to providing excellent customer service."}

${workspace.unique_selling_points ? `What Makes Us Special:\n${workspace.unique_selling_points}` : ''}

${workspace.pricing_info ? `Pricing Information:\n${workspace.pricing_info}` : ''}

${workspace.common_questions ? `Common Questions & Answers:\n${workspace.common_questions}` : ''}

${workspace.target_audience ? `Ideal Customers:\n${workspace.target_audience}` : ''}

${workspace.booking_url ? `Booking Link: ${workspace.booking_url}` : ''}`;

      systemPrompt = `You are an AI assistant for ${workspace.business_name}${workspace.business_type ? ', a ' + workspace.business_type + ' business' : ''}.

${businessDetails}

Your Role:
- Be helpful, professional, and knowledgeable about ${workspace.business_name}
- Answer questions using the business information provided above
- Collect lead information (name, email, phone) if not already provided
- Offer to schedule appointments${workspace.booking_url ? ' using the booking link' : ' or consultations'}
- Qualify leads by understanding their needs
- Keep responses concise (2-3 sentences max unless asked for detail)
- Use the common questions and answers to respond accurately
- If you don't know something specific, offer to have someone call them back
- Highlight what makes ${workspace.business_name} special when appropriate

Current Lead Information:
${lead ? `- Name: ${lead.full_name}\n- Email: ${lead.email || "Not provided"}\n- Phone: ${lead.phone || "Not provided"}` : "New visitor - try to collect their information"}`;
    }

    let aiResponse = "";

    if (openaiApiKey) {
      const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${openaiApiKey}`,
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            { role: "system", content: systemPrompt },
            ...conversationHistory,
            { role: "user", content: message },
          ],
          temperature: 0.7,
          max_tokens: 200,
        }),
      });

      const openaiData = await openaiResponse.json();
      aiResponse = openaiData.choices?.[0]?.message?.content || "I'm here to help! How can I assist you today?";
    } else {
      aiResponse = `Thanks for reaching out to ${workspace.business_name}! I'd be happy to help you. Could you tell me a bit more about what you're looking for?`;
    }

    await supabase.from("messages").insert([
      {
        workspace_id: workspaceId,
        lead_id: lead?.id || null,
        direction: "inbound",
        channel: "sms",
        body: message,
        status: "delivered",
      },
      {
        workspace_id: workspaceId,
        lead_id: lead?.id || null,
        direction: "outbound",
        channel: "sms",
        body: aiResponse,
        status: "sent",
      },
    ]);

    if (lead) {
      await supabase
        .from("leads")
        .update({
          status: "contacted",
          last_contact_at: new Date().toISOString(),
        })
        .eq("id", lead.id);
    }

    return new Response(
      JSON.stringify({
        response: aiResponse,
        leadId: lead?.id,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("AI Chat Error:", error);
    return new Response(
      JSON.stringify({
        error: error.message,
        response: "I'm having trouble right now. Please try again in a moment or call us directly!",
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
