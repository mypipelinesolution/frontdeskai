import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface EmailRequest {
  workspaceId: string;
  leadId?: string;
  to: string;
  subject: string;
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
    const { workspaceId, leadId, to, subject, message }: EmailRequest = await req.json();

    if (!to || !message) {
      throw new Error("Missing required fields: to, message");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const sendgridApiKey = Deno.env.get("SENDGRID_API_KEY");

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
    let emailResponse = null;

    if (sendgridApiKey) {
      const sendgridUrl = "https://api.sendgrid.com/v3/mail/send";

      const emailData = {
        personalizations: [
          {
            to: [{ email: to }],
            subject: subject || `Message from ${workspace.business_name}`,
          },
        ],
        from: {
          email: workspace.email || "noreply@frontdeskaipro.com",
          name: workspace.business_name,
        },
        content: [
          {
            type: "text/plain",
            value: message,
          },
        ],
      };

      const response = await fetch(sendgridUrl, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${sendgridApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(emailData),
      });

      if (!response.ok) {
        messageStatus = "failed";
        emailResponse = await response.text();
        console.error("SendGrid error:", emailResponse);
      } else {
        messageStatus = "delivered";
      }
    } else {
      console.log("SendGrid not configured - simulating email send");
      messageStatus = "sent";
    }

    const { data: messageRecord, error: dbError } = await supabase
      .from("messages")
      .insert({
        workspace_id: workspaceId,
        lead_id: leadId || null,
        direction: "outbound",
        channel: "email",
        from_number: workspace.email || "noreply@frontdeskaipro.com",
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
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Email Send Error:", error);
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
