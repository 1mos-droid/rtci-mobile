import { before, beforeEach, after, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, getDocs, collection, query, where, setDoc, updateDoc, deleteDoc, serverTimestamp } from 'firebase/firestore';

let env;
let alice, bob, admin, head, guest;
before(async () => {
  env = await initializeTestEnvironment({ projectId: 'demo-rtci',
    firestore: { host: '127.0.0.1', port: 8080, rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
    storage: { host: '127.0.0.1', port: 9199, rules: readFileSync(new URL('../../storage.rules', import.meta.url), 'utf8') } });
  alice = env.authenticatedContext('alice', { email: 'alice@example.com', email_verified: true });
  bob = env.authenticatedContext('bob', { email: 'bob@example.com', email_verified: true });
  admin = env.authenticatedContext('admin');
  head = env.authenticatedContext('head');
  guest = env.unauthenticatedContext();
});
after(async () => { await env?.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    for (const [uid, role] of [['alice', 'member'], ['bob', 'member'], ['admin', 'admin'], ['head', 'department_head'], ['developer', 'developer']]) {
      await setDoc(doc(db, 'profiles', uid), { name: uid, email: `${uid}@example.com`, role, fcm_token: 'private-device-token' });
    }
    for (const [id, data] of Object.entries({
      'prayer_requests/public': { user_id: 'bob', content: 'Public prayer', is_private: false, is_anonymous: false },
      'prayer_requests/private': { user_id: 'bob', content: 'Private prayer', is_private: true, is_anonymous: true },
      'prayer_requests/legacy': { user_id: 'bob', content: 'Missing privacy flags' },
      'transactions/alice': { member_id: 'alice', status: 'completed', amount: 10, is_shared: false },
      'transactions/bob': { member_id: 'bob', status: 'completed', amount: 100, is_shared: false },
      'transactions/shared': { member_id: 'bob', status: 'completed', amount: 100, is_shared: true },
      'transactions/pending': { member_id: 'alice', status: 'pending', amount: 20, source: 'paystack' },
      'cell_groups/group': { name: 'Fellowship', member_count: 0 },
      'events/service': { name: 'Sunday service' },
      'child_checkins/child': { child_name: 'Child', guardian_id: 'bob' },
      'applications/private': { full_name: 'Sensitive application' },
      'leadership/admin': { name: 'Church leader', title: 'Leader', department: '' },
    })) await setDoc(doc(db, id), data);
  });
});

test('Members can read their profile but cannot list or read other profiles', async () => {
  await assertSucceeds(getDoc(doc(alice.firestore(), 'profiles/alice')));
  await assertFails(getDoc(doc(alice.firestore(), 'profiles/bob')));
  await assertFails(getDocs(collection(alice.firestore(), 'profiles')));
  await assertSucceeds(getDocs(collection(head.firestore(), 'profiles')));
  await assertSucceeds(getDocs(collection(alice.firestore(), 'leadership')));
});
test('Profile creation cannot self-assign privileges or forge account email', async () => {
  const db = env.authenticatedContext('new', { email: 'new@example.com' }).firestore();
  const profile = { name: 'New member', email: 'new@example.com', role: 'member', created_at: serverTimestamp() };
  await assertFails(setDoc(doc(db, 'profiles/new'), { ...profile, role: 'admin' }));
  await assertFails(setDoc(doc(db, 'profiles/new'), { ...profile, department: 'Finance' }));
  await assertFails(setDoc(doc(db, 'profiles/new'), { ...profile, email: 'someone@example.com' }));
  await assertSucceeds(setDoc(doc(db, 'profiles/new'), profile));
});
test('Profile edits cannot escalate roles, change department or inject billing flags', async () => {
  const profile = doc(alice.firestore(), 'profiles/alice');
  await assertSucceeds(updateDoc(profile, { name: 'Updated name' }));
  for (const patch of [{ role: 'admin' }, { department: 'Finance' }, { isAdmin: true }, { email: 'bob@example.com' }]) {
    await assertFails(updateDoc(profile, patch));
  }
  await assertFails(updateDoc(doc(head.firestore(), 'profiles/alice'), { role: 'admin' }));
  await assertSucceeds(updateDoc(doc(admin.firestore(), 'profiles/alice'), { role: 'department_head' }));
  await assertFails(updateDoc(doc(admin.firestore(), 'profiles/alice'), { role: 'developer' }));
  await assertFails(updateDoc(doc(admin.firestore(), 'profiles/developer'), { role: 'member' }));
});
test('Transactions require owner-scoped queries and protect other members', async () => {
  await assertSucceeds(getDoc(doc(alice.firestore(), 'transactions/alice')));
  await assertSucceeds(getDoc(doc(alice.firestore(), 'transactions/shared')));
  await assertFails(getDoc(doc(alice.firestore(), 'transactions/bob')));
  await assertFails(getDocs(collection(alice.firestore(), 'transactions')));
  await assertSucceeds(getDocs(query(collection(alice.firestore(), 'transactions'), where('member_id', '==', 'alice'))));
  await assertSucceeds(getDocs(query(collection(alice.firestore(), 'transactions'), where('is_shared', '==', true))));
  await assertSucceeds(getDocs(collection(admin.firestore(), 'transactions')));
});
test('Members and staff cannot forge or confirm online payments', async () => {
  await assertFails(setDoc(doc(alice.firestore(), 'transactions/forged'), { amount: 100, status: 'completed', member_id: 'alice' }));
  for (const context of [alice, head, admin]) {
    await assertFails(updateDoc(doc(context.firestore(), 'transactions/pending'), { status: 'completed' }));
  }
  const manual = { amount: 100, amount_subunit: 10000, currency: 'GHS', type: 'expense', category: 'Office', description: 'Supplies',
    member_id: 'admin', logged_by: 'admin', source: 'manual', status: 'completed', date: serverTimestamp() };
  await assertSucceeds(setDoc(doc(admin.firestore(), 'transactions/manual'), manual));
  await assertFails(setDoc(doc(head.firestore(), 'transactions/manual-head'), { ...manual, logged_by: 'head' }));
});
test('Private and legacy prayer documents are hidden from members and department heads', async () => {
  await assertSucceeds(getDoc(doc(alice.firestore(), 'prayer_requests/public')));
  for (const context of [alice, head]) {
    await assertFails(getDoc(doc(context.firestore(), 'prayer_requests/private')));
    await assertFails(getDoc(doc(context.firestore(), 'prayer_requests/legacy')));
    await assertFails(getDocs(collection(context.firestore(), 'prayer_requests')));
  }
  await assertSucceeds(getDoc(doc(bob.firestore(), 'prayer_requests/private')));
  await assertSucceeds(getDoc(doc(admin.firestore(), 'prayer_requests/private')));
  await assertSucceeds(getDocs(query(collection(alice.firestore(), 'prayer_requests'),
    where('is_private', '==', false), where('is_anonymous', '==', false))));
});
test('Prayer support is identity-bound and cannot overwrite the aggregate counter', async () => {
  await assertFails(updateDoc(doc(alice.firestore(), 'prayer_requests/public'), { intercession_count: 999 }));
  await assertSucceeds(setDoc(doc(alice.firestore(), 'prayer_requests/public/supporters/alice'), { created_at: serverTimestamp() }));
  await assertFails(setDoc(doc(alice.firestore(), 'prayer_requests/public/supporters/bob'), { created_at: serverTimestamp() }));
  await assertFails(setDoc(doc(alice.firestore(), 'prayer_requests/private/supporters/alice'), { created_at: serverTimestamp() }));
});
test('Group membership is identity-bound while group metadata remains admin-only', async () => {
  await assertSucceeds(setDoc(doc(alice.firestore(), 'cell_groups/group/members/alice'),
    { user_id: 'alice', group_id: 'group', joined_at: serverTimestamp() }));
  await assertFails(setDoc(doc(alice.firestore(), 'cell_groups/group/members/bob'),
    { user_id: 'bob', group_id: 'group', joined_at: serverTimestamp() }));
  await assertFails(updateDoc(doc(alice.firestore(), 'cell_groups/group'), { member_count: 999 }));
  await assertSucceeds(deleteDoc(doc(alice.firestore(), 'cell_groups/group/members/alice')));
});
test('RSVPs cannot impersonate another member or attach to a nonexistent event', async () => {
  await assertSucceeds(setDoc(doc(alice.firestore(), 'events/service/rsvps/alice'), { member_id: 'alice', created_at: serverTimestamp() }));
  await assertFails(setDoc(doc(alice.firestore(), 'events/service/rsvps/bob'), { member_id: 'bob', created_at: serverTimestamp() }));
  await assertFails(setDoc(doc(alice.firestore(), 'events/missing/rsvps/alice'), { member_id: 'alice', created_at: serverTimestamp() }));
});
test('Children and membership applications are not available to ordinary members', async () => {
  await assertFails(getDoc(doc(alice.firestore(), 'child_checkins/child')));
  await assertSucceeds(getDoc(doc(head.firestore(), 'child_checkins/child')));
  await assertFails(getDoc(doc(alice.firestore(), 'applications/private')));
  await assertFails(getDoc(doc(head.firestore(), 'applications/private')));
  await assertSucceeds(getDoc(doc(admin.firestore(), 'applications/private')));
});
test('Guest applications require bounded valid fields and cannot forge a member ID', async () => {
  const application = { user_id: null, full_name: 'New visitor', email: 'visitor@example.com', phone: '123456789',
    address: 'Test address', covenants_agreed: true, signature_points: ['1,1'], selected_ministries: [], created_at: serverTimestamp() };
  await assertSucceeds(setDoc(doc(guest.firestore(), 'applications/visitor'), application));
  await assertFails(setDoc(doc(guest.firestore(), 'applications/forged'), { ...application, user_id: 'alice' }));
  await assertFails(setDoc(doc(guest.firestore(), 'applications/invalid'), { ...application, full_name: '' }));
  await assertFails(getDoc(doc(guest.firestore(), 'applications/visitor')));
});
test('Members cannot publish church content or access backend bookkeeping', async () => {
  for (const path of ['broadcasts/new', 'sermons/new', 'insights/new', '_rate_limits/new', '_processed_events/new', 'unknown/new']) {
    await assertFails(setDoc(doc(alice.firestore(), path), { content: 'Forged content' }));
  }
  await assertSucceeds(setDoc(doc(head.firestore(), 'broadcasts/update'), { subject: 'Church update' }));
});
test('Avatar storage enforces ownership, image type and size', async () => {
  const file = alice.storage().ref('avatars/avatar_alice.jpg');
  await assertSucceeds(file.put(new Uint8Array(10), { contentType: 'image/jpeg' }));
  await assertFails(bob.storage().ref('avatars/avatar_alice.jpg').put(new Uint8Array(10), { contentType: 'image/jpeg' }));
  await assertFails(file.put(new Uint8Array(10), { contentType: 'image/svg+xml' }));
  await assertFails(file.put(new Uint8Array(10 * 1024 * 1024), { contentType: 'image/jpeg' }));
  await assertFails(guest.storage().ref('avatars/avatar_guest.jpg').put(new Uint8Array(10), { contentType: 'image/jpeg' }));
});
test('Gallery uploads are restricted to staff', async () => {
  await assertFails(alice.storage().ref('gallery/member.jpg').put(new Uint8Array(10), { contentType: 'image/jpeg' }));
  await assertSucceeds(admin.storage().ref('gallery/admin.jpg').put(new Uint8Array(10), { contentType: 'image/jpeg' }));
});

test('An email address alone never grants ownership of a legacy contribution', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'transactions/legacy-email'), { member_id: 'alice@example.com', amount: 10 });
  });
  await assertFails(getDoc(doc(alice.firestore(), 'transactions/legacy-email')));
  const unverified = env.authenticatedContext('unverified', { email: 'alice@example.com', email_verified: false });
  await assertFails(getDoc(doc(unverified.firestore(), 'transactions/legacy-email')));
});
test('Collection-group membership queries cannot retrieve another member’s records', async () => {
  const { collectionGroup } = await import('firebase/firestore');
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'cell_groups/group/members/alice'), { user_id: 'alice', group_id: 'group' });
    await setDoc(doc(context.firestore(), 'cell_groups/group/members/bob'), { user_id: 'bob', group_id: 'group' });
  });
  await assertSucceeds(getDocs(query(collectionGroup(alice.firestore(), 'members'), where('user_id', '==', 'alice'))));
  await assertFails(getDocs(collectionGroup(alice.firestore(), 'members')));
});

test('Account deletion requests are owned, immutable to members and visible only to administrators', async () => {
  const request = { user_id: 'alice', status: 'pending', created_at: serverTimestamp() };
  await assertSucceeds(setDoc(doc(alice.firestore(), 'account_deletion_requests/alice'), request));
  await assertSucceeds(getDoc(doc(alice.firestore(), 'account_deletion_requests/alice')));
  await assertFails(getDoc(doc(bob.firestore(), 'account_deletion_requests/alice')));
  await assertFails(getDocs(collection(head.firestore(), 'account_deletion_requests')));
  await assertSucceeds(getDocs(collection(admin.firestore(), 'account_deletion_requests')));
  await assertFails(setDoc(doc(bob.firestore(), 'account_deletion_requests/alice'), { ...request, user_id: 'bob' }));
  await assertFails(updateDoc(doc(alice.firestore(), 'account_deletion_requests/alice'), { status: 'completed' }));
  await assertFails(deleteDoc(doc(alice.firestore(), 'account_deletion_requests/alice')));
  await assertFails(setDoc(doc(guest.firestore(), 'account_deletion_requests/guest'), { ...request, user_id: 'guest' }));
});
test('Device token updates cannot store oversized profile fields', async () => {
  await assertSucceeds(updateDoc(doc(alice.firestore(), 'profiles/alice'), { fcm_token: 'new-device-token' }));
  await assertFails(updateDoc(doc(alice.firestore(), 'profiles/alice'), { fcm_token: 'x'.repeat(4097) }));
  await assertFails(updateDoc(doc(alice.firestore(), 'profiles/alice'), { avatar_url: 'x'.repeat(2049) }));
});
