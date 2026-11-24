import { before, beforeEach, after, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { migrate } from '../scripts/migrate.js';

const project = 'demo-rtci';
let app, db;
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw Error('Migration integration tests require the local emulator.');
  app = initializeApp({ projectId: project }, 'migration-test');
  db = getFirestore(app);
});
beforeEach(async () => {
  await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${project}/databases/(default)/documents`, { method: 'DELETE' });
  const records = {
    'profiles/keeper': { name: 'Keep admin', role: 'admin', email: 'keeper@example.com' },
    'profiles/demoted': { name: 'Remove privilege', role: 'admin', email: 'former@example.com' },
    'profiles/member': { name: 'Member', role: 'member', email: 'member@example.com' },
    'prayer_requests/ambiguous': { member_id: 'member', content: 'Private', is_private: false },
    'prayer_requests/public': { user_id: 'member', content: 'Public', is_private: false, is_anonymous: false },
    'transactions/own': { member_id: 'member@example.com', logged_by: 'member', status: 'completed' },
    'transactions/uncertain': { member_id: 'member@example.com', logged_by: 'demoted', status: 'completed' },
    'cell_groups/group': { member_count: 17 },
    'group_memberships/one': { group_id: 'group', user_id: 'member' },
    'group_memberships/duplicate': { group_id: 'group', user_id: 'member' },
  };
  await Promise.all(Object.entries(records).map(([path, data]) => db.doc(path).set(data)));
});
after(async () => { await db?.terminate(); if (app) await deleteApp(app); });
const options = () => ({ db, project, approvedRoles: { keeper: 'admin' }, backup: { project, done: true } });

test('A migration dry-run does not mutate roles, prayers or membership counts', async () => {
  const counts = await migrate(options());
  assert.equal(counts.demotions, 1);
  assert.equal((await db.doc('profiles/demoted').get()).data().role, 'admin');
  assert.equal((await db.doc('prayer_requests/ambiguous').get()).data().is_private, false);
  assert.equal((await db.doc('cell_groups/group').get()).data().member_count, 17);
});
test('Migration applies the reviewed roles and privacy decisions and is safe to repeat', async () => {
  await migrate({ ...options(), apply: true });
  assert.equal((await db.doc('profiles/keeper').get()).data().role, 'admin');
  assert.equal((await db.doc('profiles/demoted').get()).data().role, 'member');
  assert.equal((await db.doc('leadership/keeper').get()).exists, true);
  assert.equal((await db.doc('leadership/demoted').get()).exists, false);
  assert.equal((await db.doc('prayer_requests/ambiguous').get()).data().is_private, true);
  assert.equal((await db.doc('prayer_requests/public').get()).data().is_private, false);
  assert.equal((await db.doc('transactions/own').get()).data().member_id, 'member');
  assert.equal((await db.doc('transactions/uncertain').get()).data().member_id, 'member@example.com');
  assert.equal((await db.collection('cell_groups/group/members').get()).size, 1);
  assert.equal((await db.doc('cell_groups/group').get()).data().member_count, 1);
  await migrate({ ...options(), apply: true });
  assert.equal((await db.doc('cell_groups/group').get()).data().member_count, 1);
});
test('Live writes require matching completed backup evidence and current reviewed roles', async () => {
  await assert.rejects(migrate({ ...options(), apply: true, backup: { project: 'wrong', done: true } }));
  await assert.rejects(migrate({ ...options(), apply: true, approvedRoles: { member: 'admin' } }));
  assert.equal((await db.doc('profiles/member').get()).data().role, 'member');
});
