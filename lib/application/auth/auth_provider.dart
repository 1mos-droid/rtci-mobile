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
    
    try {
      var profile = await ref.read(authRepositoryProvider).fetchUserProfile(user.uid);
      if (profile == null) {
        await ref.read(authRepositoryProvider).createProfileIfMissing(user);
        profile = await ref.read(authRepositoryProvider).fetchUserProfile(user.uid);
      }
      if (profile != null) {
        try {
          NotificationService().updateToken();
        } catch (_) {}
        return profile;
      }
    } catch (e) {
      // Fallback if network or firestore fails
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

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final profile = await ref.read(authRepositoryProvider).fetchUserProfile(currentUser.uid);
        return profile ?? AppUser(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: (currentUser.displayName != null && currentUser.displayName!.trim().isNotEmpty)
              ? currentUser.displayName!
              : (currentUser.email != null && currentUser.email!.contains('@')
                  ? currentUser.email!.split('@')[0]
                  : 'Member'),
          avatarUrl: currentUser.photoURL,
          role: UserRole.member,
        );
      }
      return null;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cred = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (cred.user != null) {
        final profile = await ref.read(authRepositoryProvider).fetchUserProfile(cred.user!.uid);
        return profile ?? AppUser(
          id: cred.user!.uid,
          email: cred.user!.email ?? '',
          name: cred.user!.displayName ?? 'Member',
          avatarUrl: cred.user!.photoURL,
          role: UserRole.member,
        );
      }
      return null;
    });
  }

  Future<void> register(String fullName, String email, String password, {String? department}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).register(fullName, email, password, department: department);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final profile = await ref.read(authRepositoryProvider).fetchUserProfile(currentUser.uid);
        return profile ?? AppUser(
          id: currentUser.uid,
          email: email,
          name: fullName,
          department: department,
          role: UserRole.member,
        );
      }
      return null;
    });
  }

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
      final url = await ref.read(authRepositoryProvider).uploadAvatar(user.id, imageFile);
      await updateProfile(avatarUrl: url);
      return url;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }
}
