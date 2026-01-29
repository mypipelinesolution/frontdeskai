export function sanitizeSlug(input: string): string {
  return input
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]/g, '')
    .slice(0, 64);
}

export function getReferralSlug(): string | null {
  const params = new URLSearchParams(window.location.search);
  const ref = params.get('ref');

  if (ref) {
    const sanitized = sanitizeSlug(ref);
    sessionStorage.setItem('referral_slug', sanitized);
    return sanitized;
  }

  return sessionStorage.getItem('referral_slug');
}

export function clearReferralSlug(): void {
  sessionStorage.removeItem('referral_slug');
}
