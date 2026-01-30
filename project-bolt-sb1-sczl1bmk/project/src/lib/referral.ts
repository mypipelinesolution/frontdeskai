/**
 * Referral Tracking System
 *
 * Captures and persists partner referral slugs throughout the customer journey.
 * All referral data is forwarded to Local-Link for commission attribution.
 */

const STORAGE_KEY = 'fdap_ref_slug';

export function sanitizeSlug(input: string): string {
  return input
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]/g, '')
    .slice(0, 64);
}

/**
 * Get referral slug from URL parameters
 * Checks multiple param names: ref, partner, r
 */
export function getReferralSlugFromUrl(): string | null {
  if (typeof window === 'undefined') return null;

  const params = new URLSearchParams(window.location.search);
  const slug = params.get('ref') || params.get('partner') || params.get('r');

  return slug ? sanitizeSlug(slug) : null;
}

/**
 * Persist referral slug to localStorage
 * Call this once on app load to capture URL params
 */
export function persistReferralSlug(): string | null {
  const urlSlug = getReferralSlugFromUrl();

  if (urlSlug) {
    localStorage.setItem(STORAGE_KEY, urlSlug);
    return urlSlug;
  }

  return localStorage.getItem(STORAGE_KEY);
}

/**
 * Read the stored referral slug
 * Use this when creating checkouts or sending to API
 */
export function readReferralSlug(): string | null {
  return localStorage.getItem(STORAGE_KEY);
}

/**
 * Get or capture referral slug (convenience method)
 */
export function getReferralSlug(): string | null {
  // First try URL
  const urlSlug = getReferralSlugFromUrl();
  if (urlSlug) {
    localStorage.setItem(STORAGE_KEY, urlSlug);
    return urlSlug;
  }

  // Then try stored
  return localStorage.getItem(STORAGE_KEY);
}

/**
 * Clear the stored referral slug
 */
export function clearReferralSlug(): void {
  localStorage.removeItem(STORAGE_KEY);
}

/**
 * Check if a referral slug is currently set
 */
export function hasReferralSlug(): boolean {
  return !!readReferralSlug();
}
