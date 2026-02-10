import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

// =============================================================================
// CREATE ACCOUNT USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Creates a new account.
///
/// This use case validates the input and delegates creation
/// to the [AccountRepository].
class CreateAccountUseCase {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes an [Account] object and returns the newly created [Account]
  /// with server-assigned fields (e.g. id, timestamps).
  ///
  /// Throws an [ArgumentError] if the account name is empty.
  Future<Account> call(Account account) {
    if (account.name.trim().isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }
    return repository.addAccount(account);
  }
}
