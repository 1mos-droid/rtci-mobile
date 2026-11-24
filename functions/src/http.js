import { ApiError } from './services.js';

export function authenticatedHandler({ authenticate, attest, limit, action, name, onFailure = () => {} }) {
  return async (req, res) => {
    res.set('Cache-Control', 'no-store');
    if (req.method !== 'POST') return res.status(405).json({ error: { code: 'method_not_allowed', message: 'Use POST.' } });
    try {
      const bearer = /^Bearer (\S+)$/.exec(req.get('authorization') ?? '');
      if (!bearer) throw new ApiError(401, 'unauthenticated', 'Please sign in again.');
      let user;
      try { user = await authenticate(bearer[1]); } catch { throw new ApiError(401, 'unauthenticated', 'Please sign in again.'); }
      if (!user?.uid) throw new ApiError(401, 'unauthenticated', 'Please sign in again.');
      const appCheck = req.get('x-firebase-appcheck');
      if (!appCheck) throw new ApiError(403, 'app_verification_failed', 'This device could not be verified. Please try again.');
      try { await attest(appCheck); }
      catch { throw new ApiError(403, 'app_verification_failed', 'This device could not be verified. Please try again.'); }
      if (!req.is('application/json') || !req.body || Array.isArray(req.body) || typeof req.body !== 'object'
          || Buffer.byteLength(JSON.stringify(req.body)) > 16384) {
        throw new ApiError(400, 'invalid_request', 'Send a valid JSON request.');
      }
      await limit(user.uid, name);
      return res.status(200).json(await action(user, req.body));
    } catch (error) {
      // Never return upstream responses, credentials, stack traces or token contents.
      const known = error instanceof ApiError;
      // Log only stable error categories; request bodies and credentials are excluded.
      if (!known || error.status >= 500) onFailure({ action: name, code: known ? error.code : 'internal' });
      return res.status(known ? error.status : 500).json({ error: {
        code: known ? error.code : 'internal', message: known ? error.message : 'This request could not be completed. Please try again.',
      } });
    }
  };
}
