import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';

// =============================================================================
// ACCOUNT REPOSITORY - Clean Architecture Domain Layer
// =============================================================================

/// Abstract repository interface for account operations.
/// Domain depends only on entities; no data/Flutter.
abstract class AccountRepository {
  Future<List<AccountEntity>> loadAccounts();
  Future<AccountEntity> addAccount(AccountEntity account);
  Future<AccountEntity> updateAccount(AccountEntity account);
  Future<void> deleteAccount(String accountId);
  Future<AccountEntity?> getAccount(String accountId);

  Future<List<AccountEntity>> getActiveAccounts();
  Future<void> updateAccountBalance(String accountId, double newBalance);
  Future<double> getTotalBalance({bool includeInactiveAccounts = false});
  Future<Map<AccountType, double>> getBalancesByType();

  Future<void> setDefaultAccount(String accountId);
  Future<String?> getDefaultAccountId();
  Future<AccountEntity?> getDefaultAccount();
  Future<void> clearDefaultAccount();

  Future<bool> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? notes,
  });

  Future<List<AccountEntity>> searchAccounts(String query);
  Future<Map<String, dynamic>> getAccountStatistics();

  void clearCache();
  Future<void> initializeDefaultAccounts();
  Future<void> addToAccountBalance(String accountId, double amount);
  Future<void> subtractFromAccountBalance(String accountId, double amount);
}
