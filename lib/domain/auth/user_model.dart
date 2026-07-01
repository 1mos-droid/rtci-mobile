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
  final UserRole role;
  final String? department;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.department,
  });

  factory AppUser.fromFirestore(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Member',
      avatarUrl: data['avatar_url'],
      role: UserRole.fromString(data['role']),
      department: data['department'],
    );
  }

  AppUser copyWith({
    String? name,
    String? avatarUrl,
    UserRole? role,
    String? department,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      department: department ?? this.department,
    );
  }

  bool get isAdmin => role == UserRole.admin || role == UserRole.developer;
  bool get isDeptHead => role == UserRole.departmentHead || role == UserRole.admin || role == UserRole.developer;
  bool get isDeveloper => role == UserRole.developer;
}
