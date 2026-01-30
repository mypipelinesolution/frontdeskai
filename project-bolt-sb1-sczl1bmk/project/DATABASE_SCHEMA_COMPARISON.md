# Database Schema Comparison

## Tables in Your Current Database (from your schema)
1. ✅ `profiles` - EXISTS
2. ✅ `subscriptions` - EXISTS
3. ✅ `conversations` - EXISTS
4. ✅ `bot_configurations` - EXISTS
5. ✅ `demo_requests` - EXISTS
6. ✅ `affiliate_clicks` - EXISTS
7. ✅ `referrals` - EXISTS

## Tables Defined in Migrations (should exist)
1. ❌ `workspaces` - MISSING (defined in 20260126175944)
2. ❌ `leads` - MISSING (defined in 20260126175944)
3. ❌ `messages` - MISSING (defined in 20260126175944)
4. ❌ `automations` - MISSING (defined in 20260126175944)
5. ❌ `orders` - MISSING (defined in 20260126175944)
6. ❌ `family_reps` - MISSING (defined in 20260126175944)
7. ❌ `internal_payouts` - MISSING (defined in 20260126175944)
8. ❌ `locallink_outbox` - MISSING (defined in 20260126175944)
9. ❌ `webinar_bookings` - MISSING (defined in 20260129232020)
10. ❌ `webinar_interactions` - MISSING (defined in 20260129232020)
11. ❌ `webinar_conversions` - MISSING (defined in 20260129232020)
12. ❌ `automation_jobs` - MISSING (defined in 20260130000123)
13. ❌ `checkout_sessions` - MISSING (defined in 20260130000123)
14. ❌ `outbox_events` - MISSING (defined in 20260130001425)
15. ❌ `bot_response_library` - MISSING (defined in 20260130005019)
16. ❌ `dfy_playbooks` - MISSING (defined in 20260130012139)
17. ❌ `dfy_client_progress` - MISSING (defined in 20260130012139)
18. ❌ `affiliate_partners` - MISSING (defined in 20260129033651)
19. ❌ `referral_clicks` - MISSING (defined in 20260129033651)
20. ❌ `referral_conversions` - MISSING (defined in 20260129033651)
21. ❌ `partner_cert_modules` - MISSING (defined in 20260130012353)
22. ❌ `partner_cert_progress` - MISSING (defined in 20260130012353)
23. ❌ `partner_cert_exams` - MISSING (defined in 20260130012353)
24. ❌ `partner_cert_results` - MISSING (defined in 20260130012353)
25. ❌ `partner_pitch_reviews` - MISSING (defined in 20260130012353)
26. ❌ `partner_cert_renewals` - MISSING (defined in 20260130012353)
27. ❌ `partner_funnels` - MISSING (defined in 20260130012353)
28. ❌ `partner_funnel_stats` - MISSING (defined in 20260130012353)
29. ❌ `enterprise_leads` - MISSING (defined in 20260130021953)
30. ❌ `enterprise_access_tokens` - MISSING (defined in 20260130021953)
31. ❌ `enterprise_applications` - MISSING (defined in 20260130021953)
32. ❌ `enterprise_orders` - MISSING (defined in 20260130021953)
33. ❌ `enterprise_webinar_views` - MISSING (defined in 20260130021953)
34. ❌ `stripe_customers` - MISSING (defined in 20260128162047)
35. ❌ `stripe_subscriptions` - MISSING (defined in 20260128162047)
36. ❌ `stripe_orders` - MISSING (defined in 20260128162047)

## Critical Issue

**Your migrations have NOT been run on your Supabase database!**

You only have 7 tables, but the migrations define 36+ tables.

## Solution

You need to run ALL the migration files in order. The migrations are numbered chronologically:

1. `20260126174048_create_frontdesk_schema.sql`
2. `20260126175944_create_frontdesk_saas_schema.sql` ⭐ Creates `workspaces`
3. `20260126214311_add_ai_configuration_fields.sql`
4. ... (continue through all 32 migration files)

## How to Run Migrations

### Option 1: Supabase CLI (Recommended)
```bash
# Install Supabase CLI
# Then run:
supabase db push
```

### Option 2: Manual via Dashboard
1. Go to Supabase Dashboard → SQL Editor
2. Run each migration file in order (oldest to newest)
3. Start with `20260126174048_create_frontdesk_schema.sql`

## Current Workaround

I've updated `useWorkspace` hook to query `profiles` table instead of `workspaces` table so the dashboard works with your current schema.

**This is temporary** - you should run the migrations to get all features working properly.
