import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/infrastructure/auth/auth_repository.dart';
import 'package:rtc_mobile/services/notification_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository();

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AppUser?> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return null;
    return _loadUser(user);
  }

  /// Signing in succeeds once Firebase Auth does; a profile that cannot be
  /// loaded or created falls back to the account details instead of failing.
  Future<AppUser> _loadUser(User user) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      var profile = await repository.fetchUserProfile(user.uid);
      if (profile == null) {
        await repository.createProfileIfMissing(user);
        profile = await repository.fetchUserProfile(user.uid);
      }
      if (profile != null) {
        try {
          NotificationService().updateToken();
        } catch (_) {}
        return profile;
      }
    } catch (e) {
      debugPrint('Profile unavailable, using account details: $e');
    }

    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!
          : (user.email != null && user.email!.contains('@')
                ? user.email!.split('@')[0]
                : 'Member'),
      avatarUrl: user.photoURL,
      role: UserRole.member,
    );
  }

  Future<void> _authenticate(Future<User?> Function() signIn) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await signIn();
      return user == null ? null : _loadUser(user);
    });
  }

  Future<void> login(String email, String password) => _authenticate(
    () => ref.read(authRepositoryProvider).login(email, password),
  );

  Future<void> signInWithGoogle() => _authenticate(
    () async =>
        (await ref.read(authRepositoryProvider).signInWithGoogle()).user,
  );

  Future<void> signInWithApple() => _authenticate(
    () async => (await ref.read(authRepositoryProvider).signInWithApple()).user,
  );

  Future<void> register(
    String fullName,
    String email,
    String password, {
    String? department,
  }) => _authenticate(
    () => ref
        .read(authRepositoryProvider)
        .register(fullName, email, password, department: department),
  );

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    final user = state.value;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    try {
      await ref.read(authRepositoryProvider).updateProfile(user.id, updates);
      final updatedUser = user.copyWith(name: name, avatarUrl: avatarUrl);
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final user = state.value;
    if (user == null) return null;

    try {
      final url = await ref
          .read(authRepositoryProvider)
          .uploadAvatar(user.id, imageFile);
      await updateProfile(avatarUrl: url);
      return url;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }
}
