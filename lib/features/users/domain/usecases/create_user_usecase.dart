import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

/// Use case for adding a new user to the company.
///
/// Only the company owner can add users. Supports creating users
/// with roles: employee, accountant, or auditor.
class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes user details and returns the created user data map.
  /// The [role] cannot be [UserRole.owner].
  Future<Map<String, dynamic>> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return repository.addUser(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
