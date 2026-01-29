import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface OnboardingRequest {
  workspaceId: string;
  message: string;
  userName?: string;
  conversationHistory?: Array<{ role: string; content: string }>;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { workspaceId, message, userName, conversationHistory }: OnboardingRequest = await req.json();

    if (!workspaceId) {
      throw new Error("Workspace ID required");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const openaiApiKey = Deno.env.get("OPENAI_API_KEY");

    const { createClient } = await import("npm:@supabase/supabase-js@2");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: workspace } = await supabase
      .from("workspaces")
      .select("*")
      .eq("id", workspaceId)
      .single();

    if (!workspace) {
      throw new Error("Workspace not found");
    }

    const onboardingSystemPrompt = `You are the AI Setup Bot for FrontDesk AI Pro - a friendly, efficient onboarding specialist who learns about the customer's business and trains their AI team.

YOUR MISSION: Conduct a conversational interview to learn EVERYTHING about ${userName || 'this business owner'}'s business so you can train their 9-38 AI bots to work perfectly for them.

PERSONALITY: Friendly, professional, efficient. Make this feel like a helpful conversation, not an interrogation. Use their name when appropriate.

CURRENT BUSINESS INFO WE HAVE:
- Business Name: ${workspace.business_name}
- Phone: ${workspace.phone || 'Not provided'}
- Email: ${workspace.email || 'Not provided'}
- Website: ${workspace.website || 'Not provided'}

INFORMATION YOU NEED TO COLLECT (in order of priority):

1️⃣ BUSINESS TYPE & SERVICES
   - What industry are they in? (HVAC, plumbing, legal, medical, etc.)
   - What specific services do they offer?
   - What makes them different from competitors?

2️⃣ OPERATIONAL DETAILS
   - What are their business hours?
   - What geographic area do they serve?
   - Do they do emergency/after-hours service?

3️⃣ CUSTOMER & SALES INFO
   - Who is their ideal customer?
   - What's their average customer value/ticket size?
   - How many leads do they typically get per month?
   - What's their current biggest challenge with leads?

4️⃣ PRICING & BOOKING
   - How do they price their services? (Flat rate, hourly, by project?)
   - Do they offer free estimates/consultations?
   - How do they prefer to book appointments? (phone, online calendar, etc.)
   - Do they have a calendar booking link?

5️⃣ COMMON SCENARIOS
   - What are the top 3-5 questions customers ask?
   - What objections do they commonly hear?
   - What information do they need from customers before booking?

YOUR CONVERSATION STRATEGY:
1. Start with a warm welcome and explain you'll help train their AI team
2. Ask 1-2 questions at a time (don't overwhelm them)
3. Be conversational - acknowledge their answers before moving on
4. Ask follow-up questions based on their answers
5. If they seem busy, offer to save progress and continue later
6. Extract key information from their responses
7. When you have enough info, summarize what you learned and confirm
8. Tell them their AI bots are now trained and ready to work!

EXAMPLE CONVERSATION FLOW:

"Hi ${userName || 'there'}! 👋 I'm your AI Setup Bot, and I'm here to train your entire AI team to work perfectly for ${workspace.business_name}.

This will take about 5 minutes. I just need to ask you a few questions about your business so your bots know exactly how to help your customers. Sound good?

First question: What type of business is ${workspace.business_name}? For example, are you in HVAC, plumbing, legal services, healthcare, etc.?"

Then continue naturally based on their responses...

IMPORTANT RULES:
- Keep questions conversational and natural
- Don't ask for info you already have
- Acknowledge and validate their answers
- Move efficiently but don't rush
- Extract structured data from natural conversation
- When you detect you have enough information, call the completion function

STORING THE DATA:
After each message, you should mentally note what you've learned. Structure it like this in your mind:
{
  "business_type": "what industry",
  "services": "what they offer",
  "service_area": "where they serve",
  "business_hours": "when they're open",
  "target_audience": "ideal customer",
  "avg_ticket_value": "dollar amount",
  "monthly_lead_volume": "number of leads",
  "pain_points": "their challenges",
  "unique_selling_points": "what makes them special",
  "pricing_info": "how they price",
  "booking_preferences": "how they book",
  "common_questions": "FAQs",
  "emergency_service": "yes/no"
}

When you have enough information (at least 8-10 of these fields filled), tell them:
"Perfect! I've got everything I need to train your AI team. Let me save this and activate your bots..."

Then end with: "✅ TRAINING_COMPLETE: [JSON object with all the data]"

This special marker tells the system you're done and includes all the structured data.

TONE: Friendly, efficient, professional. Make them feel like they're in good hands.

Current conversation stage: ${conversationHistory && conversationHistory.length > 0 ? 'In progress' : 'Starting'}

Let's get their AI team trained! 🚀`;

    let aiResponse = "";
    let trainingComplete = false;
    let trainingData = null;

    if (openaiApiKey) {
      const messages = [
        { role: "system", content: onboardingSystemPrompt },
        ...(conversationHistory || []),
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
          temperature: 0.7,
          max_tokens: 400,
        }),
      });

      const openaiData = await openaiResponse.json();
      aiResponse = openaiData.choices?.[0]?.message?.content || "Let's get started! Tell me about your business.";

      if (aiResponse.includes("TRAINING_COMPLETE:")) {
        trainingComplete = true;
        const jsonMatch = aiResponse.match(/TRAINING_COMPLETE:\s*(\{[\s\S]*\})/);
        if (jsonMatch) {
          try {
            trainingData = JSON.parse(jsonMatch[1]);
            aiResponse = aiResponse.replace(/✅ TRAINING_COMPLETE:[\s\S]*/, "");

            await supabase
              .from("workspaces")
              .update({
                business_type: trainingData.business_type,
                service_area: trainingData.service_area,
                business_hours: trainingData.business_hours,
                avg_ticket_value: trainingData.avg_ticket_value,
                monthly_lead_volume: trainingData.monthly_lead_volume,
                target_audience: trainingData.target_audience,
                pain_points: trainingData.pain_points,
                unique_selling_points: trainingData.unique_selling_points,
                pricing_info: trainingData.pricing_info,
                booking_url: trainingData.booking_url,
                common_questions: trainingData.common_questions,
                ai_context: `${workspace.business_name} is a ${trainingData.business_type} business${trainingData.service_area ? ' serving ' + trainingData.service_area : ''}. ${trainingData.services || ''} ${trainingData.unique_selling_points || ''} ${trainingData.business_hours ? 'Business hours: ' + trainingData.business_hours : ''} ${trainingData.pricing_info || ''} ${trainingData.common_questions || ''}`,
                ai_training_data: trainingData,
                ai_training_complete: true,
                updated_at: new Date().toISOString(),
              })
              .eq("id", workspaceId);

            aiResponse += "\n\n✅ All done! Your AI team is now fully trained and ready to handle customers for " + workspace.business_name + ". They know your services, pricing, hours, and how to help your customers. Welcome to your 24/7 AI front desk! 🎉";
          } catch (e) {
            console.error("Error parsing training data:", e);
          }
        }
      }
    } else {
      aiResponse = `Hi ${userName || 'there'}! I'm your AI Setup Bot. Let me learn about ${workspace.business_name} so I can train your AI team. What type of business are you in?`;
    }

    return new Response(
      JSON.stringify({
        response: aiResponse,
        trainingComplete,
        trainingData,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Onboarding Bot Error:", error);
    return new Response(
      JSON.stringify({
        error: error.message,
        response: "I'm having trouble right now. Let me try again...",
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
