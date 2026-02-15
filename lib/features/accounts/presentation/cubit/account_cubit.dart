import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/add_to_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/initialize_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/set_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/subtract_from_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/transfer_money_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required GetAccountsUseCase getAccountsUseCase,
    required CreateAccountUseCase createAccountUseCase,
    required UpdateAccountUseCase updateAccountUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetDefaultAccountUseCase getDefaultAccountUseCase,
    required SetDefaultAccountUseCase setDefaultAccountUseCase,
    required InitializeAccountsUseCase initializeAccountsUseCase,
    required UpdateAccountBalanceUseCase updateAccountBalanceUseCase,
    required AddToAccountBalanceUseCase addToAccountBalanceUseCase,
    required SubtractFromAccountBalanceUseCase subtractFromAccountBalanceUseCase,
    required TransferMoneyUseCase transferMoneyUseCase,
  })  : _getAccounts = getAccountsUseCase,
        _createAccount = createAccountUseCase,
        _updateAccount = updateAccountUseCase,
        _deleteAccount = deleteAccountUseCase,
        _getDefaultAccount = getDefaultAccountUseCase,
        _setDefaultAccount = setDefaultAccountUseCase,
        _initializeAccounts = initializeAccountsUseCase,
        _updateAccountBalance = updateAccountBalanceUseCase,
        _addToAccountBalance = addToAccountBalanceUseCase,
        _subtractFromAccountBalance = subtractFromAccountBalanceUseCase,
        _transferMoney = transferMoneyUseCase,
        super(const AccountState());

  final GetAccountsUseCase _getAccounts;
  final CreateAccountUseCase _createAccount;
  final UpdateAccountUseCase _updateAccount;
  final DeleteAccountUseCase _deleteAccount;
  final GetDefaultAccountUseCase _getDefaultAccount;
  final SetDefaultAccountUseCase _setDefaultAccount;
  final InitializeAccountsUseCase _initializeAccounts;
  final UpdateAccountBalanceUseCase _updateAccountBalance;
  final AddToAccountBalanceUseCase _addToAccountBalance;
  final SubtractFromAccountBalanceUseCase _subtractFromAccountBalance;
  final TransferMoneyUseCase _transferMoney;

  Future<void> initializeAccounts() async {
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) return;

    emit(state.copyWith(
      accounts: const [],
      defaultAccount: null,
      selectedAccount: null,
      isLoading: true,
      clearError: true,
    ));

    try {
      final accounts = await _getAccounts();
      if (accounts.isEmpty) {
        await _initializeAccounts();
        final newAccounts = await _getAccounts();
        emit(state.copyWith(accounts: newAccounts, isLoading: false, hasLoaded: true));
      } else {
        emit(state.copyWith(accounts: accounts, isLoading: false, hasLoaded: true));
      }
      loadDefaultAccount();
    } catch (error) {
      debugPrint('❌ Error initializing accounts: $error');
      emit(state.copyWith(
        accounts: const [],
        defaultAccount: null,
        selectedAccount: null,
        isLoading: false,
        error: 'خطأ في تهيئة الحسابات: $error',
      ));
    }
  }

  Future<void> loadAccounts() async {
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) return;

    emit(state.copyWith(
      accounts: const [],
      defaultAccount: null,
      selectedAccount: null,
      isLoading: true,
      clearError: true,
    ));

    try {
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false, hasLoaded: true));
    } catch (error) {
      debugPrint('❌ Error loading accounts: $error');
      emit(state.copyWith(
        accounts: const [],
        isLoading: false,
        error: 'خطأ في تحميل الحسابات: $error',
      ));
    }
  }

  Future<void> loadDefaultAccount() async {
    try {
      final defaultAccount = await _getDefaultAccount();
      emit(state.copyWith(defaultAccount: defaultAccount));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحميل الحساب الافتراضي: $error'));
    }
  }

  Future<void> addAccount(AccountEntity account) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _createAccount(account);
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));
      if (state.defaultAccount == null) setDefaultAccount(account.id);
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: 'خطأ في إضافة الحساب: $error'));
    }
  }

  Future<void> updateAccount(AccountEntity account) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _updateAccount(account);
      final accounts = await _getAccounts();
      AccountEntity? updatedDefaultAccount =
          state.defaultAccount?.id == account.id ? account : state.defaultAccount;
      AccountEntity? updatedSelectedAccount =
          state.selectedAccount?.id == account.id ? account : state.selectedAccount;
      emit(state.copyWith(
        accounts: accounts,
        isLoading: false,
        defaultAccount: updatedDefaultAccount,
        selectedAccount: updatedSelectedAccount,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: 'خطأ في تحديث الحساب: $error'));
    }
  }

  Future<void> deleteAccount(String accountId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _deleteAccount(accountId);
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));
      if (state.defaultAccount?.id == accountId) loadDefaultAccount();
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: 'خطأ في حذف الحساب: $error'));
    }
  }

  Future<void> setDefaultAccount(String accountId) async {
    try {
      await _setDefaultAccount(accountId);
      final account = state.getAccountById(accountId);
      if (account != null) emit(state.copyWith(defaultAccount: account));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تعيين الحساب الافتراضي: $error'));
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _updateAccountBalance(accountId, newBalance);
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحديث رصيد الحساب: $error'));
    }
  }

  Future<void> addToAccountBalance(String accountId, double amount) async {
    try {
      await _addToAccountBalance(accountId, amount);
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في إضافة مبلغ للحساب: $error'));
    }
  }

  Future<void> subtractFromAccountBalance(String accountId, double amount) async {
    try {
      await _subtractFromAccountBalance(accountId, amount);
      final accounts = await _getAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في خصم مبلغ من الحساب: $error'));
    }
  }

  Future<void> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final success = await _transferMoney(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        notes: description,
      );
      if (success) {
        final accounts = await _getAccounts();
        emit(state.copyWith(accounts: accounts, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: 'فشل في تحويل الأموال'));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: 'خطأ في تحويل الأموال: $error'));
    }
  }

  Future<void> toggleAccountActive(String accountId, bool isActive) async {
    try {
      final account = state.getAccountById(accountId);
      if (account != null) {
        await _updateAccount(account.copyWith(isActive: isActive));
        final accounts = await _getAccounts();
        emit(state.copyWith(accounts: accounts));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تغيير حالة الحساب: $error'));
    }
  }

  Future<void> toggleIncludeInTotal(String accountId, bool includeInTotal) async {
    try {
      final account = state.getAccountById(accountId);
      if (account != null) {
        await _updateAccount(account.copyWith(includeInTotal: includeInTotal));
        final accounts = await _getAccounts();
        emit(state.copyWith(accounts: accounts));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تغيير إعداد الحساب: $error'));
    }
  }

  void setSelectedAccount(AccountEntity? account) {
    emit(state.copyWith(selectedAccount: account));
  }
}
