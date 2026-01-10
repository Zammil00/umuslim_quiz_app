import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<UserEntity> signIn({required String email, required String password});
}
