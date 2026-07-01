enum UserRole {
  member,
  departmentHead,
  admin,
  developer,
  guest;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'developer':
        return UserRole.developer;
      case 'admin':
        return UserRole.admin;
      case 'department_head':
        return UserRole.departmentHead;
      case 'member':
      default:
        return UserRole.member;
    }
  }

  String get label {
    switch (this) {
      case UserRole.developer: return 'DEVELOPER';
      case UserRole.admin: return 'ADMIN';
      case UserRole.departmentHead: return 'DEPT HEAD';
      case UserRole.member: return 'MEMBER';
      case UserRole.guest: return 'GUEST';
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
