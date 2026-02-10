import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_service.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_event.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

// =============================================================================
// ACCOUNT BLOC - Clean Architecture Presentation Layer
// =============================================================================

/// BLoC for managing account state
/// Uses API-based AccountService for all operations
/// No Firebase dependencies
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountService _accountService;

  AccountBloc({AccountService? accountService})
    : _accountService = accountService ?? serviceLocator.accountService,
      super(const AccountState()) {
    on<InitializeAccounts>(_onInitializeAccounts);
    on<LoadAccounts>(_onLoadAccounts);
    on<LoadDefaultAccount>(_onLoadDefaultAccount);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
    on<SetDefaultAccount>(_onSetDefaultAccount);
    on<UpdateAccountBalance>(_onUpdateAccountBalance);
    on<AddToAccountBalance>(_onAddToAccountBalance);
    on<SubtractFromAccountBalance>(_onSubtractFromAccountBalance);
    on<TransferMoney>(_onTransferMoney);
    on<ToggleAccountActive>(_onToggleAccountActive);
    on<ToggleIncludeInTotal>(_onToggleIncludeInTotal);
  }

  Future<void> _onInitializeAccounts(
    InitializeAccounts event,
    Emitter<AccountState> emit,
  ) async {
    // Guard: Skip if already loading or already loaded with data
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) {
      debugPrint('⏭️ Skipping InitializeAccounts - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}, accounts: ${state.accounts.length}');
      return;
    }

    // Clear state immediately when initializing (for context changes)
    emit(
      state.copyWith(
        accounts: const [],
        defaultAccount: null,
        selectedAccount: null, // Clear selected account (filtering) - not auto-set
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
        emit(state.copyWith(accounts: newAccounts, isLoading: false, hasLoaded: true));
      } else {
        emit(state.copyWith(accounts: accounts, isLoading: false, hasLoaded: true));
      }

      // Load default account
      add(const LoadDefaultAccount());
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

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    // Guard: Skip if already loading or already loaded with data
    if (state.isLoading || (state.hasLoaded && state.accounts.isNotEmpty)) {
      debugPrint('⏭️ Skipping LoadAccounts - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}, accounts: ${state.accounts.length}');
      return;
    }

    // Clear state immediately when loading starts (for context changes)
    emit(
      state.copyWith(
        accounts: const [],
        defaultAccount: null,
        selectedAccount: null, // Clear selected account (filtering) - not auto-set
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final accounts = await _accountService.loadAccounts();
      debugPrint('🔄 Loaded ${accounts.length} accounts from API');

      // Create new list to ensure UI update
      final freshAccounts = List<Account>.from(accounts);

      emit(state.copyWith(accounts: freshAccounts, isLoading: false, hasLoaded: true));
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

  Future<void> _onLoadDefaultAccount(
    LoadDefaultAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      // Load default account for expense creation (NOT for filtering)
      final defaultAccount = await _accountService.getDefaultAccount();
      emit(state.copyWith(defaultAccount: defaultAccount));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحميل الحساب الافتراضي: $error'));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.addAccount(event.account);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));

      // If this is the first account, make it default (for expense creation)
      if (state.defaultAccount == null) {
        add(SetDefaultAccount(event.account.id));
      }
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في إضافة الحساب: $error'),
      );
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.updateAccount(event.account);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      
      // Update both defaultAccount and selectedAccount if they match the updated account
      Account? updatedDefaultAccount = state.defaultAccount?.id == event.account.id ? event.account : state.defaultAccount;
      Account? updatedSelectedAccount = state.selectedAccount?.id == event.account.id ? event.account : state.selectedAccount;
      
      emit(state.copyWith(
        accounts: accounts,
        isLoading: false,
        defaultAccount: updatedDefaultAccount,
        selectedAccount: updatedSelectedAccount,
      ));
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في تحديث الحساب: $error'),
      );
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _accountService.deleteAccount(event.accountId);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false));

      // If deleted account was default, reload default account
      if (state.defaultAccount?.id == event.accountId) {
        add(const LoadDefaultAccount());
      }
    } catch (error) {
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في حذف الحساب: $error'),
      );
    }
  }

  Future<void> _onSetDefaultAccount(
    SetDefaultAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      // Set default account for expense creation (NOT for filtering)
      await _accountService.setDefaultAccount(event.accountId);

      // Update default account in state
      final account = state.getAccountById(event.accountId);
      if (account != null) {
        emit(state.copyWith(defaultAccount: account));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تعيين الحساب الافتراضي: $error'));
    }
  }

  Future<void> _onUpdateAccountBalance(
    UpdateAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountService.updateAccountBalance(
        event.accountId,
        event.newBalance,
      );

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تحديث رصيد الحساب: $error'));
    }
  }

  Future<void> _onAddToAccountBalance(
    AddToAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountService.addToAccountBalance(event.accountId, event.amount);

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في إضافة مبلغ للحساب: $error'));
    }
  }

  Future<void> _onSubtractFromAccountBalance(
    SubtractFromAccountBalance event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountService.subtractFromAccountBalance(
        event.accountId,
        event.amount,
      );

      // Reload accounts directly
      final accounts = await _accountService.loadAccounts();
      emit(state.copyWith(accounts: accounts));
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في خصم مبلغ من الحساب: $error'));
    }
  }

  Future<void> _onTransferMoney(
    TransferMoney event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final success = await _accountService.transferMoney(
        fromAccountId: event.fromAccountId,
        toAccountId: event.toAccountId,
        amount: event.amount,
        notes: event.description,
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

  Future<void> _onToggleAccountActive(
    ToggleAccountActive event,
    Emitter<AccountState> emit,
  ) async {
    try {
      final account = state.getAccountById(event.accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(isActive: event.isActive);
        await _accountService.updateAccount(updatedAccount);

        // Reload accounts directly
        final accounts = await _accountService.loadAccounts();
        emit(state.copyWith(accounts: accounts));
      }
    } catch (error) {
      emit(state.copyWith(error: 'خطأ في تغيير حالة الحساب: $error'));
    }
  }

  Future<void> _onToggleIncludeInTotal(
    ToggleIncludeInTotal event,
    Emitter<AccountState> emit,
  ) async {
    try {
      final account = state.getAccountById(event.accountId);
      if (account != null) {
        final updatedAccount = account.copyWith(
          includeInTotal: event.includeInTotal,
        );
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
