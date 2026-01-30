import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import Stripe from "npm:stripe@14.3.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface CheckoutRequest {
  tier: 'regional' | 'agency' | 'custom';
  partner_slug?: string;
  setup_fee_cents: number;
  monthly_fee_cents: number;
  per_unit_fee_cents: number;
}

const TIER_NAMES = {
  regional: 'Regional Operator',
  agency: 'Agency Network',
  custom: 'Enterprise Custom',
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
      apiVersion: "2023-10-16",
    });

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const {
      tier,
      partner_slug,
      setup_fee_cents,
      monthly_fee_cents,
      per_unit_fee_cents,
    }: CheckoutRequest = await req.json();

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: `${TIER_NAMES[tier]} - Setup Fee`,
              description: "One-time setup and onboarding fee",
            },
            unit_amount: setup_fee_cents,
          },
          quantity: 1,
        },
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: `${TIER_NAMES[tier]} - First Month`,
              description: "Monthly license fee (first month)",
            },
            unit_amount: monthly_fee_cents,
          },
          quantity: 1,
        },
      ],
      success_url: `${Deno.env.get("PUBLIC_SITE_URL") || "https://frontdeskaipro.com"}/enterprise/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${Deno.env.get("PUBLIC_SITE_URL") || "https://frontdeskaipro.com"}/enterprise/offer`,
      metadata: {
        type: "enterprise",
        tier,
        partner_slug: partner_slug || "",
        setup_fee_cents: setup_fee_cents.toString(),
        monthly_fee_cents: monthly_fee_cents.toString(),
        per_unit_fee_cents: per_unit_fee_cents.toString(),
      },
    });

    const { error: orderError } = await supabase
      .from("enterprise_orders")
      .insert({
        tier,
        partner_slug,
        setup_fee_cents,
        monthly_fee_cents,
        per_unit_fee_cents,
        stripe_session_id: session.id,
        status: "pending",
      });

    if (orderError) {
      console.error("Failed to create order:", orderError);
    }

    return new Response(
      JSON.stringify({ url: session.url }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Error in enterprise-checkout:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
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
