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
