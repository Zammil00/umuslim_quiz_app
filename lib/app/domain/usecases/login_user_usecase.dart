import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository _repository;

  LoginUserUseCase(this._repository);

  Future<UserEntity> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
