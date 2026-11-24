import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rtc_mobile/utils/auth_error_message.dart';

void main() {
  test('maps known auth codes to friendly text and hides server messages', () {
    final error = FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'The email address is already in use by another account.',
    );
    expect(authErrorMessage(error), startsWith('An account already exists'));
    expect(
      authErrorMessage(FirebaseAuthException(code: 'network-request-failed')),
      contains('internet connection'),
    );
  });

  test('unknown failures never expose raw details', () {
    final messages = [
      authErrorMessage(
        FirebaseAuthException(code: 'internal-error', message: 'RAW'),
      ),
      authErrorMessage(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'RAW',
        ),
      ),
      authErrorMessage(Exception('RAW')),
    ];
    for (final message in messages) {
      expect(message, isNot(contains('RAW')));
      expect(message, isNot(contains('[')));
    }
  });

  test('recognises user cancellation', () {
    expect(
      isAuthCancellation(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      ),
      isTrue,
    );
    expect(
      isAuthCancellation(FirebaseAuthException(code: 'web-context-canceled')),
      isTrue,
    );
    expect(
      isAuthCancellation(FirebaseAuthException(code: 'invalid-credential')),
      isFalse,
    );
  });
}
