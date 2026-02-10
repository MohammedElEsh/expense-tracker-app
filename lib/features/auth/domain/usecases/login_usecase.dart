import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  /// Execute login with email and password
  /// Returns [UserEntity] on success
  /// Throws exception on failure with readable error message
  Future<UserEntity> call(String email, String password) {
    return repository.loginWithEmail(email: email, password: password);
  }
}
