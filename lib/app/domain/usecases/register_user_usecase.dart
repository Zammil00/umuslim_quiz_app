import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
