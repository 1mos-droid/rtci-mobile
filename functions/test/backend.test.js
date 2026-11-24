import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHmac } from 'node:crypto';
import { createServices, amountInPesewas, validSignature, validatePayment } from '../src/services.js';
import { authenticatedHandler } from '../src/http.js';

class MemoryDb {
  values = new Map();
  queue = Promise.resolve();
  collection(name) { return { doc: id => this.ref(`${name}/${id}`) }; }
  ref(path) {
    return { path, get: async () => this.snapshot(path),
      update: async data => this.values.set(path, { ...this.values.get(path), ...data }) };
  }
  snapshot(path) { return { exists: this.values.has(path), data: () => this.values.get(path) }; }
  runTransaction(callback) {
    const operation = this.queue.then(async () => {
      const writes = [];
      const tx = { get: ref => ref.get(),
        create: (ref, data) => writes.push(() => { assert(!this.values.has(ref.path)); this.values.set(ref.path, data); }),
        set: (ref, data) => writes.push(() => this.values.set(ref.path, data)),
        update: (ref, data) => writes.push(() => this.values.set(ref.path, { ...this.values.get(ref.path), ...data })) };
      const result = await callback(tx);
      for (const write of writes) write();
      return result;
    });
    this.queue = operation.catch(() => {});
    return operation;
  }
}
const user = { uid: 'alice', email: 'alice@example.com' };
const input = { amount: 12.34, fund: 'Tithe', idempotencyKey: 'unique_checkout_request_123' };
function fixture() {
  const db = new MemoryDb();
  const calls = [];
  const service = createServices({ db, paystackSecret: () => 'test-secret', bibleKey: () => 'bible-secret',
    fetchImpl: async (url, options) => {
      calls.push({ url, options });
      if (url.endsWith('/initialize')) {
        const request = JSON.parse(options.body);
        return { ok: true, json: async () => ({ status: true, data: { reference: request.reference,
          authorization_url: 'https://checkout.paystack.com/test-session' } }) };
      }
      const record = [...db.values.entries()].find(([path]) => path.startsWith('transactions/'))?.[1];
      return { ok: true, json: async () => ({ status: true, data: payment(record) }) };
    } });
  return { db, calls, service };
}
function payment(record) { return { id: 123, status: 'success', reference: record.reference,
  amount: record.amount_subunit, currency: 'GHS', customer: { email: record.email },
  metadata: { member_id: record.member_id, fund: record.category } }; }

test('Amounts use integer subunits and reject invalid money', () => {
  assert.equal(amountInPesewas(12.34), 1234);
  for (const amount of [NaN, Infinity, -1, 0, Number.MIN_VALUE, 0.0000000001, 1.001, 1000001, '100', null]) assert.throws(() => amountInPesewas(amount));
});
test('Checkout binds identity, amount, fund and server-generated reference', async () => {
  const { service, db, calls } = fixture();
  const checkout = await service.initializeGiving(user, { ...input, email: 'attacker@example.com', member_id: 'mallory' });
  assert.match(checkout.reference, /^rtci-[a-f0-9]{48}$/);
  const record = db.values.get(`transactions/${checkout.reference}`);
  assert.equal(record.status, 'pending');
  assert.equal(record.member_id, 'alice');
  const request = JSON.parse(calls[0].options.body);
  assert.equal(request.email, 'alice@example.com');
  assert.equal(request.amount, 1234);
  assert.deepEqual(request.metadata, { member_id: 'alice', fund: 'Tithe' });
});
test('Retrying the same checkout returns its URL without creating another payment', async () => {
  const { service, calls, db } = fixture();
  const first = await service.initializeGiving(user, input);
  assert.deepEqual(await service.initializeGiving(user, input), first);
  assert.equal(calls.length, 1);
  assert.equal([...db.values.keys()].filter(key => key.startsWith('transactions/')).length, 1);
});
test('Concurrent initialize requests cannot create duplicate provider transactions', async () => {
  const { service, calls } = fixture();
  const results = await Promise.allSettled([service.initializeGiving(user, input), service.initializeGiving(user, input)]);
  assert.equal(calls.length, 1);
  assert(results.some(result => result.status === 'fulfilled'));
});
test('A reused request key cannot change the amount or fund', async () => {
  const { service } = fixture();
  await service.initializeGiving(user, input);
  await assert.rejects(service.initializeGiving(user, { ...input, amount: 400 }), { code: 'checkout_conflict' });
});
test('Invalid funds and request keys fail before any database or upstream action', async () => {
  const { service, db, calls } = fixture();
  await assert.rejects(service.initializeGiving(user, { ...input, fund: 'Anything' }));
  await assert.rejects(service.initializeGiving(user, { ...input, idempotencyKey: '../escape' }));
  assert.equal(db.values.size, 0); assert.equal(calls.length, 0);
});
test('A user cannot verify another account’s contribution', async () => {
  const { service, calls } = fixture();
  const checkout = await service.initializeGiving(user, input);
  await assert.rejects(service.verifyGiving({ uid: 'bob' }, checkout), { code: 'payment_not_found' });
  assert.equal(calls.length, 1);
});
test('Verification is idempotent and updates only an authenticated provider payment', async () => {
  const { service, db } = fixture();
  const checkout = await service.initializeGiving(user, input);
  await service.verifyGiving(user, checkout);
  const verifiedAt = db.values.get(`transactions/${checkout.reference}`).verified_at;
  await service.verifyGiving(user, checkout);
  assert.equal(db.values.get(`transactions/${checkout.reference}`).status, 'completed');
  assert.equal(db.values.get(`transactions/${checkout.reference}`).verified_at, verifiedAt);
});
test('Amount, currency, reference, identity, email and fund mismatches are rejected', () => {
  const record = { reference: 'r', member_id: 'alice', category: 'Tithe', amount_subunit: 1000, email: 'a@example.com' };
  for (const change of [{ amount: 1 }, { currency: 'USD' }, { reference: 'other' }, { status: 'pending' },
    { customer: { email: 'other@example.com' } }, { metadata: { member_id: 'bob', fund: 'Tithe' } },
    { metadata: { member_id: 'alice', fund: 'Offering' } }]) {
    assert.throws(() => validatePayment(record, { ...payment(record), ...change }), { code: 'payment_mismatch' });
  }
});
test('Provider failures never mark a contribution completed', async () => {
  const db = new MemoryDb();
  const service = createServices({ db, paystackSecret: () => 'test', bibleKey: () => 'test',
    fetchImpl: async () => { throw new Error('secret upstream details'); } });
  await assert.rejects(service.initializeGiving(user, input), { code: 'service_unavailable' });
  assert.equal([...db.values.values()][0].status, 'pending');
});
test('Webhook signatures authenticate exact raw bytes and reject tampering', () => {
  const raw = Buffer.from('{"event":"charge.success"}');
  const signature = createHmac('sha512', 'secret').update(raw).digest('hex');
  assert(validSignature(raw, signature, 'secret'));
  assert(!validSignature(Buffer.from('changed'), signature, 'secret'));
  assert(!validSignature(raw, 'xyz', 'secret'));
  assert(!validSignature(raw, signature, 'wrong'));
});
test('Rate limiting is atomic across concurrent requests', async () => {
  const { service } = fixture();
  const results = await Promise.allSettled(Array.from({ length: 15 }, () => service.limit('alice', 'initializeGiving')));
  assert.equal(results.filter(result => result.status === 'fulfilled').length, 10);
  assert.equal(results.filter(result => result.status === 'rejected').length, 5);
});
test('Bible proxy rejects arbitrary URLs, unsupported versions and path injection', async () => {
  const { service, calls } = fixture();
  for (const payload of [{ operation: 'books', version: 'NIV' }, { operation: 'chapter', version: 'KJV', chapterId: '../secret' },
    { operation: 'url', version: 'KJV', url: 'http://localhost' }]) await assert.rejects(service.bible(user, payload));
  assert.equal(calls.length, 0);
});
function response() { return { code: null, body: null, set() {}, status(code) { this.code = code; return this; }, json(body) { this.body = body; return this; } }; }
function request(token = 'valid') { return { method: 'POST', body: {}, get: name => name === 'x-firebase-appcheck' ? 'test-app-check' : token ? `Bearer ${token}` : undefined, is: () => true }; }
test('HTTP boundary rejects absent and revoked authentication before the action', async () => {
  let actions = 0;
  const handler = authenticatedHandler({ name: 'test', limit: async () => {}, attest: async () => ({}),
    authenticate: async token => { if (token === 'revoked') throw new Error(); return user; },
    action: async () => { actions++; } });
  for (const token of [null, 'revoked']) { const res = response(); await handler(request(token), res); assert.equal(res.code, 401); }
  assert.equal(actions, 0);
});
test('HTTP boundary hides internal errors and rejects oversized bodies', async () => {
  const handler = authenticatedHandler({ name: 'test', limit: async () => {}, attest: async () => ({}), authenticate: async () => user,
    action: async () => { throw new Error('sk_secret_token'); } });
  const res = response(); await handler(request(), res);
  assert.equal(res.code, 500); assert(!JSON.stringify(res.body).includes('sk_secret'));
  const huge = request(); huge.body = { value: 'x'.repeat(20000) };
  const rejected = response(); await handler(huge, rejected); assert.equal(rejected.code, 400);
});

test('HTTP boundary rejects absent or invalid App Check before executing the action', async () => {
  let actions = 0;
  const handler = authenticatedHandler({ name: 'test', authenticate: async () => user,
    attest: async () => { throw new Error('invalid attestation'); }, limit: async () => {},
    action: async () => { actions++; } });
  const invalid = response(); await handler(request(), invalid); assert.equal(invalid.code, 403);
  const missing = request(); missing.get = name => name === 'authorization' ? 'Bearer valid' : undefined;
  const rejected = response(); await handler(missing, rejected); assert.equal(rejected.code, 403);
  assert.equal(actions, 0);
});
