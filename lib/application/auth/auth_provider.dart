import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';
import 'package:rtc_mobile/infrastructure/auth/auth_repository.dart';
import 'package:rtc_mobile/services/notification_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository();

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AppUser?> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return null;
    
    final profile = await ref.read(authRepositoryProvider).fetchUserProfile(user.uid);
    if (profile != null) {
      // Side effect: update notification token
      NotificationService().updateToken();
      return profile;
    }
    
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@')[0] ?? 'Member',
      avatarUrl: user.photoURL,
      role: UserRole.member,
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
      // build() will automatically re-run due to authStateChangesProvider
      return state.value; 
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cred = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (cred.user != null) {
        await ref.read(authRepositoryProvider).createProfileIfMissing(cred.user!);
      }
      return state.value;
    });
  }

  Future<void> register(String fullName, String email, String password, {String? department}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).register(fullName, email, password, department: department);
      return state.value;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }

  Future<void> updateProfile({String? name, String? avatarUrl}) async {
    final user = state.value;
