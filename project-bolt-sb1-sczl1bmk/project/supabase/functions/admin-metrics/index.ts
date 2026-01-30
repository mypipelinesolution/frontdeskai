import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

/**
 * Admin Metrics Dashboard
 *
 * Returns key business metrics for admin dashboard
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

    // Get counts
    const { count: leadsCount } = await supabase
      .from("leads")
      .select("*", { count: "exact", head: true });

    const { count: workspacesCount } = await supabase
      .from("workspaces")
      .select("*", { count: "exact", head: true });

    const { count: messagesCount } = await supabase
      .from("messages")
      .select("*", { count: "exact", head: true });

    const { count: automationJobsCount } = await supabase
      .from("automation_jobs")
      .select("*", { count: "exact", head: true });

    // Get subscription stats
    const { data: subscriptions } = await supabase
      .from("stripe_subscriptions")
      .select("status, price_id");

    const activeSubscriptions = (subscriptions || []).filter(
      (s: any) => s.status === "active"
    );

    // Get referral stats
    const { data: outboxEvents } = await supabase
      .from("outbox_events")
      .select("event_type, status, payload");

    const referralSales = (outboxEvents || []).filter(
      (e: any) => e.event_type === "sale.paid" && e.payload?.referral_partner_link_slug
    );

    const uniquePartners = new Set(
      referralSales.map((e: any) => e.payload?.referral_partner_link_slug)
    ).size;

    const totalReferralRevenue = referralSales.reduce(
      (sum: number, e: any) => sum + (e.payload?.amount || 0),
      0
    );

    // Calculate estimated MRR (rough based on price IDs)
    const priceMap: Record<string, number> = {
      [Deno.env.get("VITE_STRIPE_PRICE_STARTER") || ""]: 104,
      [Deno.env.get("VITE_STRIPE_PRICE_CORE") || ""]: 154,
      [Deno.env.get("VITE_STRIPE_PRICE_PRO") || ""]: 204,
    };

    let estimatedMRR = 0;
    const planCounts: Record<string, number> = {};

    activeSubscriptions.forEach((sub: any) => {
      const price = priceMap[sub.price_id] || 0;
      estimatedMRR += price;

      const planName = price === 104 ? "Starter" : price === 154 ? "Core" : price === 204 ? "Pro" : "Unknown";
      planCounts[planName] = (planCounts[planName] || 0) + 1;
    });

    // Get recent events
    const { data: recentOutbox } = await supabase
      .from("outbox_events")
      .select("event_type, status, created_at")
      .order("created_at", { ascending: false })
      .limit(10);

    return new Response(
      JSON.stringify({
        success: true,
        metrics: {
          leads: leadsCount || 0,
          workspaces: workspacesCount || 0,
          messages: messagesCount || 0,
          automation_jobs: automationJobsCount || 0,
          active_subscriptions: activeSubscriptions.length,
          estimated_mrr: estimatedMRR,
          plan_distribution: planCounts,
        },
        referrals: {
          total_referral_sales: referralSales.length,
          unique_partners: uniquePartners,
          total_referral_revenue_cents: totalReferralRevenue,
          total_referral_revenue_usd: (totalReferralRevenue / 100).toFixed(2),
        },
        recent_events: recentOutbox || [],
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error: any) {
    console.error("Admin metrics error:", error);
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
