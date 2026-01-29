# Setup Priority Order - Do This First!

Complete these tasks in order for a fully functional platform:

## 🔴 CRITICAL - Do First (10 minutes)

### 1. Create Database Tables
**Why**: Nothing works without the database

**How**:
1. Open: https://supabase.com/dashboard/project/fcklhskfhtfzpuolmesq/sql/new
2. Copy ALL contents from `SETUP_DATABASE.sql`
3. Paste and click "Run"
4. Wait for "Database setup complete!" message

**This enables**:
- ✅ User signup/login
- ✅ Demo request form
- ✅ Subscription tracking
- ✅ Bot configurations
- ✅ Conversation history

### 2. Enable Email Authentication
**Why**: Users need to sign up and login

**How**:
1. Go to: https://supabase.com/dashboard/project/fcklhskfhtfzpuolmesq/auth/providers
2. Enable "Email" provider
3. Turn OFF "Confirm email" (for faster testing)
4. Click "Save"

**This enables**:
- ✅ User registration
- ✅ User login
- ✅ Password reset

## 🟡 IMPORTANT - Do Second (15 minutes)

### 3. Configure Stripe for Payments
**Why**: To accept payments and manage subscriptions

**How**: See `STRIPE_SETUP.md` for complete instructions
1. Get Stripe secret key from dashboard
2. Create webhook endpoint
3. Add both to Supabase environment variables

**This enables**:
- ✅ Checkout flow
- ✅ Subscription management
- ✅ Payment webhooks
- ✅ Automatic subscription updates

### 4. Setup Brevo Email (Optional but Recommended)
**Why**: To send transactional emails to customers

**How**: Follow these guides in order:
1. `BREVO_DNS_SETUP.md` - Add DNS records to your domain
2. `BREVO_EMAIL_SETUP.md` - Configure Brevo API and deploy function

**This enables**:
- ✅ Welcome emails
- ✅ Demo request confirmations
- ✅ Password reset emails
- ✅ Subscription receipts
- ✅ Lead notifications

## 🟢 NICE TO HAVE - Do Later

### 5. Customize Branding
- Update logo in `/public/logo.png`
- Modify colors in `tailwind.config.js`
- Edit copy on homepage

### 6. Add Your Stripe Products
- Update `src/stripe-config.ts` with your product IDs
- Modify pricing tiers

### 7. Configure Email Templates
- Create branded templates in Brevo dashboard
- Set up automated email sequences

## Quick Test After Steps 1-2

After completing steps 1 and 2, test these:

**Test 1: Demo Request**
1. Go to homepage
2. Click "Request a Demo"
3. Fill out form and submit
4. Check Supabase dashboard → Table Editor → demo_requests
5. Should see your request

**Test 2: User Signup**
1. Click "Sign Up"
2. Enter email and password
3. Click "Create Account"
4. Should redirect to dashboard
5. Check Supabase dashboard → Authentication → Users
6. Should see your user account

**Test 3: Database is Working**
```bash
# In Supabase SQL Editor, run:
SELECT COUNT(*) as table_count
FROM information_schema.tables
WHERE table_schema = 'public';

# Should return 7 or more tables
```

## Current Status

Your project has:
- ✅ Supabase credentials configured in `.env`
- ✅ Email function updated for Brevo
- ✅ Database schema ready to deploy
- ✅ All code built and ready
- ⏳ Database tables need creation (Step 1)
- ⏳ Auth needs enabling (Step 2)
- ⏳ Stripe needs configuration (Step 3)
- ⏳ Email needs DNS setup (Step 4)

## Time Estimates

- Step 1: 2 minutes
- Step 2: 2 minutes
- Step 3: 10 minutes (see STRIPE_SETUP.md)
- Step 4: 30 minutes (includes DNS propagation wait time)

**Total active time: ~15 minutes**
**Total wait time: ~30 minutes (for DNS)**

## What's Already Working

Even without setup, these work:
- ✅ Homepage displays correctly
- ✅ Pricing page shows plans
- ✅ UI is fully functional
- ✅ Demo chat simulation works
- ✅ Navigation works

## Support Resources

All documentation is in your project:
- `QUICK_START_GUIDE.md` - Overall setup guide
- `SETUP_DATABASE.sql` - Database creation script
- `STRIPE_SETUP.md` - Payment configuration
- `BREVO_DNS_SETUP.md` - DNS record instructions
- `BREVO_EMAIL_SETUP.md` - Email integration guide

## Questions?

**"Do I need to do all steps now?"**
No! Do steps 1-2 now (5 minutes), then steps 3-4 when ready to accept payments and send emails.

**"Can I test without Stripe?"**
Yes! Steps 1-2 let you test user accounts, demo requests, and most features. Stripe is only needed for actual payments.

**"Is Brevo required?"**
No, it's optional. The platform works without it, but you won't be able to send transactional emails to users.

**"How long does DNS take?"**
DNS changes typically propagate in 15-60 minutes, but can take up to 48 hours in rare cases.

Start with Step 1 now - it takes 2 minutes and unlocks most features!
