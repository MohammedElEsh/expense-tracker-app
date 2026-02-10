import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for personal registration
class RegisterPersonalParams {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const RegisterPersonalParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
}

/// Use case for personal account registration
class RegisterPersonalUseCase {
  final AuthRepository repository;

  const RegisterPersonalUseCase(this.repository);

  /// Execute personal registration
  /// Returns [UserEntity] on success
  /// Throws exception on failure with readable error message
  Future<UserEntity> call(RegisterPersonalParams params) {
    return repository.registerPersonal(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
    );
  }
}
