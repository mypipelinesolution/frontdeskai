import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface WebhookPayload {
  type: 'sms' | 'missed_call' | 'form_submission';
  workspaceId: string;
  from: string;
  fromName?: string;
  fromEmail?: string;
  body?: string;
  metadata?: Record<string, any>;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const payload: WebhookPayload = await req.json();
    const { type, workspaceId, from, fromName, fromEmail, body, metadata } = payload;

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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

    let lead = null;
    const query = supabase
      .from("leads")
      .select("*")
      .eq("workspace_id", workspaceId);

    if (fromEmail) {
      query.eq("email", fromEmail);
    } else if (from) {
      query.eq("phone", from);
    }

    const { data: existingLead } = await query.maybeSingle();
    lead = existingLead;

    if (!lead) {
      const leadSource = type === 'form_submission' ? 'web_form' :
                        type === 'missed_call' ? 'missed_call' : 'chat';

      const { data: newLead } = await supabase
        .from("leads")
        .insert({
          workspace_id: workspaceId,
          full_name: fromName || "Unknown",
          email: fromEmail || null,
          phone: from || null,
          source: leadSource,
          status: "new",
        })
        .select()
        .single();

      lead = newLead;
    }

    if (body) {
      await supabase.from("messages").insert({
        workspace_id: workspaceId,
        lead_id: lead?.id,
        direction: "inbound",
        channel: type === 'sms' ? 'sms' : 'email',
        from_number: from || fromEmail,
        to_number: workspace.phone || workspace.email,
        body: body,
        status: "delivered",
      });
    }

    const { data: automations } = await supabase
      .from("automations")
      .select("*")
      .eq("workspace_id", workspaceId)
      .eq("enabled", true);

    const relevantAutomations = automations?.filter(automation => {
      if (type === 'missed_call' && automation.type === 'missed_call') return true;
      if (type === 'form_submission' && automation.type === 'instant_reply') return true;
      if (type === 'sms' && automation.type === 'instant_reply') return true;
      return false;
    }) || [];

    const responses = [];

    for (const automation of relevantAutomations) {
      let responseMessage = automation.template
        .replace('{business_name}', workspace.business_name)
        .replace('{lead_name}', lead?.full_name || 'there')
        .replace('{phone}', workspace.phone || '')
        .replace('{email}', workspace.email || '')
        .replace('{website}', workspace.website || '');

      const sendChannel = from?.includes('@') ? 'email' : 'sms';
      const functionUrl = sendChannel === 'email' ?
        `${supabaseUrl}/functions/v1/send-email` :
        `${supabaseUrl}/functions/v1/send-sms`;

      const payload = sendChannel === 'email' ? {
        workspaceId,
        leadId: lead?.id,
        to: fromEmail || from,
        subject: `Message from ${workspace.business_name}`,
        message: responseMessage,
      } : {
        workspaceId,
        leadId: lead?.id,
        to: from,
        message: responseMessage,
      };

      try {
        const response = await fetch(functionUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${supabaseServiceKey}`,
          },
          body: JSON.stringify(payload),
        });

        const result = await response.json();
        responses.push({
          automationId: automation.id,
          success: result.success,
          messageId: result.messageId,
        });
      } catch (error) {
        console.error(`Failed to execute automation ${automation.id}:`, error);
        responses.push({
          automationId: automation.id,
          success: false,
          error: error.message,
        });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        leadId: lead?.id,
        automationsTriggered: responses.length,
        responses,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Webhook Processing Error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
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
