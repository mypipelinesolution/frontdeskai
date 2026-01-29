# Stripe Test Mode vs Live Mode - Complete Guide

## 🚨 CRITICAL: Test and Live Are Completely Separate

Stripe's test mode and live mode are **completely isolated environments**. Nothing automatically transfers between them.

---

## 📋 Your Question Answered

> "Once I test it successfully, do I need to go back in and change the price IDs to the live ones, or once I convert the sandbox products to live will it automatically know it is live?"

**Answer:** You MUST manually create new products in live mode and update all price IDs. Nothing converts automatically.

---

## 🔄 What Happens When You Switch to Live Mode

### What DOES transfer automatically:
- ✅ Your Stripe account settings
- ✅ Your business information
- ✅ Your bank account connection
- ✅ Your team member access

### What DOES NOT transfer (must be recreated):
- ❌ Products
- ❌ Prices
- ❌ Customers
- ❌ Subscriptions
- ❌ Payment methods
- ❌ Webhooks
- ❌ API keys

**You must manually recreate everything in live mode.**

---

## 📝 Step-by-Step: Test Mode Setup

### 1. Create Test Products (What You're Doing Now)

Go to: https://dashboard.stripe.com/test/products

Create 4 products:
- Starter: $104/month
- Core: $154/month
- Accelerator: $204/month
- DFY: $497/month

Copy the test price IDs (they start with `price_` and work in test mode only).

### 2. Configure Test Keys

Add to your `.env`:
```bash
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_TEST_KEY
VITE_STRIPE_PRICE_STARTER=price_YOUR_TEST_STARTER_ID
VITE_STRIPE_PRICE_CORE=price_YOUR_TEST_CORE_ID
VITE_STRIPE_PRICE_PRO=price_YOUR_TEST_PRO_ID
VITE_STRIPE_PRICE_DFY=price_YOUR_TEST_DFY_ID
```

Add to Supabase secrets:
```
STRIPE_SECRET_KEY=sk_test_YOUR_TEST_SECRET_KEY
STRIPE_PRICE_STARTER=price_YOUR_TEST_STARTER_ID
STRIPE_PRICE_CORE=price_YOUR_TEST_CORE_ID
STRIPE_PRICE_PRO=price_YOUR_TEST_PRO_ID
STRIPE_PRICE_DFY=price_YOUR_TEST_DFY_ID
```

### 3. Set Up Test Webhook

Go to: https://dashboard.stripe.com/test/webhooks

Create webhook endpoint:
- URL: `https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/stripe-webhook`
- Events: `checkout.session.completed`, `customer.subscription.updated`, etc.
- Copy test webhook secret: `whsec_YOUR_TEST_SECRET`

Add to Supabase secrets:
```
STRIPE_WEBHOOK_SECRET=whsec_YOUR_TEST_SECRET
```

### 4. Test Everything

Use test card numbers:
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- 3D Secure: `4000 0027 6000 3184`

Verify:
- Checkout works
- Webhooks fire
- Orders are created
- Bots are activated

---

## 🚀 Step-by-Step: Live Mode Setup (After Testing)

Once testing is successful, you need to **completely recreate everything in live mode**.

### 1. Create Live Products (Start Fresh)

Go to: https://dashboard.stripe.com/products (NOT /test/products)

Create the SAME 4 products again:
- Starter: $104/month
- Core: $154/month
- Accelerator: $204/month
- DFY: $497/month

**IMPORTANT:** These will have DIFFERENT price IDs than your test products!

Example:
- Test: `price_1AbC2dEfGhIjKlMn`
- Live: `price_9XyZ8wVuTsRqPoNm` (completely different ID)

### 2. Get Live API Keys

Go to: https://dashboard.stripe.com/apikeys (NOT /test/apikeys)

Copy your LIVE keys:
- Publishable key: `pk_live_...` (different from test)
- Secret key: `sk_live_...` (different from test)

### 3. Update All Environment Variables

**A. Local .env file:**
```bash
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_LIVE_KEY
VITE_STRIPE_PRICE_STARTER=price_YOUR_LIVE_STARTER_ID
VITE_STRIPE_PRICE_CORE=price_YOUR_LIVE_CORE_ID
VITE_STRIPE_PRICE_PRO=price_YOUR_LIVE_PRO_ID
VITE_STRIPE_PRICE_DFY=price_YOUR_LIVE_DFY_ID
```

**B. Supabase Secrets:**

Go to: https://supabase.com/dashboard/project/ncnimbaalexocfcqwlie/settings/vault

Update ALL secrets with live values:
```
STRIPE_SECRET_KEY=sk_live_YOUR_LIVE_SECRET_KEY
STRIPE_PRICE_STARTER=price_YOUR_LIVE_STARTER_ID
STRIPE_PRICE_CORE=price_YOUR_LIVE_CORE_ID
STRIPE_PRICE_PRO=price_YOUR_LIVE_PRO_ID
STRIPE_PRICE_DFY=price_YOUR_LIVE_DFY_ID
```

**C. Redeploy Edge Functions:**

After updating Supabase secrets, you MUST redeploy:
- `create-checkout` function
- `stripe-webhook` function

This ensures they pick up the new live keys.

### 4. Create Live Webhook

Go to: https://dashboard.stripe.com/webhooks (NOT /test/webhooks)

Create NEW webhook endpoint:
- URL: `https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/stripe-webhook`
- Events: Same as test (checkout.session.completed, etc.)
- Copy LIVE webhook secret: `whsec_YOUR_LIVE_SECRET`

Add to Supabase secrets:
```
STRIPE_WEBHOOK_SECRET=whsec_YOUR_LIVE_SECRET
```

Redeploy `stripe-webhook` function again.

### 5. Update Production Domain

In `.env` (and Supabase if needed):
```bash
VITE_APP_URL=https://frontdeskaipro.com
```

This ensures Stripe redirects to the correct domain.

---

## 🎯 Quick Reference: What Changes Between Test and Live

| Item | Test Mode | Live Mode | Must Change? |
|------|-----------|-----------|--------------|
| Products | Create in test | Create in live | ✅ YES - New IDs |
| Prices | `price_test...` | `price_live...` | ✅ YES - New IDs |
| Publishable Key | `pk_test_...` | `pk_live_...` | ✅ YES |
| Secret Key | `sk_test_...` | `sk_live_...` | ✅ YES |
| Webhook Secret | `whsec_test...` | `whsec_live...` | ✅ YES |
| Webhook URL | Same | Same | ❌ NO |
| Edge Functions | Same code | Same code | ❌ NO |
| Database Schema | Same | Same | ❌ NO |

---

## ⚠️ Common Mistakes to Avoid

### Mistake #1: Using Test Keys in Production
**Problem:** Customers can't make real payments
**Solution:** Always use `pk_live_` and `sk_live_` in production

### Mistake #2: Forgetting to Update Price IDs
**Problem:** "No such price" error in production
**Solution:** Create new products in live mode and copy the NEW price IDs

### Mistake #3: Not Redeploying Edge Functions
**Problem:** Functions still use old test keys
**Solution:** Redeploy after updating Supabase secrets

### Mistake #4: Using Test Webhook Secret in Production
**Problem:** Webhooks fail signature verification
**Solution:** Create new webhook in live mode, use new secret

### Mistake #5: Mixing Test and Live Keys
**Problem:** Inconsistent behavior, some things work, others don't
**Solution:** Ensure ALL keys (publishable, secret, webhook) match the same mode

---

## 🧪 Testing Checklist

Before going live, verify in TEST mode:

- [ ] Can create checkout session
- [ ] Checkout page loads with correct prices
- [ ] Test card payment succeeds
- [ ] Redirected to thank you page
- [ ] Webhook fires successfully
- [ ] Order created in database
- [ ] Workspace gets correct subscription tier
- [ ] Bots are automatically activated
- [ ] Customer dashboard shows active bots
- [ ] Can see order in Stripe dashboard

---

## 🚀 Go-Live Checklist

When ready for production:

- [ ] Create 4 products in LIVE mode
- [ ] Copy all 4 LIVE price IDs
- [ ] Get LIVE publishable key
- [ ] Get LIVE secret key
- [ ] Update .env with live keys and price IDs
- [ ] Update Supabase secrets with live keys and price IDs
- [ ] Redeploy `create-checkout` function
- [ ] Redeploy `stripe-webhook` function
- [ ] Create webhook in LIVE mode
- [ ] Copy LIVE webhook secret
- [ ] Update Supabase secret with live webhook secret
- [ ] Redeploy `stripe-webhook` function again
- [ ] Test with REAL card in production
- [ ] Verify webhook fires
- [ ] Verify order created
- [ ] Monitor for 24 hours

---

## 💰 Cost Implications

### Test Mode
- ✅ Free forever
- ✅ Unlimited test transactions
- ✅ No fees
- ✅ Use fake card numbers

### Live Mode
- 💳 Stripe fees apply: 2.9% + $0.30 per transaction
- 💳 Monthly subscription: same rate per payment
- 💳 Real money is processed
- 💳 Real customers are charged

---

## 🔐 Security Note

**NEVER commit live keys to git!**

Your `.env` file should be in `.gitignore` (it already is).

Live keys should ONLY exist in:
1. Your local `.env` file (never committed)
2. Supabase secrets (encrypted storage)
3. Production hosting environment variables

---

## 📞 Support

If you have issues:

**Test Mode:**
- Check: https://dashboard.stripe.com/test/logs
- Webhook logs: https://dashboard.stripe.com/test/webhooks
- No money at risk - experiment freely!

**Live Mode:**
- Check: https://dashboard.stripe.com/logs
- Webhook logs: https://dashboard.stripe.com/webhooks
- Contact Stripe support if needed
- Monitor closely after launch

---

## Summary

**Test to Live Transition = Starting Fresh in Live Mode**

1. Test mode and live mode are separate
2. You must create products again in live mode
3. All API keys are different
4. All price IDs are different
5. Webhooks must be recreated
6. Nothing converts automatically
7. You must update ALL environment variables
8. You must redeploy edge functions

**The good news:** Once configured correctly, the transition is smooth and your code doesn't change - only the configuration values.
