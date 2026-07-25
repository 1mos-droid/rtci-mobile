import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';

void main() {
  group('AppUser & UserRole Tests', () {
    test('UserRole.fromString correctly parses roles', () {
      expect(UserRole.fromString('developer'), equals(UserRole.developer));
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('department_head'), equals(UserRole.departmentHead));
      expect(UserRole.fromString('member'), equals(UserRole.member));
      expect(UserRole.fromString(null), equals(UserRole.member));
      expect(UserRole.fromString('unknown'), equals(UserRole.member));
    });

    test('AppUser.fromFirestore parses profile data correctly', () {
      final data = {
        'email': 'test@example.com',
        'name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role': 'admin',
        'department': 'Media',
      };

      final user = AppUser.fromFirestore('user_123', data);

      expect(user.id, equals('user_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('John Doe'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.role, equals(UserRole.admin));
      expect(user.department, equals('Media'));
      expect(user.isAdmin, isTrue);
    });

    test('AppUser.fromFirestore handles missing/null profile fields gracefully', () {
      final data = <String, dynamic>{};

      final user = AppUser.fromFirestore('user_456', data);

      expect(user.id, equals('user_456'));
      expect(user.email, equals(''));
      expect(user.name, equals('Member'));
      expect(user.avatarUrl, isNull);
      expect(user.role, equals(UserRole.member));
      expect(user.department, isNull);
    });

    test('AppUser copyWith updates fields correctly', () {
      const user = AppUser(
        id: '123',
        email: 'test@example.com',
        name: 'Initial Name',
        role: UserRole.member,
      );

      final updated = user.copyWith(name: 'Updated Name', avatarUrl: 'https://new.url');

      expect(updated.id, equals('123'));
      expect(updated.name, equals('Updated Name'));
      expect(updated.avatarUrl, equals('https://new.url'));
      expect(updated.email, equals('test@example.com'));
    });
  });
}
