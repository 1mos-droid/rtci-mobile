import { setGlobalOptions } from 'firebase-functions/v2';
import { error as logError } from 'firebase-functions/logger';
import { getAppCheck } from 'firebase-admin/app-check';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { onDocumentWritten, onDocumentCreated } from 'firebase-functions/v2/firestore';
import { defineSecret } from 'firebase-functions/params';
import { createServices, validSignature, ApiError } from './services.js';
import { authenticatedHandler } from './http.js';

setGlobalOptions({ serviceAccount: 'rtci-runtime@rtci-22582.iam.gserviceaccount.com' });
initializeApp();
const db = getFirestore();
const paystack = defineSecret('PAYSTACK_SECRET_KEY');
const bible = defineSecret('BIBLE_API_KEY');
const services = createServices({ db, paystackSecret: () => paystack.value(), bibleKey: () => bible.value() });
const options = { invoker: 'public', region: 'us-central1', maxInstances: 5, timeoutSeconds: 60, memory: '256MiB',
  cors: [/^https:\/\/rtci-22582\.(web\.app|firebaseapp\.com)$/] };
const reportFailure = (details) => logError('Backend request failed', details);
const authenticated = (name) => authenticatedHandler({ name, onFailure: reportFailure,
  authenticate: (token) => getAuth().verifyIdToken(token, true), attest: (token) => getAppCheck().verifyToken(token), limit: services.limit, action: services[name] });
export const initializeGiving = onRequest({ ...options, secrets: [paystack] }, authenticated('initializeGiving'));
export const verifyGiving = onRequest({ ...options, secrets: [paystack] }, authenticated('verifyGiving'));
export const bibleContent = onRequest({ ...options, secrets: [bible] }, authenticatedHandler({ name: 'bible', onFailure: reportFailure,
  authenticate: (token) => getAuth().verifyIdToken(token, true), attest: (token) => getAppCheck().verifyToken(token), limit: services.limit, action: services.bible }));

export const paystackWebhook = onRequest({ invoker: 'public', region: 'us-central1', maxInstances: 5, timeoutSeconds: 60, secrets: [paystack] }, async (req, res) => {
  if (req.method !== 'POST') return res.sendStatus(405);
  if (!validSignature(req.rawBody, req.get('x-paystack-signature'), paystack.value())) return res.sendStatus(401);
  if (req.body?.event !== 'charge.success' || !/^rtci-[a-f0-9]{48}$/.test(req.body.data?.reference ?? '')) return res.sendStatus(200);
  try {
    await services.reconcile(req.body.data?.reference);
    return res.sendStatus(200);
  } catch (error) {
    if (error instanceof ApiError && error.code === 'payment_not_found') return res.sendStatus(200);
    logError('Webhook reconciliation failed', { code: error instanceof ApiError ? error.code : 'internal' });
    return res.sendStatus(error instanceof ApiError ? error.status : 500);
  }
});

export const syncLeadership = onDocumentWritten({ document: 'profiles/{uid}', region: 'us-central1', retry: true, maxInstances: 5 }, async (event) => {
  const target = db.collection('leadership').doc(event.params.uid);
  // Read the current profile so out-of-order delivery cannot republish a demoted leader.
  await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(db.collection('profiles').doc(event.params.uid));
    const profile = snapshot.data();
    if (!profile || !['admin', 'developer', 'department_head'].includes(profile.role)) {
      tx.delete(target); return;
    }
    tx.set(target, { name: profile.name ?? 'Church leader', title: profile.title ?? 'Church leader',
      department: profile.department ?? '', avatar_url: profile.avatar_url ?? null });
  });
});

// The event ID is recorded atomically with the increment so trigger retries cannot overcount.
export const countPrayerSupport = onDocumentCreated({ document: 'prayer_requests/{prayerId}/supporters/{uid}', region: 'us-central1', retry: true, maxInstances: 5 }, async (event) => {
  if (!event.id) return;
  const receipt = db.collection('_processed_events').doc(event.id.replaceAll('/', '_'));
  const prayer = db.collection('prayer_requests').doc(event.params.prayerId);
  await db.runTransaction(async (tx) => {
    const [seen, snapshot] = await Promise.all([tx.get(receipt), tx.get(prayer)]);
    if (seen.exists || !snapshot.exists) return;
    tx.update(prayer, { intercession_count: (snapshot.data().intercession_count ?? 0) + 1 });
    tx.set(receipt, { processed_at: new Date() });
  });
});

export const countGroupMembership = onDocumentWritten({ document: 'cell_groups/{groupId}/members/{uid}', region: 'us-central1', retry: true, maxInstances: 5 }, async (event) => {
  if (!event.id || !event.data) return;
  const delta = Number(event.data.after.exists) - Number(event.data.before.exists);
  if (!delta) return;
  const receipt = db.collection('_processed_events').doc(event.id.replaceAll('/', '_'));
  const group = db.collection('cell_groups').doc(event.params.groupId);
  await db.runTransaction(async (tx) => {
    const [seen, snapshot] = await Promise.all([tx.get(receipt), tx.get(group)]);
    if (seen.exists || !snapshot.exists) return;
    tx.update(group, { member_count: (snapshot.data().member_count ?? 0) + delta });
    tx.set(receipt, { processed_at: new Date() });
  });
});
