# Intelligent AI Onboarding System

## Overview

Your AI bots now **automatically learn about each customer's business** through a conversational onboarding process and train themselves to provide personalized service.

## How It Works

### 1. Customer Subscribes
- Customer completes checkout for any plan (Starter, Core, Accelerator, or DFY)
- They're redirected to the Success page after payment

### 2. AI Setup Bot Launches Automatically
- **Onboarding Chat Interface** appears immediately on the success page
- The AI Setup Bot introduces itself and starts a friendly conversation
- No manual forms - just natural conversation

### 3. Conversational Business Intelligence Gathering

The AI Setup Bot conducts a 5-minute interview to learn:

**Business Basics:**
- Industry type (HVAC, plumbing, legal, healthcare, etc.)
- Specific services offered
- What makes them unique

**Operational Details:**
- Business hours
- Service area/location
- Emergency or after-hours availability

**Customer & Sales Info:**
- Ideal customer profile
- Average customer value/ticket size
- Monthly lead volume
- Current challenges with lead follow-up

**Pricing & Booking:**
- Pricing structure (flat rate, hourly, by project)
- Free estimates or consultations
- Appointment booking preferences
- Calendar link if available

**Common Scenarios:**
- Top 3-5 customer questions
- Common objections
- Required info before booking

### 4. AI Training Completion

When the bot has collected enough information:
- All data is **automatically saved** to the workspace database
- The customer's AI workforce is **instantly trained**
- All 9-38 bots now know the business inside and out

### 5. Personalized Bot Service

Every bot in the customer's workforce now:
- ✅ Knows their industry and services
- ✅ Understands their pricing
- ✅ Can answer common questions accurately
- ✅ Follows their business hours
- ✅ Highlights their unique selling points
- ✅ Books appointments correctly
- ✅ Qualifies leads based on their ideal customer
- ✅ Speaks with knowledge about their business

## Database Schema

### New Fields in `workspaces` Table:
```sql
business_type              -- Industry (HVAC, plumbing, etc.)
service_area              -- Geographic coverage
business_hours            -- Operating schedule
avg_ticket_value          -- Average customer value
monthly_lead_volume       -- Lead volume
target_audience           -- Ideal customer profile
pain_points               -- Business challenges
unique_selling_points     -- Competitive advantages
pricing_info              -- Pricing structure
booking_url               -- Calendar link
common_questions          -- FAQs and answers
ai_training_complete      -- Training status
ai_training_data          -- Full structured data (JSONB)
```

## Edge Functions

### `/onboarding-bot`
- Conducts conversational interview
- Extracts structured data from natural responses
- Saves training data to database
- Returns completion status

### `/ai-chat` (Updated)
- Now uses learned business context
- Provides personalized responses
- Answers questions accurately based on training
- Highlights unique selling points

## User Experience Flow

1. **Customer subscribes** → Payment success
2. **Chat window opens** → "Hi! I'm your AI Setup Bot..."
3. **Natural conversation** → Bot asks questions, customer responds
4. **Progress saved** → Can pause and continue later if needed
5. **Training complete** → "Your AI team is ready!"
6. **Dashboard access** → All bots trained and operational

## Benefits

### For Customers:
- No tedious forms to fill out
- Feels like talking to a helpful person
- Takes only 5 minutes
- Bots immediately work for their specific business

### For You:
- 100% automated onboarding
- High-quality business data collected
- Customers get immediate value
- Reduced support requests
- Better bot performance = higher retention

## Technical Implementation

**Frontend:**
- `OnboardingChat.tsx` - React chat interface
- `SuccessPage.tsx` - Triggers onboarding after checkout

**Backend:**
- `onboarding-bot/index.ts` - Conversational AI that learns
- Database migration for new fields
- Updated `ai-chat` to use learned context

**AI Strategy:**
- Uses GPT-4o-mini for intelligent conversation
- Extracts structured data from natural language
- Validates completeness before finishing
- Stores data in both text and JSON formats

## Example Conversation

**Bot:** "Hi John! 👋 I'm your AI Setup Bot. I'll train your AI team to work perfectly for ABC Plumbing. This takes about 5 minutes. What type of business is ABC Plumbing?"

**Customer:** "We're a residential plumbing company"

**Bot:** "Perfect! Residential plumbing - got it. What specific services do you offer? For example: repairs, installations, emergency service?"

**Customer:** "We do all types of plumbing repairs, water heater installation, and 24/7 emergency service"

**Bot:** "Excellent! Emergency service is huge. What geographic area do you serve?"

...conversation continues...

**Bot:** "✅ All done! Your AI team is now fully trained and ready to handle customers for ABC Plumbing. They know your services, pricing, hours, and how to help your customers. Welcome to your 24/7 AI front desk! 🎉"

## Result

Every customer gets a **fully personalized AI workforce** that knows their business as well as they do - automatically, in just 5 minutes.
