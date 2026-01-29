# Brevo Email Authentication Setup

Add these DNS records to your domain registrar for frontdeskaipro.com

## DNS Records to Add

### 1. Brevo Verification Code
```
Type: TXT
Name: @
Value: brevo-code:14634ee391ad641c7958bbb28603a771
TTL: 3600 (or automatic)
```

### 2. DKIM Record 1
```
Type: CNAME
Name: brevo1._domainkey
Value: b1.frontdeskaipro-com.dkim.brevo.com
TTL: 3600 (or automatic)
```

### 3. DKIM Record 2
```
Type: CNAME
Name: brevo2._domainkey
Value: b2.frontdeskaipro-com.dkim.brevo.com
TTL: 3600 (or automatic)
```

### 4. DMARC Record
```
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com
TTL: 3600 (or automatic)
```

## Where to Add These Records

### If using GoDaddy:
1. Go to https://dcc.godaddy.com/
2. Click on your domain name
3. Click "DNS" tab
4. Click "Add" button for each record
5. Select type (TXT or CNAME)
6. Enter Name and Value exactly as shown above
7. Save each record

### If using Namecheap:
1. Go to https://ap.www.namecheap.com/
2. Click "Domain List"
3. Click "Manage" next to your domain
4. Click "Advanced DNS" tab
5. Click "Add New Record"
6. Select type and enter details
7. Save changes

### If using Cloudflare:
1. Go to https://dash.cloudflare.com/
2. Select your domain
3. Click "DNS" tab
4. Click "Add record"
5. Enter details for each record
6. Save

### If using other registrar:
Look for "DNS Management", "DNS Records", or "Domain Settings" in your registrar's control panel.

## Important Notes

1. **Exact Values Required**: Copy and paste the values exactly as shown
2. **For Name field**:
   - `@` means root domain
   - Keep the full name for DKIM records (brevo1._domainkey, etc.)
   - Keep underscore prefix for _dmarc
3. **Propagation Time**: DNS changes take 15 minutes to 48 hours to propagate
4. **Verification**: Return to Brevo after 1-2 hours to verify the records

## Verification in Brevo

After adding records:
1. Wait at least 30 minutes for DNS propagation
2. Go to your Brevo dashboard
3. Navigate to Senders & Domains section
4. Click "Authenticate" or "Verify" button
5. Brevo will check if records are properly configured

## Why These Records Matter

- **Brevo Code**: Verifies you own the domain
- **DKIM Records**: Authenticates your emails (prevents spam filtering)
- **DMARC Record**: Email policy and reporting (improves deliverability)

Without these records, your emails may go to spam or be rejected by recipient servers.

## Common Issues

**Record not found**: Wait longer (DNS can take up to 48 hours)
**Invalid format**: Make sure you copied values exactly, including dots and hyphens
**Wrong Name field**: Some registrars auto-append the domain - if you see "brevo1._domainkey.frontdeskaipro.com.frontdeskaipro.com", just use "brevo1._domainkey"

## Test Your Setup

After propagation, test using:
```bash
# Test TXT record
dig TXT frontdeskaipro.com

# Test DKIM 1
dig CNAME brevo1._domainkey.frontdeskaipro.com

# Test DKIM 2
dig CNAME brevo2._domainkey.frontdeskaipro.com

# Test DMARC
dig TXT _dmarc.frontdeskaipro.com
```

Or use online tools:
- https://mxtoolbox.com/SuperTool.aspx
- https://www.whatsmydns.net/
