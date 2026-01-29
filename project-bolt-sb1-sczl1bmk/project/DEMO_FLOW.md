# Demo Flow Documentation

## Overview
The demo functionality allows potential customers to explore FrontDesk AI Pro without requiring signup or payment.

## How It Works

### 1. Landing Page Demo Form
- Located on the homepage (`/`)
- User enters:
  - Name (required)
  - Email (required)
  - Phone (optional)
- Click "Request Demo" button

### 2. Demo Access
Instead of redirecting to Stripe checkout, the system:
1. Stores user info in `sessionStorage` as `demo_user`
2. Redirects to `/app` (the main application)
3. Shows full application interface with DEV_MODE enabled

### 3. Welcome Experience
When demo users arrive at `/app`:
- **Welcome Banner** appears with personalized greeting
  - Shows user's name
  - Explains they have full access
  - Options to:
    - View Pricing (redirects to `/pricing`)
    - Continue Exploring (dismisses banner)
    - Close button (X) in top right
- **Sidebar Info** shows:
  - "Demo User" label
  - Their email address
  - "Exploring Full Access" status

### 4. Full Feature Access
Demo users get access to:
- All 38 AI Bots
- Dashboard with analytics
- Leads inbox
- Conversations
- Automations
- Widget settings
- Bot team visualization

## Technical Implementation

### Session Storage
```javascript
// Stored on form submission
sessionStorage.setItem('demo_user', JSON.stringify({
  name: "User Name",
  email: "user@example.com",
  phone: "123-456-7890"
}));
```

### Files Modified
1. **src/pages/Landing.tsx**
   - `handleDemoRequest()` - Saves to sessionStorage and redirects to /app

2. **src/App.tsx**
   - Checks for `demo_user` in sessionStorage on load
   - Shows welcome banner
   - Displays demo user info in sidebar
   - Maintains DEV_MODE for full access

## Advantages

### For Users
- Instant access (no signup required)
- Full feature exploration
- No credit card needed
- Risk-free evaluation

### For Business
- Lower friction to demo
- Captures lead information
- Users can explore before committing
- Clear path to pricing/purchase

## Converting Demo Users

Demo users can convert to paying customers by:
1. Clicking "View Pricing" in welcome banner
2. Navigating to pricing page from any location
3. Selecting a plan and completing checkout

## Future Enhancements

Potential improvements:
- Save demo user to database as a lead
- Email follow-up campaigns
- Track which features demo users interact with
- Time-limited demo sessions
- Demo user analytics dashboard
- Guided product tour
- Demo-specific limitations (e.g., no real email sending)
