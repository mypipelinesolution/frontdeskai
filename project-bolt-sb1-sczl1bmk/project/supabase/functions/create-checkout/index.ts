import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface CheckoutRequest {
  plan?: string;
  plan_key?: string;
  price_id?: string;
  referral_slug?: string;
}

const PLAN_PRICE_IDS: Record<string, string> = {
  fd_starter: Deno.env.get("STRIPE_PRICE_STARTER") || "",
  fd_core: Deno.env.get("STRIPE_PRICE_CORE") || "",
  fd_pro: Deno.env.get("STRIPE_PRICE_PRO") || "",
  fd_dfy: Deno.env.get("STRIPE_PRICE_DFY") || "",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
    const APP_URL = Deno.env.get("VITE_APP_URL") || Deno.env.get("APP_URL") || "http://localhost:5173";

    console.log("=== CREATE CHECKOUT DEBUG ===");
    console.log("STRIPE_SECRET_KEY exists:", !!STRIPE_SECRET_KEY);
    console.log("APP_URL:", APP_URL);

    if (!STRIPE_SECRET_KEY) {
      console.error("ERROR: Stripe secret key not configured");
      throw new Error("Stripe secret key not configured");
    }

    const body: CheckoutRequest = await req.json();
    const { plan, plan_key, price_id, referral_slug } = body;

    const planKey = plan || plan_key;
    let priceId = price_id;

    // If no price_id provided, try to get it from plan_key
    if (!priceId && planKey) {
      priceId = PLAN_PRICE_IDS[planKey];
    }

    // Now check if we have a price_id
    if (!priceId) {
      return new Response(
        JSON.stringify({ error: "Missing price_id or valid plan_key" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const checkoutParams = {
      "mode": "subscription",
      "line_items[0][price]": priceId,
      "line_items[0][quantity]": "1",
      "success_url": `${APP_URL}/thank-you`,
      "cancel_url": `${APP_URL}/pricing${referral_slug ? `?ref=${referral_slug}` : ""}`,
      "metadata[platform]": "frontdesk",
      "metadata[plan_key]": planKey || "",
      "metadata[payout_system]": "locallink",
      "metadata[referral_slug]": referral_slug || "",
    };

    console.log("Stripe checkout params:", checkoutParams);
    console.log("Price ID being used:", priceId);

    const stripeResponse = await fetch("https://api.stripe.com/v1/checkout/sessions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${STRIPE_SECRET_KEY}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams(checkoutParams).toString(),
    });

    console.log("Stripe API response status:", stripeResponse.status);

    if (!stripeResponse.ok) {
      const errorText = await stripeResponse.text();
      console.error("Stripe API error response:", errorText);
      console.error("Price ID used:", priceId);
      console.error("Plan key:", planKey);

      let errorMessage = "Failed to create checkout session";
      try {
        const errorJson = JSON.parse(errorText);
        errorMessage = errorJson.error?.message || errorMessage;
      } catch {
        errorMessage = errorText;
      }

      throw new Error(errorMessage);
    }

    const session = await stripeResponse.json();
    console.log("Stripe session created successfully:");
    console.log("- Session ID:", session.id);
    console.log("- URL:", session.url);
    console.log("- Mode:", session.mode);
    console.log("- Status:", session.status);

    return new Response(
      JSON.stringify({ sessionId: session.id, url: session.url }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Checkout error:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
