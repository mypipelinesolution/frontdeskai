# Checkout Debugging Guide

## What I Just Fixed

I added **comprehensive logging** to both the frontend and backend. When you click a pricing button now, you'll see EXACTLY what's happening in the browser console.

## How to Debug

### Step 1: Open Browser Console
1. Open your site: http://localhost:5173
2. Press **F12** to open Developer Tools
3. Click the **Console** tab
4. Click any "Get Started" button

### Step 2: Read the Logs

You'll see logs like this:

```
=== CHECKOUT DEBUG START ===
Price ID: price_1StsFsPbfTJTNa5AOU7efEPQ
Product: FrontDesk AI Pro — Starter
Supabase URL: https://ncnimbaalexocfcqwlie.supabase.co
Request body: {price_id: "price_1StsFsPbfTJTNa5AOU7efEPQ"}
Response status: 200 (or 500)
Response text: {...}
```

### Step 3: Identify the Error

#### Error Type 1: "Stripe secret key not configured"
**What you'll see:**
```
Response status: 500
Error: Stripe secret key not configured
```

**How to fix:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `ncnimbaalexocfcqwlie`
3. Go to **Settings** → **Edge Functions** → **Secrets**
4. Add secret:
   - Name: `STRIPE_SECRET_KEY`
   - Value: Your Stripe secret key (starts with `sk_test_` for test mode)
5. Click "Add Secret"

#### Error Type 2: "Invalid price ID"
**What you'll see:**
```
Response status: 500
Error: No such price: 'price_xxx'
```

**How to fix:**
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/test/products)
2. Check that your products exist and are active
3. Copy the **Price ID** from each product
4. Update `.env` file in your project:
   ```
   VITE_STRIPE_PRICE_STARTER=price_YOUR_ACTUAL_PRICE_ID
   VITE_STRIPE_PRICE_CORE=price_YOUR_ACTUAL_PRICE_ID
   VITE_STRIPE_PRICE_PRO=price_YOUR_ACTUAL_PRICE_ID
   VITE_STRIPE_PRICE_DFY=price_YOUR_ACTUAL_PRICE_ID
   ```
5. Also update `src/stripe-config.ts` with the correct price IDs

#### Error Type 3: CORS Error
**What you'll see:**
```
Access to fetch has been blocked by CORS policy
```

**This shouldn't happen** - the function has CORS headers. If you see this:
1. The edge function isn't deployed properly
2. Redeploy it (I already did this, so shouldn't be an issue)

#### Error Type 4: Network Error
**What you'll see:**
```
Failed to fetch
TypeError: NetworkError
```

**This means:**
- Edge function doesn't exist or isn't deployed
- Wrong URL
- Internet connection issue

## Quick Test - Direct API Call

Open your browser console and paste this:

```javascript
fetch('https://ncnimbaalexocfcqwlie.supabase.co/functions/v1/create-checkout', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ price_id: 'price_1StsFsPbfTJTNa5AOU7efEPQ' })
})
.then(r => r.json())
.then(data => console.log('SUCCESS:', data))
.catch(err => console.error('ERROR:', err));
```

### Expected Responses:

**Success:**
```json
{
  "sessionId": "cs_test_...",
  "url": "https://checkout.stripe.com/c/pay/cs_test_..."
}
```

**Error - No Stripe Key:**
```json
{
  "error": "Stripe secret key not configured"
}
```

**Error - Invalid Price:**
```json
{
  "error": "Failed to create checkout session: No such price: 'price_xxx'"
}
```

## Common Issues and Solutions

### Issue: "checkout.stripe.com refused to connect"

This means the checkout session WAS created successfully, but there's something wrong with the Stripe checkout URL.

**Possible causes:**
1. You're using a **Live mode** price ID but your STRIPE_SECRET_KEY is **Test mode** (or vice versa)
2. The Stripe account that created the price is different from the account the secret key belongs to

**How to verify:**
- Test keys start with: `sk_test_`
- Live keys start with: `sk_live_`
- Test price IDs: `price_1...` (created in test mode)
- Live price IDs: `price_1...` (created in live mode)

**Fix:**
Make sure both are in the same mode (test or live).

### Issue: Button spins forever, no logs

**Cause:** JavaScript error before fetch happens

**Fix:**
1. Check console for red errors
2. Make sure `.env` file has VITE_SUPABASE_URL set

### Issue: Get an alert "No checkout URL received"

**Cause:** API call succeeded but returned unexpected format

**Fix:**
Check the full console output - there will be logs showing what was received

## The Root Cause

Based on your screenshot showing "checkout.stripe.com refused to connect", the most likely issue is:

**Your Stripe secret key and price IDs are from different Stripe accounts or different modes (test/live)**

### How to Fix This RIGHT NOW:

1. **Check your Stripe Dashboard:**
   - Are you in [Test Mode](https://dashboard.stripe.com/test/dashboard) or [Live Mode](https://dashboard.stripe.com/dashboard)?
   - Top of page shows "Test mode" or "Live mode"

2. **Get matching keys:**
   - If in Test Mode:
     - Secret Key: Go to [API Keys (Test)](https://dashboard.stripe.com/test/apikeys)
     - Price IDs: Go to [Products (Test)](https://dashboard.stripe.com/test/products)
   - If in Live Mode:
     - Secret Key: Go to [API Keys (Live)](https://dashboard.stripe.com/apikeys)
     - Price IDs: Go to [Products (Live)](https://dashboard.stripe.com/products)

3. **Update Supabase Secret:**
   - Supabase Dashboard → Settings → Edge Functions → Secrets
   - Update `STRIPE_SECRET_KEY` with the key from step 2

4. **Verify Price IDs match:**
   - Your `.env` price IDs should match the mode you're using

## Need More Help?

After clicking the button, **copy ALL the console output** and share it. The enhanced logging will show exactly what's failing.

The logs now show:
- ✓ Exact API endpoint called
- ✓ Request body sent
- ✓ Response status code
- ✓ Full response body
- ✓ Parsed data
- ✓ Exact error messages

This makes it impossible NOT to find the issue!
