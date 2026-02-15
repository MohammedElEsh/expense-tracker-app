import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';

class AccountState extends Equatable {
  final List<AccountEntity> accounts;
  final AccountEntity? defaultAccount;
  final AccountEntity? selectedAccount;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;

  const AccountState({
    this.accounts = const [],
    this.defaultAccount,
    this.selectedAccount,
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    accounts,
    defaultAccount,
    selectedAccount,
    isLoading,
    hasLoaded,
    error,
  ];

  AccountState copyWith({
    List<AccountEntity>? accounts,
    AccountEntity? defaultAccount,
    AccountEntity? selectedAccount,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
    bool clearDefaultAccount = false,
    bool clearSelectedAccount = false,
  }) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      defaultAccount:
          clearDefaultAccount ? null : (defaultAccount ?? this.defaultAccount),
      selectedAccount:
          clearSelectedAccount
              ? null
              : (selectedAccount ?? this.selectedAccount),
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<AccountEntity> get activeAccounts =>
      accounts.where((a) => a.isActive).toList();

  // حساب الإجماليات
  double get totalBalance {
    return accounts
        .where((account) => account.isActive && account.includeInTotal)
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  Map<AccountType, double> get balancesByType {
    final Map<AccountType, double> balances = {};

    for (final account in accounts) {
      if (account.isActive && account.includeInTotal) {
        balances[account.type] =
            (balances[account.type] ?? 0.0) + account.balance;
      }
    }

    return balances;
  }

  List<AccountEntity> get lowBalanceAccounts {
    return activeAccounts.where((account) => account.isLowBalance).toList();
  }

  AccountEntity? getAccountById(String accountId) {
    try {
      return accounts.firstWhere((account) => account.id == accountId);
    } catch (e) {
      return null;
    }
  }

  List<AccountEntity> getAccountsByType(AccountType type) {
    return activeAccounts.where((account) => account.type == type).toList();
  }

  double getTotalBalanceByType(AccountType type) {
    return getAccountsByType(type)
        .where((account) => account.includeInTotal)
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  bool hasAccountType(AccountType type) {
    return accounts.any((account) => account.type == type && account.isActive);
  }

  int get totalActiveAccounts => activeAccounts.length;

  bool get hasLowBalanceAccounts => lowBalanceAccounts.isNotEmpty;

  double get averageBalance {
    final activeAccountsWithBalance =
        activeAccounts.where((account) => account.includeInTotal).toList();

    if (activeAccountsWithBalance.isEmpty) return 0.0;

    return totalBalance / activeAccountsWithBalance.length;
  }

  List<AccountEntity> get creditCards => getAccountsByType(AccountType.credit);

  double get totalCreditLimit {
    return creditCards.fold(
      0.0,
      (sum, account) => sum + (account.creditLimit ?? 0.0),
    );
  }

  double get totalCreditUsed {
    return creditCards.fold(
      0.0,
      (sum, account) => sum + ((account.creditLimit ?? 0.0) - account.balance),
    );
  }

  double get totalAvailableCredit {
    return creditCards.fold(
      0.0,
      (sum, account) => sum + account.availableBalance,
    );
  }

  double get averageCreditUsage {
    if (creditCards.isEmpty) return 0.0;

    final totalUsagePercentage = creditCards.fold(
      0.0,
      (sum, account) => sum + (account.creditUsagePercentage ?? 0.0),
    );

    return totalUsagePercentage / creditCards.length;
  }
}
