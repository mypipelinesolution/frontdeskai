# Complete Setup Checklist for FrontDesk AI Pro

## 🎯 Where to Add ALL Secrets

**IMPORTANT:** All API keys go into **Supabase Secrets** (NOT Stripe, NOT your .env file for edge functions)

Go to: https://supabase.com/dashboard/project/ncnimbaalexocfcqwlie/settings/vault

---

## ✅ Required Secrets (Checkout Won't Work Without These)

### 1. Stripe Secrets (6 total)

**You already have 4 of these from your screenshot:**
- ✅ `STRIPE_PRICE_STARTER`
- ✅ `STRIPE_PRICE_CORE`
- ✅ `STRIPE_PRICE_PRO`
- ✅ `STRIPE_PRICE_DFY`

**You still need 2 more:**

#### A. STRIPE_SECRET_KEY
- **Where to get it:** https://dashboard.stripe.com/test/apikeys
- **What to copy:** Your "Secret key" (starts with `sk_test_`)
- **Add to Supabase as:** `STRIPE_SECRET_KEY`
- **Status:** ❌ MISSING - Checkout will not work without this!

#### B. STRIPE_WEBHOOK_SECRET
- **Where to get it:**
  1. Go to: https://dashboard.stripe.com/test/webhooks
  2. Click "+ Add endpoint"
  3. **Endpoint URL:** `https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/stripe-webhook`
  4. **Events to select:**
     - `checkout.session.completed`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `invoice.payment_succeeded`
     - `invoice.payment_failed`
  5. Click "Add endpoint"
  6. Copy the **Signing secret** (starts with `whsec_`)
- **Add to Supabase as:** `STRIPE_WEBHOOK_SECRET`
- **Status:** ❌ MISSING - Payments won't be processed without this!

---

## 🤖 Optional Secrets (Features Work Without These, But Limited)

### 2. OpenAI (For AI Chat Features)

You mentioned you created an OpenAI account - great!

#### OPENAI_API_KEY
- **Where to get it:** https://platform.openai.com/api-keys
- **What to do:**
  1. Click "Create new secret key"
  2. Give it a name (e.g., "FrontDesk AI Pro")
  3. Copy the key (starts with `sk-`)
- **Add to Supabase as:** `OPENAI_API_KEY`
- **Status:** ⚠️ OPTIONAL - Without this, chat widget will show generic responses
- **What it powers:**
  - AI chat conversations on your website
  - Smart lead qualification
  - Automated customer responses

### 3. Twilio (For SMS/Voice Features)

You mentioned you created a Twilio account!

#### Three Twilio secrets needed:

**A. TWILIO_ACCOUNT_SID**
- **Where to get it:** https://console.twilio.com/ (on dashboard homepage)
- **Add to Supabase as:** `TWILIO_ACCOUNT_SID`

**B. TWILIO_AUTH_TOKEN**
- **Where to get it:** Same page as Account SID (click "Show" to reveal)
- **Add to Supabase as:** `TWILIO_AUTH_TOKEN`

**C. TWILIO_PHONE_NUMBER**
- **Where to get it:**
  1. Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/incoming
  2. If you don't have one, click "Buy a number" (Twilio trial gives you one free)
  3. Copy your phone number (format: +1234567890)
- **Add to Supabase as:** `TWILIO_PHONE_NUMBER`
- **Status:** ⚠️ OPTIONAL - Without these, SMS features won't send actual texts
- **What it powers:**
  - Automated SMS replies
  - Missed call text-back
  - Appointment reminders
  - Lead nurture campaigns

### 4. SendGrid (For Email Features)

You mentioned you created a SendGrid account!

#### SENDGRID_API_KEY
- **Where to get it:**
  1. Go to: https://app.sendgrid.com/settings/api_keys
  2. Click "Create API Key"
  3. Name it: "FrontDesk AI Pro"
  4. Choose "Restricted Access" or "Full Access"
  5. If restricted, enable: "Mail Send" permission
  6. Copy the API key (starts with `SG.`)
- **Add to Supabase as:** `SENDGRID_API_KEY`
- **Status:** ⚠️ OPTIONAL - Without this, email features won't send actual emails
- **What it powers:**
  - Automated email follow-ups
  - Lead nurture emails
  - Appointment confirmations
  - Review requests

---

## 📋 Complete Secret List for Supabase

Here's every secret you need to add to Supabase vault:

### REQUIRED (Must have for checkout):
1. `STRIPE_SECRET_KEY` - Your Stripe secret key
2. `STRIPE_WEBHOOK_SECRET` - Webhook signing secret
3. `STRIPE_PRICE_STARTER` - ✅ You have this
4. `STRIPE_PRICE_CORE` - ✅ You have this
5. `STRIPE_PRICE_PRO` - ✅ You have this
6. `STRIPE_PRICE_DFY` - ✅ You have this

### OPTIONAL (Add for full functionality):
7. `OPENAI_API_KEY` - For AI chat
8. `TWILIO_ACCOUNT_SID` - For SMS
9. `TWILIO_AUTH_TOKEN` - For SMS
10. `TWILIO_PHONE_NUMBER` - For SMS
11. `SENDGRID_API_KEY` - For email

---

## 🚀 Step-by-Step Setup Process

### Phase 1: Get Checkout Working (Do This First!)

1. **Add STRIPE_SECRET_KEY to Supabase:**
   - Get from: https://dashboard.stripe.com/test/apikeys
   - Add to: https://supabase.com/dashboard/project/ncnimbaalexocfcqwlie/settings/vault
   - Secret name: `STRIPE_SECRET_KEY`

2. **Add STRIPE_WEBHOOK_SECRET to Supabase:**
   - Create webhook at: https://dashboard.stripe.com/test/webhooks
   - Endpoint URL: `https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/stripe-webhook`
   - Add events (see list above)
   - Copy signing secret
   - Add to Supabase as: `STRIPE_WEBHOOK_SECRET`

3. **Tell me when done!**
   - I'll redeploy the edge functions
   - Then test checkout with test card: `4242 4242 4242 4242`

### Phase 2: Add AI Features (Do This Second)

4. **Add OpenAI API Key:**
   - Get from: https://platform.openai.com/api-keys
   - Add to Supabase as: `OPENAI_API_KEY`

5. **Tell me when done!**
   - I'll redeploy the ai-chat function
   - Then test the chat widget

### Phase 3: Add Communication Features (Optional)

6. **Add Twilio credentials (all 3):**
   - Get from: https://console.twilio.com/
   - Add all 3 to Supabase

7. **Add SendGrid API key:**
   - Get from: https://app.sendgrid.com/settings/api_keys
   - Add to Supabase

8. **Tell me when done!**
   - I'll redeploy send-sms and send-email functions
   - Then test SMS and email features

---

## ⚠️ Important Notes

### About Edge Functions
- Edge functions DON'T use your local `.env` file
- Edge functions ONLY access Supabase secrets
- After adding secrets, functions MUST be redeployed
- I'll handle all redeployments for you

### About Test vs Live Mode

**You're currently in TEST mode** (which is correct for setup):
- Stripe: Use test keys (`sk_test_`, `pk_test_`)
- Test card: `4242 4242 4242 4242`
- No real charges happen

**Before going live:**
- Switch all secrets to live versions
- Update Stripe keys to live (`sk_live_`, `pk_live_`)
- Create live products in Stripe
- Update webhook to use live mode
- I'll create a separate guide for going live

### What Works Without Optional Keys?

Without OpenAI, Twilio, SendGrid:
- ✅ Checkout works (takes payments)
- ✅ Database records created
- ✅ User accounts created
- ✅ Dashboard works
- ❌ AI chat shows generic responses
- ❌ SMS features log but don't send
- ❌ Email features log but don't send

---

## 🧪 Testing Checklist

After adding secrets and I redeploy:

### Test 1: Checkout Flow
- [ ] Click "Get Started" button on landing page
- [ ] Redirects to Stripe checkout
- [ ] Shows correct price
- [ ] Use test card: 4242 4242 4242 4242
- [ ] Completes payment
- [ ] Redirects to thank-you page
- [ ] Order created in Supabase database

### Test 2: AI Chat (if OpenAI added)
- [ ] Open chat widget on site
- [ ] Send a message
- [ ] Get intelligent AI response
- [ ] Lead created in database

### Test 3: SMS (if Twilio added)
- [ ] Trigger SMS from dashboard
- [ ] Receive actual text message
- [ ] Message logged in database

### Test 4: Email (if SendGrid added)
- [ ] Trigger email from dashboard
- [ ] Receive actual email
- [ ] Message logged in database

---

## 💡 Quick Start Recommendation

**Do this in order:**

1. **TODAY:** Add the 2 missing Stripe secrets (takes 5 minutes)
2. **TODAY:** Let me redeploy and test checkout works
3. **TOMORROW:** Add OpenAI key for AI chat (takes 3 minutes)
4. **LATER:** Add Twilio + SendGrid when ready for full features

This way you can start taking payments TODAY, then add features gradually!

---

## 📞 Next Step

**Tell me:** "I've added STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET"

Then I'll:
1. Redeploy the edge functions
2. Test the checkout flow
3. Confirm everything works
4. Give you the test card details

You're SO close! Just 2 more secrets and checkout will work!
