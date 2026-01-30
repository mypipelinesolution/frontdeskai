import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

/**
 * Local-Link Outbox Sender
 *
 * Sends pending outbox events to Local-Link for commission attribution.
 * Run this on a schedule (e.g., every 2-5 minutes).
 *
 * FrontDesk AI Pro does NOT calculate commissions.
 * We only capture referral slugs and forward them to Local-Link.
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const locallinkUrl = Deno.env.get("LOCALLINK_INGEST_URL");
    const locallinkSecret = Deno.env.get("LOCALLINK_INGEST_SECRET");

    if (!locallinkUrl || !locallinkSecret) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Local-Link integration not configured",
          sent: 0,
        }),
        {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { createClient } = await import("npm:@supabase/supabase-js@2");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: events, error: fetchError } = await supabase
      .from("outbox_events")
      .select("*")
      .eq("status", "pending")
      .order("created_at", { ascending: true })
      .limit(50);

    if (fetchError) {
      throw fetchError;
    }

    let sent = 0;
    const results = [];

    for (const event of events || []) {
      try {
        const response = await fetch(locallinkUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-LocalLink-Secret": locallinkSecret,
          },
          body: JSON.stringify({
            event_id: event.id,
            event_type: event.event_type,
            created_at: event.created_at,
            workspace_id: event.workspace_id,
            payload: event.payload,
          }),
        });

        if (!response.ok) {
          throw new Error(`Local-Link API returned ${response.status}`);
        }

        await supabase
          .from("outbox_events")
          .update({
            status: "sent",
            sent_at: new Date().toISOString(),
          })
          .eq("id", event.id);

        sent++;
        results.push({
          id: event.id,
          status: "success",
        });
      } catch (error: any) {
        const attempts = (event.attempts || 0) + 1;

        await supabase
          .from("outbox_events")
          .update({
            status: attempts >= 5 ? "failed" : "pending",
            error: error.message || "Unknown error",
            attempts,
          })
          .eq("id", event.id);

        results.push({
          id: event.id,
          status: "failed",
          error: error.message,
        });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        sent,
        processed: results.length,
        results,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error: any) {
    console.error("Outbox sender error:", error);
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
