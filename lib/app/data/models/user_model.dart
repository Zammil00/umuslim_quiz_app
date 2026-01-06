import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.fullName,
    required super.role,
    super.createdAt,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String email) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: _stringToRole(json['role'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role
          .name, // Assuming enum name matches DB value, or use separate mapper
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static UserRole _stringToRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}
