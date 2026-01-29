# Stripe Integration Setup

## 🚨 CRITICAL: Must Complete Before Going Live

Your application is fully integrated with Stripe, but you MUST configure the following before it will work:

### Current Error
The error "No such price" means you need to create products in Stripe and add the price IDs to your configuration.

---

## ✅ What's Already Built

All payment buttons throughout the app are connected to Stripe:

### Landing Page (`/`)
- ✅ "Get Started" button (header)
- ✅ "Request Demo" form submission → Core plan
- ✅ Starter plan card → Checkout
- ✅ Core plan card → Checkout
- ✅ Accelerator plan card → Checkout
- ✅ "Start DFY Setup" button → DFY plan checkout
- ✅ Add-on bot "Add to Plan" buttons (shows alert, can be enhanced later)

### Pricing Page (`/pricing`)
- ✅ All plan cards connect to Stripe checkout
- ✅ Add-on bot cards (shows alert, can be enhanced later)

### Edge Functions
- ✅ `create-checkout` - Creates Stripe checkout sessions
- ✅ `stripe-webhook` - Handles Stripe events (subscriptions, payments, cancellations)

---

## 📋 STEP 1: Create Products in Stripe

1. Go to: https://dashboard.stripe.com/test/products
2. Click "Add product" for each plan:

### Product 1: Starter Plan
- Name: `FrontDesk AI Pro - Starter`
- Description: `24/7 AI Chat & SMS, Call Answering, Basic CRM`
- Pricing model: `Recurring`
- Price: `$104.00 USD`
- Billing period: `Monthly`
- Click "Save product"
- **Copy the Price ID** (starts with `price_...`)

### Product 2: Core Plan
- Name: `FrontDesk AI Pro - Core`
- Description: `24/7 AI Front Desk, SMS & Email Campaigns, Smart Booking`
- Pricing model: `Recurring`
- Price: `$154.00 USD`
- Billing period: `Monthly`
- Click "Save product"
- **Copy the Price ID**

### Product 3: Accelerator Plan
- Name: `FrontDesk AI Pro - Accelerator`
- Description: `Full Automation Suite, Advanced Lead Nurturing AI`
- Pricing model: `Recurring`
- Price: `$204.00 USD`
- Billing period: `Monthly`
- Click "Save product"
- **Copy the Price ID**

### Product 4: DFY Setup
- Name: `FrontDesk AI Pro - DFY Setup`
- Description: `White Glove Setup - We do everything for you`
- Pricing model: `Recurring`
- Price: `$497.00 USD`
- Billing period: `Monthly`
- Click "Save product"
- **Copy the Price ID**

---

## 📝 STEP 2: Configure Supabase Secrets

**IMPORTANT:** All Stripe configuration is done in Supabase Dashboard. The frontend does NOT need a publishable key because we use the Checkout Session redirect flow (not Stripe.js directly).

### Update Supabase Secrets (CRITICAL)

Go to: https://supabase.com/dashboard/project/ncnimbaalexocfcqwlie/settings/vault

Add or update these secrets:

```
STRIPE_SECRET_KEY              # Get from https://dashboard.stripe.com/test/apikeys (sk_test_...)
STRIPE_WEBHOOK_SECRET          # Get after creating webhook (see Step 3)
STRIPE_PRICE_STARTER           # Price ID from Product 1
STRIPE_PRICE_CORE              # Price ID from Product 2
STRIPE_PRICE_PRO               # Price ID from Product 3
STRIPE_PRICE_DFY               # Price ID from Product 4
```

**IMPORTANT:** After adding secrets, you MUST redeploy edge functions for them to take effect!

---

## 🪝 STEP 3: Configure Webhook

### 2. Configure Webhook

Go to: https://dashboard.stripe.com/test/webhooks

1. Click "Add endpoint"
2. Enter URL: `https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/stripe-webhook`
3. Select these events:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy the "Signing secret" (starts with `whsec_...`)
5. Add it to Supabase secrets as `STRIPE_WEBHOOK_SECRET`

---

## 🧪 Testing

1. Click any "Get Started" button on the landing page
2. You should be redirected to Stripe Checkout
3. Use test card: `4242 4242 4242 4242`
4. After successful payment, you'll be redirected to `/thank-you`
5. Webhook will create order record and handle referral tracking

---

## 🔄 What Happens on Purchase

1. User clicks payment button
2. `create-checkout` edge function creates Stripe session
3. User completes payment on Stripe
4. Stripe sends webhook to `stripe-webhook` function
5. Function creates order record in database
6. If referral slug exists:
   - Family rep → Creates internal payout (80% commission)
   - Partner → Syncs to LocalLink (10-20% commission)

---

## 🎯 Next Steps for Add-ons

To enable add-on purchases after signup:
1. Create Stripe products for each add-on bot
2. Add price IDs to Supabase secrets (e.g., `VITE_STRIPE_PRICE_ADDON_SOCIAL`)
3. Update the "Add to Plan" button handler to create checkout with add-on price
4. Allow customers to manage subscriptions via customer portal

---

## 📞 Support

If you have any issues:
- Check Supabase logs: https://supabase.com/dashboard/project/ncnimbaalexocfcqwlie/logs
- Check Stripe webhook logs: https://dashboard.stripe.com/test/webhooks
- Verify all secrets are properly set in Supabase vault
