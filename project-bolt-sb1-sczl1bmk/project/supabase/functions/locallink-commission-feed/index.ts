import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-LocalLink-Secret",
};

/**
 * Local-Link Commission Feed (Pull API)
 *
 * Allows Local-Link to pull commission-eligible events.
 * Protected by LOCALLINK_INGEST_SECRET.
 *
 * Query params:
 *   - since: ISO timestamp (optional) - fetch events after this time
 *   - limit: number (optional, max 500) - number of events to fetch
 */
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const secret = req.headers.get("x-locallink-secret");
    const expectedSecret = Deno.env.get("LOCALLINK_INGEST_SECRET");

    if (!expectedSecret) {
      return new Response(
        JSON.stringify({
          error: "Local-Link integration not configured",
        }),
        {
          status: 503,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    if (secret !== expectedSecret) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized",
        }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const { createClient } = await import("npm:@supabase/supabase-js@2");
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const url = new URL(req.url);
    const since = url.searchParams.get("since");
    const limitParam = url.searchParams.get("limit");
    const limit = limitParam ? Math.min(parseInt(limitParam), 500) : 100;

    let query = supabase
      .from("outbox_events")
      .select("*")
      .in("event_type", ["sale.paid", "sale.created", "addon.activated"])
      .order("created_at", { ascending: true })
      .limit(limit);

    if (since) {
      query = query.gte("created_at", since);
    }

    const { data: events, error } = await query;

    if (error) {
      throw error;
    }

    return new Response(
      JSON.stringify({
        success: true,
        count: events?.length || 0,
        events: events || [],
        next_cursor: events && events.length > 0
          ? events[events.length - 1].created_at
          : null,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error: any) {
    console.error("Commission feed error:", error);
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
