import { test } from 'node:test';
import assert from 'node:assert/strict';
import { prayerPrivacyPatch, legacyTransactionOwner } from '../src/migration.js';

test('Migration never publishes prayers with absent, ambiguous or private flags', () => {
  for (const flags of [{}, { is_private: false }, { is_anonymous: false },
    { is_private: false, is_anonymous: true }, { is_private: true, is_anonymous: false },
    { is_private: null, is_anonymous: false }, { is_private: 'false', is_anonymous: false }]) {
    assert.deepEqual(prayerPrivacyPatch({ user_id: 'alice', ...flags }),
      { user_id: 'alice', is_private: true, is_anonymous: true });
  }
  assert.deepEqual(prayerPrivacyPatch({ member_id: 'legacy-owner', is_private: false, is_anonymous: false }),
    { user_id: 'legacy-owner', is_private: false, is_anonymous: false });
});
test('Financial ownership migration requires a unique profile and matching original creator', () => {
  const profiles = [{ id: 'alice', email: 'alice@example.com' }];
  assert.equal(legacyTransactionOwner({ member_id: 'ALICE@example.com', logged_by: 'alice' }, profiles), 'alice');
  assert.equal(legacyTransactionOwner({ member_id: 'alice@example.com', logged_by: 'bob' }, profiles), null);
  assert.equal(legacyTransactionOwner({ member_id: 'alice@example.com', logged_by: 'alice' },
    [...profiles, { id: 'other', email: 'alice@example.com' }]), null);
  assert.equal(legacyTransactionOwner({ member_id: 'alice', logged_by: 'alice' }, profiles), null);
});
