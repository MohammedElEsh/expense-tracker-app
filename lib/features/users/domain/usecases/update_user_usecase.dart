import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

/// Use case for updating a user's details.
///
/// Only the company owner can update users. Supports updating
/// the user's name and/or role.
class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes the [userId] and optional [name] and [role] to update.
  /// At least one of [name] or [role] must be provided.
  /// Returns the updated user data map.
  Future<Map<String, dynamic>> call({
    required String userId,
    String? name,
    UserRole? role,
  }) {
    return repository.updateUser(userId: userId, name: name, role: role);
  }
}
