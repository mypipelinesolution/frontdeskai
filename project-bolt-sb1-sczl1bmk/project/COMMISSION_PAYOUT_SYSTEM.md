# Commission Payout System

## Overview
Comprehensive commission tracking system for both family members (80% commission) and employees (50% commission) with automatic sync to Local-Link Marketplace Admin Dashboard.

## Database Tables

### `employee_reps`
Tracks all employees eligible for commission payouts.

**Fields:**
- `id` - Unique identifier
- `profile_id` - Optional link to user account
- `name` - Employee full name
- `email` - Contact email
- `commission_rate` - Decimal (0.50 = 50%)
- `employee_type` - sales, support, developer, marketing, manager, other
- `active` - Current employment status
- `hired_at` - Employment start date
- `created_at` - Record creation timestamp

### `commission_payouts`
Unified payout tracking for all commission types.

**Fields:**
- `id` - Unique identifier
- `order_id` - Links to subscription order
- `recipient_type` - 'family' or 'employee'
- `recipient_id` - Links to family_reps or employee_reps
- `recipient_name` - Cached name for display
- `order_amount` - Original subscription amount (in cents)
- `commission_rate` - Percentage as decimal
- `commission_amount` - Calculated payout amount (in cents)
- `status` - pending, processing, paid, failed
- `payment_method` - stripe, paypal, bank_transfer, check, cash, other
- `paid_at` - Payment completion timestamp
- `period_start` - Commission period start
- `period_end` - Commission period end
- `locallink_sync_status` - pending, synced, failed
- `locallink_synced_at` - Sync completion timestamp
- `notes` - Additional notes
- `created_at` - Record creation timestamp

### `payout_summary` (View)
Aggregated summary of payouts per recipient.

**Fields:**
- `recipient_type` - family or employee
- `recipient_id` - Person identifier
- `recipient_name` - Person name
- `total_orders` - Number of orders
- `total_earned` - Total commission earned
- `total_paid` - Amount already paid
- `total_pending` - Amount pending payment
- `last_payment_date` - Most recent payment

## Automatic Payout Creation

A database trigger automatically creates commission records when new orders are created:

1. **Checks referral code** - Validates if order has a referral slug
2. **Identifies referrer** - Looks up in family_reps table
3. **Calculates commission** - Applies appropriate rate (80% for family)
4. **Creates payout record** - Inserts into commission_payouts
5. **Queues LocalLink sync** - Creates entry in locallink_outbox

## Commission Rates

- **Family Members:** 80% (0.80) - Default rate
- **Employees:** 50% (0.50) - Default rate
- Rates are customizable per person

## Admin Pages

### 1. Commission Payouts Page (`/admin` → Commission Payouts)

**Features:**
- View all payouts (family + employees)
- Filter by recipient type (family/employee)
- Filter by status (pending/paid)
- Summary cards showing:
  - Family Pending (80%)
  - Family Paid
  - Employee Pending (50%)
  - Employee Paid
- Person-by-person breakdown
- Transaction table with:
  - Recipient name
  - Type (family/employee)
  - Order amount
  - Commission rate
  - Commission amount
  - Payment status
  - LocalLink sync status
- Actions:
  - Mark as paid
  - Sync to LocalLink

### 2. Employee Management Page (`/admin` → Employees)

**Features:**
- Add new employees
- Edit employee details
- View active/inactive employees
- Configure commission rates
- Track hire dates
- Summary statistics:
  - Total employees
  - Active employees
  - Default commission rate

## Local-Link Marketplace Integration

### Outbox Pattern
The system uses an "outbox" pattern for syncing data to Local-Link:

1. **Create payout** → Insert into `commission_payouts`
2. **Queue sync** → Insert into `locallink_outbox`
3. **Sync status** → Track in `locallink_sync_status` field
4. **Manual sync** → Button in UI to retry failed syncs

### Sync Fields
- `order_id` - Order reference
- `referral_slug` - Referrer identifier
- `amount` - Commission amount
- `sync_status` - pending, sent, failed
- `sync_attempts` - Retry counter
- `last_sync_attempt` - Timestamp
- `synced_at` - Success timestamp

## Usage Examples

### Add a New Employee
1. Go to `/admin`
2. Click "Employees" in sidebar
3. Click "Add Employee" button
4. Fill in details:
   - Name
   - Email
   - Employee Type
   - Commission Rate (default 0.50)
   - Active status
5. Submit

### View Family Payouts
1. Go to `/admin`
2. Click "Commission Payouts"
3. View "Family Payouts (80%)" section
4. See total earned, paid, and pending amounts

### Mark Payout as Paid
1. Navigate to Commission Payouts page
2. Find transaction in table
3. Click checkmark icon in Actions column
4. Status updates to "paid"
5. Payment timestamp recorded

### Sync to Local-Link
1. Navigate to Commission Payouts page
2. Find transaction with "pending" LocalLink status
3. Click external link icon in Actions column
4. Status updates to "synced"
5. Sync timestamp recorded

## Security

All tables have Row Level Security (RLS) enabled:

- **Admin only** - Can view/manage all records
- **Family reps** - Can view their own payouts
- **Employees** - Can view their own payouts
- **Customers** - No access to payout data

## Future Enhancements

Potential additions:
- Automated payment processing via Stripe
- Email notifications for pending payouts
- CSV export for accounting
- Payment batch processing
- Recurring payout schedules
- Multi-currency support
- Tax form generation (1099)
- Performance-based commission adjustments
- Commission caps and floors
- Tiered commission structures
