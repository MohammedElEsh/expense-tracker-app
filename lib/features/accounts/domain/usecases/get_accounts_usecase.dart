import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

// =============================================================================
// GET ACCOUNTS USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Retrieves the list of all accounts.
///
/// This use case encapsulates the logic for fetching accounts,
/// delegating to the [AccountRepository] for data access.
class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// If [activeOnly] is `true`, only active accounts are returned.
  Future<List<Account>> call({bool activeOnly = false}) {
    if (activeOnly) {
      return repository.getActiveAccounts();
    }
    return repository.loadAccounts();
  }
}
