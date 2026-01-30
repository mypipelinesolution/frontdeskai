import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

/**
 * Automation Runner - Processes queued automation jobs
 *
 * Run this on a schedule (e.g., every 5 minutes) to process pending jobs
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

    const { createClient } = await import("npm:@supabase/supabase-js@2");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const now = new Date().toISOString();

    // Get jobs ready to run
    const { data: jobs, error: fetchError } = await supabase
      .from("automation_jobs")
      .select("*")
      .eq("status", "queued")
      .lte("run_at", now)
      .limit(25);

    if (fetchError) {
      throw fetchError;
    }

    const results = [];

    for (const job of jobs || []) {
      // Mark as running
      await supabase
        .from("automation_jobs")
        .update({ status: "running" })
        .eq("id", job.id);

      try {
        // Execute the bot
        const botResponse = await fetch(`${supabaseUrl}/functions/v1/ai-chat`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${supabaseServiceKey}`,
          },
          body: JSON.stringify({
            message: job.payload.message || "Follow-up",
            workspaceId: job.workspace_id,
            leadId: job.lead_id || null,
          }),
        });

        const botData = await botResponse.json();

        // Mark as completed
        await supabase
          .from("automation_jobs")
          .update({
            status: "done",
            completed_at: new Date().toISOString(),
          })
          .eq("id", job.id);

        results.push({
          id: job.id,
          status: "success",
          response: botData.response || botData.reply,
        });
      } catch (error: any) {
        // Mark as failed
        await supabase
          .from("automation_jobs")
          .update({
            status: "failed",
            error: error.message || "Unknown error",
            completed_at: new Date().toISOString(),
          })
          .eq("id", job.id);

        results.push({
          id: job.id,
          status: "failed",
          error: error.message,
        });
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
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
  } catch (error) {
    console.error("Automation Runner Error:", error);
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
