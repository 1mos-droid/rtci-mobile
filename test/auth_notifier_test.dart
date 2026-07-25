import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/infrastructure/auth/auth_repository.dart';
import 'package:rtc_mobile/application/auth/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user_123');
    when(() => mockUser.email).thenReturn('user@example.com');
    when(() => mockUser.displayName).thenReturn('Sanctuary Member');
    when(() => mockUser.photoURL).thenReturn(null);
  });

  group('AuthNotifier TDD Tests', () {
    test('build() creates profile if missing and returns valid AppUser profile', () async {
      const mockProfile = AppUser(
        id: 'user_123',
        email: 'user@example.com',
        name: 'Sanctuary Member',
        role: UserRole.member,
      );

      when(() => mockAuthRepository.fetchUserProfile('user_123'))
          .thenAnswer((_) async => mockProfile);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );

      container.listen(authNotifierProvider, (_, __) {});
      final user = await container.read(authNotifierProvider.future);

      expect(user, isNotNull);
      expect(user?.id, equals('user_123'));
      expect(user?.name, equals('Sanctuary Member'));
      expect(user?.role, equals(UserRole.member));
    });

    test('build() falls back to Firebase User properties if Firestore fetch fails', () async {
      when(() => mockAuthRepository.fetchUserProfile('user_123'))
          .thenThrow(Exception('Firestore network error'));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );

      container.listen(authNotifierProvider, (_, __) {});
      final user = await container.read(authNotifierProvider.future);

      expect(user, isNotNull);
      expect(user?.id, equals('user_123'));
      expect(user?.email, equals('user@example.com'));
      expect(user?.name, equals('Sanctuary Member'));
      expect(user?.role, equals(UserRole.member));
    });

    test('updateProfile updates user state correctly', () async {
      const initialProfile = AppUser(
        id: 'user_123',
        email: 'user@example.com',
        name: 'Old Name',
        role: UserRole.member,
      );

      when(() => mockAuthRepository.fetchUserProfile('user_123'))
          .thenAnswer((_) async => initialProfile);
      when(() => mockAuthRepository.updateProfile('user_123', any()))
          .thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          authStateChangesProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );

      container.listen(authNotifierProvider, (_, __) {});
      await container.read(authNotifierProvider.future);
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.updateProfile(name: 'New Name');

      final updatedUser = container.read(authNotifierProvider).value;
      expect(updatedUser?.name, equals('New Name'));
    });
  });
}
