import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_service.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

// =============================================================================
// ACCOUNT CUBIT - Clean Architecture Presentation Layer
// =============================================================================

/// Cubit for managing account state
/// Uses API-based AccountService for all operations
/// No Firebase dependencies
class AccountCubit extends Cubit<AccountState> {
  final AccountService _accountService;

  AccountCubit({AccountService? accountService})
    : _accountService = accountService ?? serviceLocator.accountService,
      super(const AccountState());

  Future<void> initializeAccounts() async {
    // Guard: Skip if already loading or already loaded with data
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) {
      debugPrint(
        '⏭️ Skipping InitializeAccounts - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}, accounts: ${state.accounts.length}',
      );
      return;
    }

    // Clear state immediately when initializing (for context changes)
    emit(
      state.copyWith(
        accounts: const [],
        defaultAccount: null,
        selectedAccount:
            null, // Clear selected account (filtering) - not auto-set
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      // Load accounts first
      final accounts = await _accountService.loadAccounts();

      // Initialize default account if needed
      if (accounts.isEmpty) {
        await _accountService.initializeDefaultAccounts();
        // Reload accounts after initialization
        final newAccounts = await _accountService.loadAccounts();
        emit(
          state.copyWith(
            accounts: newAccounts,
            isLoading: false,
            hasLoaded: true,
          ),
        );
      } else {
        emit(
          state.copyWith(accounts: accounts, isLoading: false, hasLoaded: true),
        );
      }

      // Load default account
      loadDefaultAccount();
    } catch (error) {
      debugPrint('❌ Error initializing accounts: $error');
      emit(
        state.copyWith(
          accounts: const [],
          defaultAccount: null,
          selectedAccount: null,
          isLoading: false,
          error: 'خطأ في تهيئة الحسابات: $error',
        ),
      );
    }
  }

  Future<void> loadAccounts() async {
    // Guard: Skip if already loading or already loaded with data
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) {
      debugPrint(
        '⏭️ Skipping LoadAccounts - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}, accounts: ${state.accounts.length}',
      );
      return;
    }

    // Clear state immediately when loading starts (for context changes)
    emit(
      state.copyWith(
        accounts: const [],
        defaultAccount: null,
        selectedAccount:
            null, // Clear selected account (filtering) - not auto-set
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final accounts = await _accountService.loadAccounts();
      debugPrint('🔄 Loaded ${accounts.length} accounts from API');

      // Create new list to ensure UI update
      final freshAccounts = List<Account>.from(accounts);

      emit(
        state.copyWith(
          accounts: freshAccounts,
          isLoading: false,
          hasLoaded: true,
        ),
      );
      debugPrint(
        '✅ AccountState updated - account count: ${freshAccounts.length}',
      );
    } catch (error) {
      debugPrint('❌ Error loading accounts: $error');
      emit(
        state.copyWith(
          accounts: const [],
          isLoading: false,
          error: 'خطأ في تحميل الحسابات: $error',
        ),
      );
    }
  }

  Future<void> loadDefaultAccount() async {
    try {
      // Load default account for expense creation (NOT for filtering)
      final defaultAccount = await _accountService.getDefaultAccount();
      emit(state.copyWith(defaultAccount: defaultAccount));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحميل الحساب الافتراضي: $error'));
    }
  }

  Future<void> addAccount(Account account) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.addAccount(account);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));

      // If this is the first account, make it default (for expense creation)
      if (state.defaultAccount == null) {
        setDefaultAccount(account.id);
      }
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في إضافة الحساب: $error'),
      );
    }
  }

  Future<void> updateAccount(Account account) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.updateAccount(account);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();

      // Update both defaultAccount and selectedAccount if they match the updated account
      Account? updatedDefaultAccount =
          state.defaultAccount?.id == account.id
              ? account
              : state.defaultAccount;
      Account? updatedSelectedAccount =
          state.selectedAccount?.id == account.id
              ? account
              : state.selectedAccount;

      emit(
        state.copyWith(
          accounts: accounts,
          isLoading: false,
          defaultAccount: updatedDefaultAccount,
          selectedAccount: updatedSelectedAccount,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في تحديث الحساب: $error'),
      );
    }
  }

  Future<void> deleteAccount(String accountId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.deleteAccount(accountId);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));

      // If deleted account was default, reload default account
      if (state.defaultAccount?.id == accountId) {
        loadDefaultAccount();
      }
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في حذف الحساب: $error'),
      );
    }
  }

  Future<void> setDefaultAccount(String accountId) async {
    try {
      // Set default account for expense creation (NOT for filtering)
      await _accountService.setDefaultAccount(accountId);

      // Update default account in state
      final account = state.getAccountById(accountId);
      if (account != null) {
        emit(state.copyWith(defaultAccount: account));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تعيين الحساب الافتراضي: $error'));
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      await _accountService.updateAccountBalance(accountId, newBalance);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحديث رصيد الحساب: $error'));
    }
  }

  Future<void> addToAccountBalance(String accountId, double amount) async {
    try {
      await _accountService.addToAccountBalance(accountId, amount);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في إضافة مبلغ للحساب: $error'));
    }
  }

  Future<void> subtractFromAccountBalance(
    String accountId,
    double amount,
  ) async {
    try {
      await _accountService.subtractFromAccountBalance(accountId, amount);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
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
      final success = await _accountService.transferMoney(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        notes: description,
      );

      if (success) {
        // Reload accounts directly
        final accounts = await _accountService.loadAccounts();
        emit(state.copyWith(accounts: accounts, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false, error: 'فشل في تحويل الأموال'));
      }
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في تحويل الأموال: $error'),
      );
    }
  }

  Future<void> toggleAccountActive(String accountId, bool isActive) async {
    try {
      final account = state.getAccountById(accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(isActive: isActive);
        await _accountService.updateAccount(updatedAccount);

        // Reload accounts directly
        final accounts = await _accountService.loadAccounts();
        emit(state.copyWith(accounts: accounts));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تغيير حالة الحساب: $error'));
    }
  }

  Future<void> toggleIncludeInTotal(
    String accountId,
    bool includeInTotal,
  ) async {
    try {
      final account = state.getAccountById(accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(includeInTotal: includeInTotal);
        await _accountService.updateAccount(updatedAccount);

        // Reload accounts directly
        final accounts = await _accountService.loadAccounts();
        emit(state.copyWith(accounts: accounts));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تغيير إعداد الحساب: $error'));
    }
  }
}
