import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

/// Use case for deleting a user from the company.
///
/// Only the company owner can delete users.
class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes the [userId] of the user to remove from the company.
  Future<void> call(String userId) {
    return repository.deleteUser(userId);
  }
}
