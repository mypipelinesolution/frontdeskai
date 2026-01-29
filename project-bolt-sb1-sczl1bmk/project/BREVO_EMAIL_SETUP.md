# Brevo Email Integration - Complete Setup

Your email function is now configured to use Brevo! Follow these steps:

## Step 1: Add DNS Records (Required)

See `BREVO_DNS_SETUP.md` for detailed instructions on adding these records to your domain registrar:

1. Brevo verification TXT record
2. DKIM CNAME records (2 records)
3. DMARC TXT record

**This must be done first** - without these records, your emails will go to spam or be rejected.

## Step 2: Get Your Brevo API Key

1. **Login to Brevo**
   - Go to: https://app.brevo.com/

2. **Navigate to API Settings**
   - Click your name in top right
   - Click "SMTP & API"
   - Go to "API Keys" tab

3. **Create New API Key**
   - Click "Create a new API key"
   - Name it: "FrontDesk AI Pro"
   - Copy the key (starts with `xkeysib-...`)

## Step 3: Add API Key to Supabase

1. **Go to Supabase Edge Functions Settings**
   - Visit: https://supabase.com/dashboard/project/fcklhskfhtfzpuolmesq/settings/functions

2. **Add Environment Variable**
   - Click "Add new secret"
   - Key: `BREVO_API_KEY`
   - Value: Your Brevo API key (paste the key from Step 2)
   - Click "Save"

## Step 4: Deploy the Email Function

### Option A: Using Supabase CLI (Recommended)

If you have Supabase CLI installed:

```bash
# Login to Supabase
supabase login

# Link your project
supabase link --project-ref fcklhskfhtfzpuolmesq

# Deploy the send-email function
supabase functions deploy send-email
```

### Option B: Manual Deployment via Dashboard

1. **Go to Edge Functions**
   - Visit: https://supabase.com/dashboard/project/fcklhskfhtfzpuolmesq/functions

2. **Create New Function**
   - Click "Create a new function"
   - Name: `send-email`
   - Click "Create function"

3. **Copy Function Code**
   - Open `supabase/functions/send-email/index.ts` in your project
   - Copy all the code
   - Paste into the Supabase editor
   - Click "Deploy"

## Step 5: Test Email Sending

Test the function using curl:

```bash
curl -X POST \
  'https://fcklhskfhtfzpuolmesq.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "your-email@example.com",
    "subject": "Test Email from FrontDesk AI Pro",
    "message": "This is a test email to verify Brevo integration is working!",
    "from_name": "FrontDesk AI Pro",
    "from_email": "noreply@frontdeskaipro.com"
  }'
```

Replace `YOUR_ANON_KEY` with your actual anon key from `.env` file.

## Updated Email Function Features

The new email function supports:

- **Simple API**: Just provide `to`, `subject`, and `message`
- **HTML Emails**: Optional `html` parameter for rich emails
- **Custom Sender**: Optional `from_name` and `from_email`
- **Automatic Fallback**: Works without Brevo (simulation mode)

### Usage Example in Your Code

```typescript
const response = await fetch(
  `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/send-email`,
  {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: 'customer@example.com',
      subject: 'Welcome to FrontDesk AI Pro!',
      message: 'Thank you for signing up...',
      html: '<h1>Welcome!</h1><p>Thank you for signing up...</p>',
      from_name: 'FrontDesk AI Pro',
      from_email: 'noreply@frontdeskaipro.com'
    })
  }
);
```

## Brevo Email Limits

Free Plan:
- 300 emails per day
- Brevo branding in emails

Starter Plan ($25/month):
- 20,000 emails per month
- No branding
- Better deliverability

## Common Use Cases

### 1. Welcome Email After Signup
Send when user completes registration

### 2. Demo Request Confirmation
Automatically email when someone requests a demo

### 3. Subscription Receipts
Email invoice after Stripe payment

### 4. Password Reset
Email reset link when user forgets password

### 5. Lead Notifications
Alert you when someone chats with your AI bot

## Verification Checklist

Before going live:

- [ ] DNS records added and verified in Brevo dashboard
- [ ] Brevo API key added to Supabase environment
- [ ] Email function deployed successfully
- [ ] Test email sent and received
- [ ] Check spam folder (should NOT be there if DNS is correct)
- [ ] Verify sender name and email appear correctly

## Troubleshooting

**Emails going to spam**
- Wait for DNS propagation (up to 48 hours)
- Verify all 4 DNS records are correct
- Check authentication status in Brevo dashboard

**API errors**
- Verify API key is correct
- Check that key has email sending permissions
- Review Brevo logs for specific error messages

**Function not found**
- Ensure function is deployed
- Check function name is exactly `send-email`
- Verify project URL is correct

## Next Steps

Once email is working:

1. **Create Email Templates** in Brevo dashboard for consistent branding
2. **Set up Transactional Emails** for automated workflows
3. **Monitor Deliverability** using Brevo analytics
4. **Add Email to Onboarding Flow** to welcome new users

Your email infrastructure is now professional-grade and ready for production!
