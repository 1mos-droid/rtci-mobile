# Android release readiness

The Android release build is complete, its backend is deployed, and the owner has passed the core phone acceptance checks.

Release target: **RTCI Connect 1.1.0+6**, Android package `com.rtci.app.rtc_mobile`. The owner chose Android first; iOS store distribution is deferred.

## Completed in the live project

- Firebase billing is enabled and the backend APIs are provisioned in `rtci-22582`.
- All seven Node.js 22 functions are active in `us-central1`: `initializeGiving`, `verifyGiving`, `bibleContent`, `paystackWebhook`, `syncLeadership`, `countPrayerSupport`, and `countGroupMembership`.
- Functions execute as `rtci-runtime@rtci-22582.iam.gserviceaccount.com`, with database access, auth read access, logging, and event-delivery permissions. Application code no longer runs as the project-wide Editor identity. Provider credentials are bound through Secret Manager, not Flutter assets or build defines.
- Scoped Firestore and Storage rules are deployed. App Check enforcement is enabled for both products, and the owner confirmed Home refresh and profile upload after enforcement. `_rate_limits.expires_at` has an active TTL policy.
- The configured default Storage bucket now exists in `US-CENTRAL1`, with uniform bucket access and public access prevention. Upload and backup infrastructure no longer points at a nonexistent bucket.
- A managed Firestore export completed before migration. Daily managed backups retain seven days; the separate pre-migration export folder expires after 30 days.
- The owner reviewed privileged profiles and retained only `isemuk8@gmail.com` as administrator. The reviewed migration preserved ambiguous prayers as private and retained financial history. Seven profiles, four prayers, and six historical financial records were preserved. Existing legacy payments are not newly certified by this migration.
- Release signing fingerprints were registered with Firebase. The Android Play Integrity API/provider is configured with a one-hour token lifetime. For the signed App Distribution APK, registered certificate validation and device integrity are required, and off-Play versions are allowed. The original default Play-recognition requirement blocked the first phone Bible test; it must not be reintroduced for off-Play testing.
- Public support, privacy and account-deletion pages are deployed at `https://rtci-22582-support.web.app/`, using the owner-specified mailbox `ea6971684@gmail.com`.
- The owner confirmed saving the live Paystack webhook URL: `https://us-central1-rtci-22582.cloudfunctions.net/paystackWebhook`.
- The owner chose to keep the current provider credentials for now and move to another provider account later. That switch requires updating Secret Manager and redeploying affected functions; it does not require embedding keys in the app.

## Verification

- **90 Flutter tests passed**: responsive layouts, enlarged text, account flows, pending checkout recovery, keyboard controls, reduced motion, account lifecycle and notification token cleanup.
- **18 backend/migration unit tests passed**: money validation, ownership, idempotency, webhook authentication, request attestation, strict Bible routes, and conservative privacy migration.
- **21 local emulator tests passed**: Firestore/Storage authorization and a repeatable migration rehearsal, including role demotion and backup guards.
- **21 live checks passed**: published support pages, authenticated Bible books and chapter access, rejection of unauthenticated/unattested requests, payment-reference validation, and unsigned/signed webhook handling. A single GHS 1 unpaid checkout was initialized, retried with the same reference/URL, and verified as pending. Its pending record, temporary account, debug token, and rate-limit records were removed. No charge was made.
- Flutter analysis is clean. The backend dependency audit found zero vulnerabilities. Release-source configuration checks pass.
- The final signed APK and AAB compiled successfully. Both signatures match the release keystore and the APK is not debuggable. Artifact sizes and SHA-256 hashes are recorded in `RELEASE_VERIFICATION.json`. The exact provider credential values were absent from checked source files and both artifacts. Do not use the old artifacts dated August 2026.

Automated live backend checks used an officially registered, temporary App Check debug credential. Native Play Integrity was separately confirmed on the owner’s physical Android phone, including after Firestore and Storage enforcement.

## Store rollout and optional extended acceptance

1. **Passed on the owner’s phone:** sign-in, Bible reading, Home refresh and profile upload. The initial Bible attestation error was resolved by applying the documented signed off-Play configuration. Home refresh and photo upload were checked again after Firestore/Storage enforcement was enabled.
2. For Play distribution, link Play Integrity to this Cloud project in Play Console and register the **Play app-signing** SHA-256/SHA-1 certificates in Firebase if Play signs with a different key from the upload keystore. The local release keystore is already registered. Review the attestation policy when changing distribution channels.
3. The final release is uploaded privately to Firebase App Distribution. No tester invitations or public Play rollout were sent. The verified AAB is ready for the intended Play testing track and store review. Store data-safety/privacy/deletion disclosures must describe the implemented behavior and the published support URLs.
4. Further acceptance can cover notification opt-in, TalkBack, account switching, and a voluntary real donation/reconciliation. Automated tests did not charge a payment or certify a real settlement. Paystack may retain its unpaid test checkout metadata after the pending application record is removed.

## Operations

- Check **Explore → Account deletion requests** as an administrator. Requests are durable and identity-bound; submission does not claim immediate deletion. Verify ownership and process requests within the published 30-day period. Remove the Auth account, profile/avatar, and associated personal records, while retaining only financial records required for accounting/legal obligations. Record completion in the request with a server timestamp. An email-only match is insufficient to remove unrelated legacy records.
- See `BACKEND_ROLLOUT.md` before future deployments or migrations. Never restore the previous permissive catch-all rules as a client compatibility workaround.
- CI source checks are in `.github/workflows/verify.yml`. The manual signed Android workflow requires the protected `android-release` environment and signing secrets; those secrets are not committed. The remote GitHub workflows have been prepared, not run from this session.
