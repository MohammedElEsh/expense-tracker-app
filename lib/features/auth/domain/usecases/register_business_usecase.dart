import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for business registration
class RegisterBusinessParams {
  final String name;
  final String email;
  final String password;
  final String companyName;
  final String? phone;

  const RegisterBusinessParams({
    required this.name,
    required this.email,
    required this.password,
    required this.companyName,
    this.phone,
  });
}

/// Use case for business account registration
class RegisterBusinessUseCase {
  final AuthRepository repository;

  const RegisterBusinessUseCase(this.repository);

  /// Execute business registration
  /// Returns [UserEntity] on success
  /// Throws exception on failure with readable error message
  Future<UserEntity> call(RegisterBusinessParams params) {
    return repository.registerBusiness(
      name: params.name,
      email: params.email,
      password: params.password,
      companyName: params.companyName,
      phone: params.phone,
    );
  }
}
