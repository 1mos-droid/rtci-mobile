import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { prayerPrivacyPatch, legacyTransactionOwner } from '../src/migration.js';

const privileged = role => ['admin', 'developer', 'department_head'].includes(role);

/** Dry-run by default; callers supply reviewed identities and completed backup evidence. */
export async function migrate({ db, project, apply = false, approvedRoles, backup }) {
  if (!project) throw new Error('Specify the target project explicitly.');
  if (apply && (!approvedRoles || !backup || backup.project !== project || backup.done !== true)) {
    throw new Error('Apply requires a reviewed role allowlist and a completed backup for this project.');
  }
  const [profiles, prayers, legacy, transactions] = await Promise.all([
    db.collection('profiles').get(), db.collection('prayer_requests').get(),
    db.collection('group_memberships').get(), db.collection('transactions').get(),
  ]);
  const profileData = profiles.docs.map(doc => ({ ...doc.data(), id: doc.id }));
  if (approvedRoles) {
    for (const [uid, role] of Object.entries(approvedRoles)) {
      if (!privileged(role) || !profileData.some(profile => profile.id === uid && profile.role === role)) {
        throw new Error('The reviewed role allowlist no longer matches the current profiles. Repeat the review.');
      }
    }
  }
  const effectiveRole = profile => approvedRoles ? approvedRoles[profile.id] ?? 'member' : profile.role;
  const leaders = profileData.filter(profile => privileged(effectiveRole(profile)));
  const demotions = profileData.filter(profile => privileged(profile.role) && effectiveRole(profile) === 'member');
  const counts = { profiles: profiles.size, leadership: leaders.length, demotions: demotions.length,
    prayers: prayers.size, legacyMemberships: legacy.size, transactions: transactions.size };
  console.log(JSON.stringify({ project, mode: apply ? 'apply' : 'dry-run', rolesReviewed: Boolean(approvedRoles), counts }));
  if (!apply) return counts;

  const writer = db.bulkWriter();
  // BulkWriter promises must be observed: close() alone does not reject failed writes.
  const writes = [];
  const queue = promise => writes.push(promise.then(() => ({ ok: true }), () => ({ ok: false })));
  for (const profile of profileData) {
    if (privileged(profile.role) && !privileged(effectiveRole(profile))) {
      queue(writer.update(db.collection('profiles').doc(profile.id), { role: 'member' }));
      queue(writer.delete(db.collection('leadership').doc(profile.id)));
    }
  }
  for (const profile of leaders) {
    queue(writer.set(db.collection('leadership').doc(profile.id), {
      name: profile.name ?? 'Church leader', title: profile.title ?? 'Church leader',
      department: profile.department ?? '', avatar_url: profile.avatar_url ?? null,
    }));
  }
  for (const doc of transactions.docs) {
    const owner = legacyTransactionOwner(doc.data(), profileData);
    if (owner) queue(writer.update(doc.ref, { member_id: owner }));
  }
  for (const doc of prayers.docs) queue(writer.update(doc.ref, prayerPrivacyPatch(doc.data())));

  const memberships = new Map();
  for (const doc of legacy.docs) {
    const data = doc.data();
    if (typeof data.group_id !== 'string' || typeof data.user_id !== 'string'
      || !data.group_id || !data.user_id || data.group_id.includes('/') || data.user_id.includes('/')) continue;
    memberships.set(`${data.group_id}/${data.user_id}`, data);
  }
  for (const data of memberships.values()) {
    const group = db.collection('cell_groups').doc(data.group_id);
    if (!(await group.get()).exists) continue;
    const member = group.collection('members').doc(data.user_id);
    if (!(await member.get()).exists) queue(writer.set(member, {
      group_id: data.group_id, user_id: data.user_id,
      joined_at: data.joined_at ?? FieldValue.serverTimestamp(),
    }));
  }
  // Attach rejection handlers before flushing so a failing early write cannot
  // become an unhandled rejection while later records are being prepared.
  const completed = Promise.all(writes);
  await writer.close();
  const results = await completed;
  const failures = results.filter(result => !result.ok);
  if (failures.length) throw new Error(`${failures.length} migration writes failed. Do not deploy triggers; inspect and rerun.`);
  const groups = await db.collection('cell_groups').get();
  for (const group of groups.docs) {
    const members = await group.ref.collection('members').count().get();
    await group.ref.update({ member_count: members.data().count });
  }
  console.log('Migration complete. Triggers may now be deployed.');
  return counts;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const option = name => process.argv.find(arg => arg.startsWith(`--${name}=`))?.slice(name.length + 3);
  const project = option('project');
  if (!project) throw new Error('Specify --project=PROJECT_ID explicitly.');
  const read = name => option(name) ? JSON.parse(readFileSync(option(name), 'utf8')) : undefined;
  const db = getFirestore(initializeApp({ projectId: project }));
  await migrate({ db, project, apply: process.argv.includes('--apply'),
    approvedRoles: read('approved-roles'), backup: read('backup-record') });
}
