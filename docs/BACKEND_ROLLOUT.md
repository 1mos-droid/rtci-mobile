# Backend operations and future rollout

The backend and scoped rules have been deployed to `rtci-22582`. Read `RELEASE_READINESS.md` for current evidence and the remaining Android distribution gates. The owner chose the existing RTCI project as the target; migration rehearsals used only the local `demo-rtci` emulators.

## Provider configuration

Secrets are `PAYSTACK_SECRET_KEY` and `BIBLE_API_KEY` in Secret Manager. The Bible endpoint is `https://rest.api.bible`, using the configured KJV Bible. Provider keys passed read-only checks. Never put provider keys in Flutter build defines, source files, command arguments, or release notes.

To change provider accounts later, enter replacement values in the hidden CLI prompts:

```sh
firebase functions:secrets:set PAYSTACK_SECRET_KEY --project rtci-22582
firebase functions:secrets:set BIBLE_API_KEY --project rtci-22582
firebase deploy --only functions:rtci --project rtci-22582 --non-interactive --force
```

Secret versions are bound at deployment. Creating a new secret version alone does not update an already deployed function. Verify the new account, webhook configuration and Bible entitlement before retiring old versions.

Paystack webhook: `https://us-central1-rtci-22582.cloudfunctions.net/paystackWebhook`. Signed webhooks trigger server-to-server verification of the bound amount, currency, payer, fund and reference. Returning from a checkout page is not proof of payment.

## Runtime identity and data protection

The seven functions use `rtci-runtime@rtci-22582.iam.gserviceaccount.com`. The previous default compute identity no longer has accessor permission on the provider secrets. It has datastore user, Firebase Auth viewer, logging writer, Eventarc receiver and Cloud Run invoker roles. Secret Manager access is granted on the required named secrets. Do not replace this with project-wide Editor access.

The default Firebase bucket is `rtci-22582.firebasestorage.app` in `US-CENTRAL1`. Public access prevention and uniform bucket access are enabled. Storage rules restrict avatars to their owner and gallery uploads to staff. Cross-service staff checks depend on the deployed Firestore role records and the Storage service agent’s `roles/firebaserules.firestoreServiceAgent` permission. This permission was granted explicitly: the CLI skips its automatic role-check prompt in noninteractive deployments.

Firestore and Storage rules deny unlisted collections and unknown storage paths. Member reads are scoped in the client queries. App Check is required on custom backend requests. The App Distribution APK uses the documented off-Play policy: `allowUnrecognizedVersion: true`, `requireLicensed: false`, and `MEETS_DEVICE_INTEGRITY`; registered SHA-256 certificate checks still apply. Google Play-only recognition is inappropriate for a version that has not been published through Play. Review this policy again when choosing the final public distribution channel. Firestore/Storage App Check enforcement is now on, following native phone verification; register the Play app-signing certificate as well as the upload certificate if they differ.

`_rate_limits.expires_at` has TTL enabled. `_processed_events` receipts support trigger idempotency and must not be removed inside the delivery/retry window. Retry-enabled triggers read current state or record receipts atomically.

## Backup and migration procedure

A managed export completed before the reviewed migration. The private operation record and role approval are in ignored `.dart_tool/rtci-release/` on this workstation. Daily managed backups retain seven days; `rtci-release-backups/` export objects expire after 30 days. These files and buckets contain personal information and must remain private.

For a future migration:

1. Back up the intended database and wait for successful completion.
2. Review privileged identities against trusted administration. Never assume previously permissive role records are trustworthy.
3. Run the local emulator tests and migration rehearsal.
4. Run a dry-run with explicit project and approved-role inputs using trusted Application Default Credentials:

   ```sh
   node functions/scripts/migrate.js --project=PROJECT_ID --approved-roles=/private/path/approved-roles.json
   ```

5. The approval file maps reviewed UIDs to their existing privileged role. Unlisted privileged profiles are demoted to member. Inspect the counts before applying. The completed backup record must contain the matching `project`, `done: true`, and the managed export operation/output location.

   ```sh
   node functions/scripts/migrate.js --project=PROJECT_ID --approved-roles=/private/path/approved-roles.json --backup-record=/private/path/backup-operation.json --apply
   ```

The migration is dry-run by default and refuses live writes without approved roles and backup evidence. Only two explicit false privacy flags permit a legacy prayer to remain public. Email-keyed financial ownership is migrated only when a unique profile and original creator UID agree. Existing payment statuses are preserved for manual reconciliation, not invented or certified.

Apply migration before deploying newly introduced counting triggers. Re-running the migration after counting triggers are already active requires maintenance coordination: pausing membership changes and trigger delivery avoids count rebuilding racing event increments.

## Deployment

```sh
firebase deploy --only functions:rtci,firestore,storage --project rtci-22582 --non-interactive --force
firebase deploy --only hosting --project rtci-22582 --non-interactive
```

`--force` acknowledges the reviewed retry policy. It is appropriate only after checking the exact deployment plan. Retry-enabled triggers must remain idempotent. First-time service creation may require a retry after Google service-account permissions propagate; inspect deployment state rather than assuming an upload succeeded.

Hosting targets the separate `rtci-22582-support` site; it does not replace the project's original default site.

## Local verification

```sh
npm ci --prefix functions
npm test --prefix functions
npm --prefix functions run test:rules
npm audit --prefix functions
python3 scripts/check_release_config.py
flutter analyze --no-pub
flutter test --no-pub
```

Use a complete JDK 21, including `javac`. A verified local JDK exists in ignored `.dart_tool/rtci-jdk21`; no system Java installation was changed. From `android/`, build both signed artifacts:

```sh
./gradlew assembleRelease bundleRelease -Dorg.gradle.java.home=/absolute/path/to/jdk21 -Porg.gradle.java.installations.paths=/absolute/path/to/jdk21 --console=plain --no-daemon
```

Do not use the debug keystore for release. Verify APK/AAB signatures against the release certificate and record their SHA-256 hashes. Preserve R8 mapping files for crash diagnosis.

## CI signing

The manual `Build signed Android release` workflow uses a protected `android-release` GitHub environment. Configure `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `ANDROID_KEY_ALIAS` through GitHub's secret UI. The workflow materializes temporary files, refuses to overwrite existing signing files, and removes the temporary files on completion. Each Play upload needs a new build number.

## References

- [Firebase: security rules are not filters](https://firebase.google.com/docs/firestore/security/rules-query)
- [Firebase: App Check with Play Integrity](https://firebase.google.com/docs/app-check/android/play-integrity-provider)
- [Firebase: function retries](https://firebase.google.com/docs/functions/retries)
- [Paystack: verify payments](https://paystack.com/docs/payments/verify-payments/)
- [Paystack: webhook authentication](https://paystack.com/docs/payments/webhooks/)
