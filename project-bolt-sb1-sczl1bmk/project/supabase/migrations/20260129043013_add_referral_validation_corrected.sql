/*
  # Add Validation to Referral Clicks Policy

  1. Security Enhancement
    - Replaces unrestricted INSERT policy with validated version
    - Ensures referral_code and partner_id reference valid affiliate partners
    - Maintains anonymous tracking capability for affiliate links
  
  2. Changes Made
    - Drop "Anyone can insert click tracking" policy
    - Create new policy that validates partner_id exists in affiliate_partners
    - Validates referral_code matches the partner's code
    - Only allows tracking for active partners
  
  3. Security Notes
    - Anonymous users can still track clicks (required for affiliate system)
    - Data integrity enforced through validation
    - Prevents insertion of fake/invalid affiliate data
*/

-- Drop the unrestricted policy
DROP POLICY IF EXISTS "Anyone can insert click tracking" ON referral_clicks;

-- Create validated policy
-- Allows anonymous/authenticated users to insert click tracking
-- but validates that the partner_id and referral_code are valid
CREATE POLICY "Track clicks for valid referral codes"
  ON referral_clicks FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    -- Validate that partner_id exists and referral_code matches
    EXISTS (
      SELECT 1 FROM affiliate_partners
      WHERE affiliate_partners.id = referral_clicks.partner_id
      AND affiliate_partners.referral_code = referral_clicks.referral_code
      AND affiliate_partners.is_active = true
    )
  );

-- Add comment explaining the policy
COMMENT ON POLICY "Track clicks for valid referral codes" ON referral_clicks IS 
  'Allows anonymous click tracking but validates partner_id and referral_code against active affiliate partners';
