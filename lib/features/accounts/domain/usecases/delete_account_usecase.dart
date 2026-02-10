import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

// =============================================================================
// DELETE ACCOUNT USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Deletes an account by its ID.
///
/// This use case validates the input and delegates deletion
/// to the [AccountRepository].
class DeleteAccountUseCase {
  final AccountRepository repository;

  DeleteAccountUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes an [accountId] and removes the corresponding account.
  ///
  /// Throws an [ArgumentError] if [accountId] is empty.
  Future<void> call(String accountId) {
    if (accountId.trim().isEmpty) {
      throw ArgumentError('Account ID cannot be empty');
    }
    return repository.deleteAccount(accountId);
  }
}
