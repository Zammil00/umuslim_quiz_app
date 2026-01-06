enum UserRole { admin, user }

class UserEntity {
  final String id;
  final String fullName;
  final UserRole role;
  final DateTime? createdAt;
  final String
  email; // Usually needed for registration even if not in profiles table explicitly, but auth.users has it.

  UserEntity({
    required this.id,
    required this.fullName,
    required this.role,
    this.createdAt,
    required this.email,
  });
}
