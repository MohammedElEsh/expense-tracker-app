import 'package:expense_tracker/features/accounts/data/datasources/account_service.dart';
import 'package:expense_tracker/features/accounts/data/models/account_model.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({required AccountService accountService})
      : _service = accountService;

  final AccountService _service;

  @override
  Future<List<AccountEntity>> loadAccounts() => _service.loadAccounts();

  @override
  Future<AccountEntity> addAccount(AccountEntity account) =>
      _service.addAccount(AccountModel.fromEntity(account));

  @override
  Future<AccountEntity> updateAccount(AccountEntity account) =>
      _service.updateAccount(AccountModel.fromEntity(account));

  @override
  Future<void> deleteAccount(String accountId) =>
      _service.deleteAccount(accountId);

  @override
  Future<AccountEntity?> getAccount(String accountId) =>
      _service.getAccount(accountId);

  @override
  Future<List<AccountEntity>> getActiveAccounts() => _service.getActiveAccounts();

  @override
  Future<void> updateAccountBalance(String accountId, double newBalance) =>
      _service.updateAccountBalance(accountId, newBalance);

  @override
  Future<double> getTotalBalance({bool includeInactiveAccounts = false}) =>
      _service.getTotalBalance(includeInactiveAccounts: includeInactiveAccounts);

  @override
  Future<Map<AccountType, double>> getBalancesByType() =>
      _service.getBalancesByType();

  @override
  Future<void> setDefaultAccount(String accountId) =>
      _service.setDefaultAccount(accountId);

  @override
  Future<String?> getDefaultAccountId() => _service.getDefaultAccountId();

  @override
  Future<AccountEntity?> getDefaultAccount() => _service.getDefaultAccount();

  @override
  Future<void> clearDefaultAccount() => _service.clearDefaultAccount();

  @override
  Future<bool> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? notes,
  }) =>
      _service.transferMoney(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        notes: notes,
      );

  @override
  Future<List<AccountEntity>> searchAccounts(String query) =>
      _service.searchAccounts(query);

  @override
  Future<Map<String, dynamic>> getAccountStatistics() =>
      _service.getAccountStatistics();

  @override
  void clearCache() => _service.clearCache();

  @override
  Future<void> initializeDefaultAccounts() =>
      _service.initializeDefaultAccounts();

  @override
  Future<void> addToAccountBalance(String accountId, double amount) =>
      _service.addToAccountBalance(accountId, amount);

  @override
  Future<void> subtractFromAccountBalance(String accountId, double amount) =>
      _service.subtractFromAccountBalance(accountId, amount);
}
