import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:rtc_mobile/domain/auth/user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockGoogleSignInAccount extends Mock implements gsi.GoogleSignInAccount {}
class MockGoogleSignInAuthorizationClient extends Mock implements gsi.GoogleSignInAuthorizationClient {}
class MockGoogleSignInClientAuthorization extends Mock implements gsi.GoogleSignInClientAuthorization {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  group('AuthRepository & Google Sign-In Unit Tests', () {
    test('GoogleSignInAccount authorization token retrieval', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockGoogleSignInAuthorizationClient();
      final mockClientAuth = MockGoogleSignInClientAuthorization();

      when(() => mockAccount.authorizationClient).thenReturn(mockAuthClient);
      when(() => mockAuthClient.authorizeScopes(any())).thenAnswer((_) async => mockClientAuth);
      when(() => mockClientAuth.accessToken).thenReturn('fake_access_token');

      final authClient = mockAccount.authorizationClient;
      final authz = await authClient.authorizeScopes(['email']);

      expect(authz.accessToken, equals('fake_access_token'));
    });

    test('Firebase Auth credential generation', () {
      final cred = GoogleAuthProvider.credential(
        accessToken: 'fake_access_token',
        idToken: 'fake_id_token',
      );

      expect(cred.providerId, equals('google.com'));
      expect(cred.signInMethod, equals('google.com'));
    });
  });
}

class FakeAuthCredential extends Fake implements AuthCredential {}
