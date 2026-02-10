import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';

/// Use case for retrieving all company users.
///
/// Fetches the complete list of users in the current company.
/// Only available in business mode.
class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Returns a list of user data maps.
  Future<List<Map<String, dynamic>>> call() {
    return repository.getAllUsers();
  }
}
