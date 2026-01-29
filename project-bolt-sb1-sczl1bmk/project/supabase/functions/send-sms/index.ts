import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface SMSRequest {
  workspaceId: string;
  leadId?: string;
  to: string;
  message: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { workspaceId, leadId, to, message }: SMSRequest = await req.json();

    if (!to || !message) {
      throw new Error("Missing required fields: to, message");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const twilioAccountSid = Deno.env.get("TWILIO_ACCOUNT_SID");
    const twilioAuthToken = Deno.env.get("TWILIO_AUTH_TOKEN");
    const twilioPhoneNumber = Deno.env.get("TWILIO_PHONE_NUMBER");

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

    let messageStatus = "sent";
    let twilioResponse = null;

    if (twilioAccountSid && twilioAuthToken && twilioPhoneNumber) {
      const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${twilioAccountSid}/Messages.json`;

      const formData = new URLSearchParams();
      formData.append("To", to);
      formData.append("From", workspace.phone || twilioPhoneNumber);
      formData.append("Body", message);

      const response = await fetch(twilioUrl, {
        method: "POST",
        headers: {
          "Authorization": `Basic ${btoa(`${twilioAccountSid}:${twilioAuthToken}`)}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: formData.toString(),
      });

      twilioResponse = await response.json();

      if (!response.ok) {
        messageStatus = "failed";
        console.error("Twilio error:", twilioResponse);
      } else {
        messageStatus = "delivered";
      }
    } else {
      console.log("Twilio not configured - simulating SMS send");
      messageStatus = "sent";
    }

    const { data: messageRecord, error: dbError } = await supabase
      .from("messages")
      .insert({
        workspace_id: workspaceId,
        lead_id: leadId || null,
        direction: "outbound",
        channel: "sms",
        from_number: workspace.phone || twilioPhoneNumber || "System",
        to_number: to,
        body: message,
        status: messageStatus,
      })
      .select()
      .single();

    if (dbError) {
      console.error("Database error:", dbError);
    }

    if (leadId) {
      await supabase
        .from("leads")
        .update({
          last_contact_at: new Date().toISOString(),
          status: "contacted",
        })
        .eq("id", leadId);
    }

    return new Response(
      JSON.stringify({
        success: messageStatus !== "failed",
        status: messageStatus,
        messageId: messageRecord?.id,
        twilioSid: twilioResponse?.sid,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("SMS Send Error:", error);
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
