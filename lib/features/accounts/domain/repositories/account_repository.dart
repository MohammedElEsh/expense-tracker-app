import 'package:expense_tracker/features/accounts/data/models/account.dart';

// =============================================================================
// ACCOUNT REPOSITORY - Clean Architecture Domain Layer
// =============================================================================

/// Abstract repository interface for account operations.
///
/// Defines the contract that any account data source implementation
/// must fulfill. This allows the domain/presentation layers to remain
/// independent of the concrete data source (REST API, local DB, etc.).
abstract class AccountRepository {
  // ===========================================================================
  // CRUD OPERATIONS
  // ===========================================================================

  /// Load all accounts.
  ///
  /// Returns a list of all [Account] objects for the current user/company.
  Future<List<Account>> loadAccounts();

  /// Create a new account.
  ///
  /// Takes an [Account] object and persists it via the data source.
  /// Returns the created [Account] with server-assigned fields (e.g. id).
  Future<Account> addAccount(Account account);

  /// Update an existing account.
  ///
  /// Takes an [Account] object with updated fields and persists the changes.
  /// Returns the updated [Account].
  Future<Account> updateAccount(Account account);

  /// Delete an account by its [accountId].
  ///
  /// Removes the account from the data source. Also handles cleanup
  /// such as clearing default account preferences if needed.
  Future<void> deleteAccount(String accountId);

  /// Get a single account by its [accountId].
  ///
  /// Returns the [Account] if found, or `null` if not found.
  Future<Account?> getAccount(String accountId);

  // ===========================================================================
  // HELPER OPERATIONS
  // ===========================================================================

  /// Get only active accounts.
  Future<List<Account>> getActiveAccounts();

  /// Update the balance of a specific account.
  Future<void> updateAccountBalance(String accountId, double newBalance);

  /// Calculate the total balance across all qualifying accounts.
  ///
  /// If [includeInactiveAccounts] is `true`, inactive accounts are included.
  Future<double> getTotalBalance({bool includeInactiveAccounts = false});

  /// Get balances grouped by [AccountType].
  Future<Map<AccountType, double>> getBalancesByType();

  // ===========================================================================
  // DEFAULT ACCOUNT MANAGEMENT
  // ===========================================================================

  /// Set the default account by [accountId].
  Future<void> setDefaultAccount(String accountId);

  /// Get the default account ID from local storage.
  Future<String?> getDefaultAccountId();

  /// Get the default [Account] object.
  ///
  /// Falls back to the first active account if the stored default is invalid.
  Future<Account?> getDefaultAccount();

  /// Clear the stored default account preference.
  Future<void> clearDefaultAccount();

  // ===========================================================================
  // TRANSFER & SEARCH
  // ===========================================================================

  /// Transfer money between two accounts.
  ///
  /// Returns `true` if the transfer was successful, `false` otherwise.
  Future<bool> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? notes,
  });

  /// Search accounts by a [query] string.
  ///
  /// Matches against name, type display name, and description.
  Future<List<Account>> searchAccounts(String query);

  /// Get aggregate account statistics.
  Future<Map<String, dynamic>> getAccountStatistics();

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached account data to force a fresh reload.
  void clearCache();
}
