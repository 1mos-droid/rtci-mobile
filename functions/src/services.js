import { createHash, createHmac, timingSafeEqual } from 'node:crypto';
import { FieldValue } from 'firebase-admin/firestore';

export class ApiError extends Error {
  constructor(status, code, message) { super(message); this.status = status; this.code = code; }
}
export const funds = ['Tithe', 'Offering', 'Building Fund', 'Missions', 'Welfare', 'Seed'];
export function amountInPesewas(amount) {
  if (typeof amount !== 'number' || !Number.isFinite(amount) || amount < 0.01 || amount > 1000000
      || Math.abs(amount * 100 - Math.round(amount * 100)) > 0.000001) {
    throw new ApiError(400, 'invalid_amount', 'Enter a positive amount with at most two decimal places.');
  }
  return Math.round(amount * 100);
}
export function validSignature(raw, signature, secret) {
  if (!secret || !Buffer.isBuffer(raw) || !/^[a-f0-9]{128}$/i.test(signature ?? '')) return false;
  const expected = createHmac('sha512', secret).update(raw).digest();
  return timingSafeEqual(expected, Buffer.from(signature, 'hex'));
}
export function validatePayment(record, payment) {
  let metadata = payment?.metadata;
  if (typeof metadata === 'string') { try { metadata = JSON.parse(metadata); } catch { metadata = null; } }
  if (payment?.status !== 'success' || payment.reference !== record.reference
      || payment.amount !== record.amount_subunit || payment.currency !== 'GHS'
      || payment.customer?.email?.toLowerCase() !== record.email.toLowerCase()
      || metadata?.member_id !== record.member_id || metadata?.fund !== record.category) {
    throw new ApiError(409, 'payment_mismatch', 'The payment details do not match this contribution.');
  }
}

export function createServices({ db, paystackSecret, bibleKey, fetchImpl = fetch, clock = Date.now }) {
  async function upstream(url, options = {}) {
    try {
      const response = await fetchImpl(url, { ...options, signal: AbortSignal.timeout(15000) });
      const result = await response.json();
      if (!response.ok || result.status === false) throw new Error('Upstream refused request');
      return result;
    } catch {
      throw new ApiError(503, 'service_unavailable', 'This service is temporarily unavailable. Please try again.');
    }
  }
  function paymentHeaders() {
    const secret = paystackSecret();
    if (!secret) throw new ApiError(503, 'payments_unconfigured', 'Giving is temporarily unavailable. Please contact the church.');
    return { Authorization: `Bearer ${secret}`, 'Content-Type': 'application/json' };
  }
  async function limit(uid, action) {
    const minute = Math.floor(clock() / 60000);
    const id = createHash('sha256').update(`${uid}:${action}:${minute}`).digest('hex');
    const ref = db.collection('_rate_limits').doc(id);
    const maximum = action === 'initializeGiving' ? 10 : action === 'bible' ? 120 : 60;
    await db.runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      const count = snapshot.exists ? snapshot.data().count : 0;
      if (count >= maximum) throw new ApiError(429, 'rate_limited', 'Please wait a moment and try again.');
      tx.set(ref, { count: count + 1, expires_at: new Date((minute + 5) * 60000) });
    });
  }
  async function initializeGiving(user, input) {
    const amount = amountInPesewas(input.amount);
    if (!funds.includes(input.fund) || !/^[a-zA-Z0-9_-]{16,80}$/.test(input.idempotencyKey ?? '')) {
      throw new ApiError(400, 'invalid_checkout', 'Choose a valid fund and try again.');
    }
    // Read the authenticated account email; never trust a client-supplied payer identity.
    if (!user.email) throw new ApiError(400, 'email_required', 'An account email is required for giving.');
    const headers = paymentHeaders();
    const reference = `rtci-${createHash('sha256').update(`${user.uid}:${input.idempotencyKey}`).digest('hex').slice(0, 48)}`;
    const ref = db.collection('transactions').doc(reference);
    const existing = await db.runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      if (snapshot.exists) {
        const record = snapshot.data();
        if (record.amount_subunit !== amount || record.category !== input.fund || record.member_id !== user.uid) {
          throw new ApiError(409, 'checkout_conflict', 'This checkout reference belongs to a different contribution.');
        }
        if (record.status === 'completed') throw new ApiError(409, 'already_paid', 'This contribution has already been confirmed.');
        if (record.authorization_url) return record;
        throw new ApiError(409, 'checkout_in_progress', 'This checkout is still being prepared. Please check your giving status before trying again.');
      }
      tx.create(ref, {
        reference, member_id: user.uid, email: user.email, amount: amount / 100, amount_subunit: amount,
        currency: 'GHS', category: input.fund, type: 'contribution', campus: 'Main',
        description: `Online giving: ${input.fund}`, status: 'pending', source: 'paystack',
        checkout_state: 'initializing', logged_by: user.uid, date: FieldValue.serverTimestamp(),
      });
      return null;
    });
    if (existing) return { reference, authorizationUrl: existing.authorization_url };
    const response = await upstream('https://api.paystack.co/transaction/initialize', {
      method: 'POST', headers,
      body: JSON.stringify({ email: user.email, amount, currency: 'GHS', reference,
        metadata: { member_id: user.uid, fund: input.fund } }),
    });
    const url = response.data?.authorization_url;
    let parsed;
    try { parsed = new URL(url); } catch { /* rejected below */ }
    if (response.data?.reference !== reference || !parsed || parsed.protocol !== 'https:' || parsed.hostname !== 'checkout.paystack.com' || parsed.username || parsed.password || (parsed.port && parsed.port !== '443')) {
      throw new ApiError(503, 'invalid_checkout_response', 'Checkout could not be prepared. Please contact the church.');
    }
    await ref.update({ authorization_url: url, checkout_state: 'ready' });
    return { reference, authorizationUrl: url };
  }
  async function reconcile(reference, uid = null) {
    if (typeof reference !== 'string' || !/^rtci-[a-f0-9]{48}$/.test(reference)) {
      throw new ApiError(400, 'invalid_reference', 'This payment reference is invalid.');
    }
    const ref = db.collection('transactions').doc(reference);
    const snapshot = await ref.get();
    if (!snapshot.exists || (uid && snapshot.data().member_id !== uid)) {
      throw new ApiError(404, 'payment_not_found', 'This contribution could not be found.');
    }
    const record = snapshot.data();
    const response = await upstream(`https://api.paystack.co/transaction/verify/${reference}`, { headers: paymentHeaders() });
    if (response.data?.status !== 'success') return { reference, status: record.status === 'completed' ? 'completed' : 'pending' };
    validatePayment(record, response.data);
    await db.runTransaction(async (tx) => {
      const current = await tx.get(ref);
      validatePayment(current.data(), response.data);
      if (current.data().status !== 'completed') {
        tx.update(ref, { status: 'completed', verified_at: FieldValue.serverTimestamp(),
          provider_transaction_id: String(response.data.id), checkout_state: 'paid' });
      }
    });
    return { reference, status: 'completed', amount: record.amount, fund: record.category };
  }
  async function bible(_user, input) {
    const key = bibleKey();
    if (!key) throw new ApiError(503, 'bible_unconfigured', 'Bible reading is temporarily unavailable. Please try again later.');
    // Strict routes prevent clients from turning this endpoint into an arbitrary proxy.
    if (input.version !== 'KJV') throw new ApiError(400, 'invalid_version', 'This Bible version is not available.');
    const base = 'https://rest.api.bible/v1/bibles/de4e12af7f28f599-01';
    let path;
    if (input.operation === 'books') path = '/books';
    else if (input.operation === 'chapters' && /^[A-Z0-9]{2,8}$/.test(input.bookId ?? '')) path = `/books/${input.bookId}/chapters`;
    else if (input.operation === 'chapter' && /^[A-Z0-9]{2,8}\.[0-9]{1,3}$/.test(input.chapterId ?? '')) {
      path = `/chapters/${input.chapterId}?content-type=json&include-notes=false&include-titles=true&include-chapter-numbers=false&include-verse-numbers=true`;
    } else throw new ApiError(400, 'invalid_bible_request', 'Choose a valid book and chapter.');
    return upstream(base + path, { headers: { 'api-key': key } });
  }
  return { limit, initializeGiving, verifyGiving: (user, input) => reconcile(input.reference, user.uid), reconcile, bible };
}
