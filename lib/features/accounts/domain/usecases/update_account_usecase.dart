import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

// =============================================================================
// UPDATE ACCOUNT USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Updates an existing account.
///
/// This use case validates the input and delegates the update
/// to the [AccountRepository].
class UpdateAccountUseCase {
  final AccountRepository repository;

  UpdateAccountUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes an [Account] object with the updated fields and returns
  /// the updated [Account] as confirmed by the data source.
  ///
  /// Throws an [ArgumentError] if the account ID or name is empty.
  Future<Account> call(Account account) {
    if (account.id.trim().isEmpty) {
      throw ArgumentError('Account ID cannot be empty');
    }
    if (account.name.trim().isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }
    return repository.updateAccount(account);
  }
}
