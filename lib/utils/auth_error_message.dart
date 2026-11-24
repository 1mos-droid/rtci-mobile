import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// True when the user dismissed a sign-in flow; no message should be shown.
bool isAuthCancellation(Object error) {
  if (error is GoogleSignInException) {
    return error.code == GoogleSignInExceptionCode.canceled;
  }
  if (error is FirebaseAuthException) {
    return const {
      'canceled',
      'cancelled',
      'web-context-canceled',
      'popup-closed-by-user',
      'cancelled-popup-request',
    }.contains(error.code);
  }
  return false;
}

/// Converts an authentication failure into text that is safe to show users.
/// Server and SDK messages are never shown verbatim.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact the church office.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Try signing in instead.';
      case 'weak-password':
        return 'Choose a stronger password with at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your connection and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked to another sign-in method. Sign in with that method instead.';
      case 'operation-not-allowed':
        return 'This sign-in method is not available right now.';
      case 'missing-google-token':
        return 'Google could not complete sign-in. Please try again.';
    }
  }
  if (error is FirebaseException &&
      (error.code == 'unavailable' || error.code == 'network-request-failed')) {
    return 'No internet connection. Check your connection and try again.';
  }
  if (error is GoogleSignInException) {
    return 'Google sign-in could not be completed. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
