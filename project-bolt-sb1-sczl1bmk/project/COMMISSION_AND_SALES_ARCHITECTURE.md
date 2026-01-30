# Commission & Sales Architecture - Final Clarification

## 🎯 CRITICAL: What FrontDesk Does vs. What Local-Link Does

### ✅ FrontDesk AI Pro (This System)
**ONLY Does:**
1. Captures partner referral slug from URL (`?ref=partner-slug`)
2. Stores it throughout customer journey
3. Attaches it to every Stripe checkout
4. Forwards sale data to Local-Link
5. **THAT'S IT.**

**Does NOT:**
- ❌ Calculate commissions
- ❌ Store commission rates
- ❌ Store partner tiers (10%/15%/20%)
- ❌ Handle payouts
- ❌ Process payroll
- ❌ Manage partner accounts

### ✅ Local-Link (Your Commission Engine)
**Handles:**
1. Partner tiers and commission rates
2. Commission calculation based on subscription tier
3. Payout processing
4. Revenue dashboards
5. Partner CRM and statements
6. Tax records
7. Family/staff overrides

---

## 🔗 The Only Connection Point

**The unique partner link slug is the ONLY identifier.**

```
FrontDesk captures: "taylor-abc123"
                        ↓
FrontDesk forwards to Local-Link: "taylor-abc123"
                        ↓
Local-Link looks up: partner with slug "taylor-abc123"
                        ↓
Local-Link checks: what tier is this partner?
                        ↓
Local-Link calculates: 10%, 15%, or 20% commission
                        ↓
Local-Link pays: partner gets paid
```

**FrontDesk never knows or cares about the percentage.**

---

## 📊 What FrontDesk Sends to Local-Link

Every sale creates an outbox event with:

```json
{
  "event_id": "uuid",
  "event_type": "sale.paid",
  "created_at": "2024-01-15T10:30:00Z",
  "workspace_id": "uuid",
  "payload": {
    "referral_partner_link_slug": "taylor-abc123",  // ← THE KEY
    "stripe_customer_id": "cus_...",
    "stripe_subscription_id": "sub_...",
    "plan_key": "core",
    "addon_key": null,
    "amount": 15400,  // cents
    "currency": "usd",
    "product_type": "subscription"
  }
}
```

**Local-Link receives this and handles everything else.**

---

## 🚫 What Bots Must NEVER Say

All sales bots, chat bots, and marketing must follow:

### ❌ NEVER Mention:
- Commission percentages
- Partner tiers
- Payout amounts
- Earnings potential (for partners)
- "You'll make X% per sale"

### ✅ ALWAYS Focus On:
- Product features and benefits
- Pricing for end customers
- Value proposition
- Results and ROI
- "Never miss a lead" / "24/7 AI Front Desk"

---

## 🎯 Updated Bot Rules

### Sales Closer Bot
**Can say:**
- "Most businesses choose Core at $154/mo"
- "Want me to activate this for you now?"
- "This pays for itself with 1-2 recovered leads"

**Cannot say:**
- Anything about commissions or referral earnings

### Partner Recruiter Bot
**Can say:**
- "Get your unique referral link"
- "Track your sales in your Local-Link dashboard"
- "Earn recurring income"

**Cannot say:**
- Specific percentages
- Commission structure
- Tier details

---

## 🏗️ Sales & Marketing System Overview

Based on your playbooks, here's the complete architecture:

### 1. Traffic Sources
- Facebook Ads → Webinar page
- Instagram Ads → Webinar page
- Partner links → Direct to homepage or pricing
- Messenger/DM → Sales Closer Bot

### 2. Conversion Funnels

**Funnel A - Direct:**
```
Ad → Landing Page → Chat Bot → Checkout → Stripe → Activated
```

**Funnel B - Webinar:**
```
Ad → Webinar Page → AI Webinar Host Bot → Checkout → Stripe → Activated
```

**Funnel C - Partner:**
```
Partner Link → Chat/Webinar → Checkout (with ref slug) → Stripe → Local-Link
```

### 3. Bot Ecosystem (From Your Playbooks)

**Core Sales Bots:**
1. **Sales Closer Bot** - Qualifies and closes in chat/DM
2. **Webinar Host Bot** - Runs 12-min demo webinars 24/7
3. **Upsell Engine Bot** - Promotes upgrades every 14 days
4. **Churn Prevention Bot** - Retains at-risk customers

**Growth Bots:**
5. **Ad Optimizer Bot** - Weekly ad performance optimization
6. **Growth Strategist Bot** - Business scenario planning
7. **Partner Recruiter Bot** - Recruits new partners
8. **Partner Success Coach Bot** - Helps partners succeed

**Operations Bots:**
9. **Referral Forwarder Bot** - Ensures slug tracking (NO commission calc)
10. **Onboarding Bot** - Trains new customer Business Brain

### 4. Weekly Optimization Loop

**Every Sunday 7pm:**
```
Ad Optimizer Bot runs:
  ↓
Analyzes: CTR, CPL, CVR
  ↓
Kills worst ad
  ↓
Promotes best ad
  ↓
Generates 2 new variants
  ↓
Pushes to Meta API
```

**Every 14 Days:**
```
Upsell Engine checks:
  ↓
High call volume? → Recommend Accelerator
  ↓
Many DMs? → Recommend Social Bot
  ↓
Low bookings? → Recommend DFY
```

---

## 📈 Webinar System (From Your Spec)

### Webinar Title
"Meet Your AI Bot Team: The 24/7 AI Front Desk That Captures Leads, Books Appointments & Follows Up Automatically"

### Duration
12-15 minutes

### Structure
1. **Hook** (2 min) - Problem: Missed leads kill revenue
2. **Solution** (2 min) - FrontDesk AI Pro overview
3. **Bot Tour** (6 min)
   - Starter bots ($104/mo)
   - Core bots ($154/mo) - Most Popular
   - Accelerator bots ($204/mo)
   - Add-ons ($29-$99/mo)
4. **DFY Offer** (2 min) - $497/mo hands-free
5. **CTA** (2 min) - Choose plan and start
6. **Q&A** - Bot answers common questions

### Key Messaging
- "Never miss a lead"
- "Books appointments automatically"
- "Replaces receptionist without payroll"
- "Works 24/7"
- "Cancel anytime"

---

## 🎯 Partner System (From Your Spec)

### Partner Funnel
```
Partner ad/post
    ↓
Partner landing page
    ↓
Partner Recruiter Bot
    ↓
Training + certification
    ↓
Get unique link: frontdeskaipro.com/?ref=their-slug
    ↓
Ad templates provided
    ↓
Partner posts ads
    ↓
Sales come in with slug
    ↓
Local-Link tracks and pays
```

### What Partners Get
1. Unique referral link
2. 3 done-for-them ad creatives
3. Ad copy templates
4. Training on how to post
5. Dashboard in Local-Link (not FrontDesk)

### What Partners Do
1. Post ads with their link ($20/day recommended)
2. Share on social media
3. Send to their audience
4. Track results in Local-Link

---

## 🔐 Critical Implementation Rules

### Rule 1: Slug Persistence
```javascript
// On page load (already implemented)
persistReferralSlug();

// In every API call
referral_slug: readReferralSlug()

// In Stripe checkout
metadata: {
  referral_partner_link_slug: readReferralSlug()
}
```

### Rule 2: Outbox Events
Every sale MUST create outbox event:
```javascript
await supabase.from('outbox_events').insert({
  event_type: 'sale.paid',
  payload: {
    referral_partner_link_slug: slug,  // ← MUST HAVE
    // ... other sale data
  }
});
```

### Rule 3: Never Lose Attribution
- Slug captured on first visit
- Stored in localStorage
- Persists through:
  - Chat sessions
  - Page navigation
  - Days/weeks later
  - Different channels (SMS, call, DM)

---

## 📊 Metrics That Matter

### FrontDesk Tracks:
- Leads captured
- Messages sent
- Conversations active
- Checkouts created
- **Referral slug present: yes/no**

### Local-Link Tracks:
- Commission owed per partner
- Tier level per partner
- Payout history
- Partner performance
- Revenue attribution

---

## 🚀 Launch Sequence (Your Playbook)

### Phase 1: AI Sales Playbook v1 (Now)
1. Deploy Ad Optimizer Bot
2. Deploy Sales Closer Bot
3. Deploy Webinar Host Bot
4. Deploy Upsell Engine Bot
5. Launch FB ads → Webinar funnel
6. **Result:** System converts at 30-50%

### Phase 2: Partner Launch Kit (60 Days)
1. Deploy Partner Recruiter Bot
2. Deploy Partner Onboarding Bot
3. Create partner landing page
4. Create ad templates
5. Recruit 50 partners
6. **Result:** $37,500 MRR (50 partners × 5 clients × $150)

### Phase 3: Vertical Franchises (6 Months)
1. Create industry-specific versions
2. License to vertical specialists
3. **Result:** Massive scale

---

## ✅ What's Already Built and Working

1. ✅ Referral slug capture (URL → localStorage)
2. ✅ Slug persistence through journey
3. ✅ Stripe metadata inclusion
4. ✅ Outbox events creation
5. ✅ Local-Link integration endpoints:
   - Push: `locallink-send-outbox` (every 5 min)
   - Pull: `locallink-commission-feed` (on demand)
6. ✅ Admin metrics dashboard
7. ✅ Database schema with referral fields

---

## 🎯 What You Need to Build Next

### In FrontDesk (This System):
1. **Webinar page** with AI Webinar Host Bot
2. **Sales Closer Bot** full script implementation
3. **Ad Optimizer Bot** integration with Meta API
4. **Upsell Engine Bot** triggers and flows
5. **Partner landing pages**

### In Local-Link (Separate System):
1. Partner accounts and tiers
2. Commission calculation engine
3. Partner dashboards
4. Payout processing
5. Revenue attribution logic

---

## 💡 Key Insight: Clean Separation

This architecture is **enterprise-grade** because:

1. **FrontDesk = Sales Machine**
   - Focuses on converting
   - Doesn't care about backend money
   - Scales infinitely

2. **Local-Link = Money Machine**
   - Handles all financial complexity
   - Flexible tier structures
   - Audit trails and compliance

3. **One Integration Point**
   - Just the referral slug
   - Simple, reliable, bulletproof

**This is how Shopify, Uber, and Amazon scale to millions of transactions.**

---

## 🎉 Bottom Line

Your system is **architecturally correct**.

- FrontDesk captures and forwards
- Local-Link calculates and pays
- Partners get unique links
- Bots never mention commissions
- Everything scales cleanly

**You're ready to launch and grow to 1,000+ partners without changing this architecture.** 🚀
