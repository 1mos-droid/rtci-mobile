// Preserve privacy under ambiguous legacy data. Only two explicit false flags
// identify a request as safe to publish to the member community.
export function prayerPrivacyPatch(data) {
  const privateRequest = data.is_private !== false || data.is_anonymous !== false;
  return {
    user_id: data.user_id ?? data.member_id ?? null,
    is_private: privateRequest,
    is_anonymous: privateRequest,
  };
}

export function legacyTransactionOwner(data, profiles) {
  if (typeof data.member_id !== 'string' || !data.member_id.includes('@')) return null;
  const matches = profiles.filter(profile => typeof profile.email === 'string'
    && profile.email.toLowerCase() === data.member_id.toLowerCase());
  return matches.length === 1 && matches[0].id === data.logged_by ? matches[0].id : null;
}
