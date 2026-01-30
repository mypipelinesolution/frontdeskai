import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface RegisterRequest {
  lead_id: string;
  email: string;
  name: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { lead_id, email, name }: RegisterRequest = await req.json();

    const tokenValue = generateSecureToken();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const { data: token, error: tokenError } = await supabase
      .from("enterprise_access_tokens")
      .insert({
        lead_id,
        email,
        token: tokenValue,
        expires_at: expiresAt.toISOString(),
      })
      .select()
      .single();

    if (tokenError) throw tokenError;

    const replayUrl = `${Deno.env.get("PUBLIC_SITE_URL") || "https://frontdeskaipro.com"}/enterprise/replay?t=${tokenValue}`;
    const offerUrl = `${Deno.env.get("PUBLIC_SITE_URL") || "https://frontdeskaipro.com"}/enterprise/offer`;
    const applyUrl = `${Deno.env.get("PUBLIC_SITE_URL") || "https://frontdeskaipro.com"}/enterprise/apply`;

    const brevoApiKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoApiKey) {
      console.warn("BREVO_API_KEY not set, skipping email");
    } else {
      const emailResponse = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "api-key": brevoApiKey,
        },
        body: JSON.stringify({
          sender: {
            name: "FrontDesk AI Pro Enterprise",
            email: "enterprise@frontdeskaipro.com",
          },
          to: [{ email, name }],
          subject: "Your Enterprise Demo Replay + Offer Access",
          htmlContent: `
            <!DOCTYPE html>
            <html>
            <head>
              <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
                .content { background: #f8f9fa; padding: 30px; }
                .button { display: inline-block; padding: 15px 30px; background: #2563eb; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 10px 0; }
                .footer { text-align: center; padding: 20px; color: #666; font-size: 14px; }
                .expiry { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h1>Your Enterprise Demo Access</h1>
                  <p>Welcome to FrontDesk AI Pro Enterprise</p>
                </div>
                <div class="content">
                  <p>Hi ${name},</p>
                  <p>Thank you for your interest in FrontDesk AI Pro Enterprise! Your personal replay link is ready.</p>

                  <div class="expiry">
                    <strong>⏰ Access expires in 7 days</strong><br/>
                    This link will expire on ${expiresAt.toLocaleDateString()}
                  </div>

                  <h2>🎥 Watch the Full Demo</h2>
                  <p>See how agencies and operators launch their own AI platform in 30 days:</p>
                  <a href="${replayUrl}" class="button">Watch Demo Replay</a>

                  <h2>📋 What's Included:</h2>
                  <ul>
                    <li>Full 45-minute platform walkthrough</li>
                    <li>Live bot demonstrations</li>
                    <li>Revenue model breakdown</li>
                    <li>Real customer case studies</li>
                    <li>Implementation timeline</li>
                  </ul>

                  <h2>🚀 Ready to Move Forward?</h2>
                  <p>
                    <a href="${offerUrl}" class="button">View Enterprise Tiers</a>
                    <a href="${applyUrl}" class="button">Apply for License</a>
                  </p>

                  <p>Questions? Reply to this email or call us at <strong>(555) 123-4567</strong></p>
                </div>
                <div class="footer">
                  <p>FrontDesk AI Pro Enterprise<br/>
                  enterprise@frontdeskaipro.com</p>
                  <p><em>This link is personal to you and expires in 7 days</em></p>
                </div>
              </div>
            </body>
            </html>
          `,
        }),
      });

      if (!emailResponse.ok) {
        console.error("Email send failed:", await emailResponse.text());
      }
    }

    return new Response(
      JSON.stringify({ success: true, token: tokenValue }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Error in enterprise-register:", error);
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

function generateSecureToken(): string {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return btoa(String.fromCharCode(...array))
    .replace(/\//g, "_")
    .replace(/\+/g, "-")
    .replace(/=/g, "");
}
