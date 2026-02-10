// ✅ Clean Architecture - Presentation BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_api_service.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseApiService _expenseApiService;

  ExpenseBloc({ExpenseApiService? expenseApiService})
    : _expenseApiService =
          expenseApiService ?? serviceLocator.expenseApiService,
      super(const ExpenseState()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<EditExpense>(_onEditExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<DeleteAllExpenses>(_onDeleteAllExpenses);
    on<FilterExpensesByDate>(_onFilterExpensesByDate);
    on<FilterExpensesByMonth>(_onFilterExpensesByMonth);
    on<SearchExpenses>(_onSearchExpenses);
    on<FilterExpensesByCategory>(_onFilterExpensesByCategory);
    on<FilterExpensesByDateRange>(_onFilterExpensesByDateRange);
    on<FilterExpensesByAmountRange>(_onFilterExpensesByAmountRange);
    on<ClearExpenseFilters>(_onClearExpenseFilters);
    on<ReloadExpensesForCurrentMode>(_onReloadExpensesForCurrentMode);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    // Guard: Skip if already loading or already loaded with data (unless forceRefresh)
    if (!event.forceRefresh && (state.isInitialLoading || (state.hasLoaded && state.allExpenses.isNotEmpty))) {
      debugPrint('⏭️ Skipping LoadExpenses - isInitialLoading: ${state.isInitialLoading}, hasLoaded: ${state.hasLoaded}, expenses: ${state.allExpenses.length}');
      return;
    }

    // Preserve current expenses before clearing (for error recovery)
    final previousExpenses = state.allExpenses;
    
    // Clear state immediately when loading starts (for context changes)
    // This ensures old data is not visible while loading new data
    emit(
      state.copyWith(
        allExpenses: const [],
        filteredExpenses: const [],
        isInitialLoading: true,
        clearError: true,
      ),
    );

    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('🔄 تحميل المصروفات - الوضع: ${currentAppMode.name}');
      debugPrint('🔄 تحميل المصروفات - companyId: $companyId');
      debugPrint(
        '   Role-based filtering handled by backend via authentication token',
      );

      // Load expenses from API
      // The API handles filtering by:
      // - appMode and companyId (from SettingsService)
      // - User role (from authentication token):
      //   * Owner/Accountant: All company expenses
      //   * Employee: Only their own expenses (where employeeId matches)
      //   * Auditor: Read-only access to all expenses
      debugPrint('🔄 ExpenseBloc - Fetching expenses from API...');
      final allExpenses = await _expenseApiService.getExpenses();

      debugPrint(
        '📊 ExpenseBloc - API returned ${allExpenses.length} expenses',
      );

      // Log first few expense IDs for debugging
      if (allExpenses.isNotEmpty) {
        debugPrint(
          '📋 ExpenseBloc - First expense: id=${allExpenses.first.id}, '
          'amount=${allExpenses.first.amount}, '
          'category=${allExpenses.first.category}, '
          'accountId=${allExpenses.first.accountId}, '
          'employeeId=${allExpenses.first.employeeId}',
        );
      }

      // Sort by date descending (newest first)
      allExpenses.sort((a, b) => b.date.compareTo(a.date));
      debugPrint(
        '📊 ExpenseBloc - Sorted ${allExpenses.length} expenses by date',
      );

      final filteredExpenses = _applyFilters(allExpenses);
      debugPrint(
        '📊 ExpenseBloc - After applying filters: ${filteredExpenses.length} expenses',
      );

      final newState = state.copyWith(
        allExpenses: allExpenses,
        filteredExpenses: filteredExpenses,
        isInitialLoading: false,
        hasLoaded: true,
      );

      debugPrint(
        '✅ ExpenseBloc - Emitting state: '
        'allExpenses=${newState.allExpenses.length}, '
        'filteredExpenses=${newState.filteredExpenses.length}, '
        'isInitialLoading=${newState.isInitialLoading}',
      );

      emit(newState);
    } catch (error) {
      debugPrint('❌ خطأ في تحميل المصروفات: $error');
      String errorMessage = 'Failed to load expenses';

      // Handle specific error types
      if (error.toString().contains('ForbiddenException') ||
          error.toString().contains('403')) {
        errorMessage =
            'You do not have permission to view expenses. Please contact your administrator.';
      } else if (error.toString().contains('UnauthorizedException') ||
          error.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to load expenses: ${error.toString().replaceAll('Exception: ', '')}';
      }

      // Ensure isInitialLoading is always cleared on error to prevent stuck state
      // Restore previous expenses on error (they were cleared at start of load)
      emit(
        state.copyWith(
          isInitialLoading: false,
          error: errorMessage,
          allExpenses: previousExpenses, // Restore previous expenses on error
          filteredExpenses: _applyFilters(previousExpenses),
        ),
      );
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    final expense = event.expense;
    
    // Optimistic update: Add expense immediately to state for instant UI feedback
    final updatedExpenses = List<Expense>.from(state.allExpenses);
    updatedExpenses.add(expense);
    // Sort by date descending (newest first)
    updatedExpenses.sort((a, b) => b.date.compareTo(a.date));
    
    final filteredExpenses = _applyFilters(updatedExpenses);
    
    // Update state immediately with the new expense
    emit(
      state.copyWith(
        allExpenses: updatedExpenses,
        filteredExpenses: filteredExpenses,
        isMutating: true, // Set mutation flag
        clearError: true,
      ),
    );
    
    debugPrint('✅ Expense added optimistically to UI: ${expense.id}');
    debugPrint('   📊 Total expenses in state: ${updatedExpenses.length}');
    debugPrint('   📅 Expense date: ${expense.date}');
    debugPrint('   🏦 Expense accountId: ${expense.accountId}');
    debugPrint('   💰 Expense amount: ${expense.amount}');
    debugPrint('   📂 Expense category: ${expense.category}');

    try {
      debugPrint('💰 Creating expense via API...');

      // Create expense via API (get server response with real ID if needed)
      final createdExpense = await _expenseApiService.createExpense(
        accountId: expense.accountId,
        amount: expense.amount,
        category: expense.category,
        customCategory: expense.customCategory,
        date: expense.date,
        vendorName: expense.vendorName,
        invoiceNumber: expense.invoiceNumber,
        notes: expense.notes,
        projectId: expense.projectId,
        employeeId: expense.employeeId,
      );

      debugPrint('✅ Expense created successfully in API: ${createdExpense.id}');

      // If server returned a different ID, update the expense in state
      // Otherwise, the optimistic update already has the correct expense
      if (createdExpense.id != expense.id) {
        final serverUpdatedExpenses = List<Expense>.from(state.allExpenses);
        final index = serverUpdatedExpenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          serverUpdatedExpenses[index] = createdExpense;
          serverUpdatedExpenses.sort((a, b) => b.date.compareTo(a.date));
          final filteredExpenses = _applyFilters(serverUpdatedExpenses);
          emit(
            state.copyWith(
              allExpenses: serverUpdatedExpenses,
              filteredExpenses: filteredExpenses,
              isMutating: false, // Clear mutation flag
            ),
          );
        } else {
          // Clear mutation flag on success
          emit(state.copyWith(isMutating: false));
        }
      } else {
        // Clear mutation flag on success
        emit(state.copyWith(isMutating: false));
      }

      // Note: Account balance updates are handled by the backend API
      // No need to manually update account balance here

      // Note: Project and vendor statistics are calculated automatically
      // by the backend API based on expenses

      // No need to reload - expense already in state via optimistic update
    } catch (error) {
      debugPrint('❌ خطأ في إضافة المصروف: $error');
      
      // Rollback: Remove the optimistically added expense on error
      final rolledBackExpenses = List<Expense>.from(state.allExpenses)
        ..removeWhere((e) => e.id == expense.id);
      rolledBackExpenses.sort((a, b) => b.date.compareTo(a.date));
      final filteredExpenses = _applyFilters(rolledBackExpenses);
      
      String errorMessage = 'Failed to add expense';
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to add expense: ${error.toString().replaceAll('Exception: ', '')}';
      }
      
      emit(
        state.copyWith(
          allExpenses: rolledBackExpenses,
          filteredExpenses: filteredExpenses,
          isMutating: false, // Clear mutation flag on error
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> _onEditExpense(
    EditExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      debugPrint('✏️ تعديل مصروف: ${event.expense.id}');

      final expense = event.expense;

      // Update expense via API
      await _expenseApiService.updateExpense(
        expense.id,
        accountId: expense.accountId,
        amount: expense.amount,
        category: expense.category,
        customCategory: expense.customCategory,
        date: expense.date,
        vendorName: expense.vendorName,
        invoiceNumber: expense.invoiceNumber,
        notes: expense.notes,
        projectId: expense.projectId,
        employeeId: expense.employeeId,
      );

      debugPrint('✅ تم تحديث المصروف في API');

      // Note: Account balance updates are handled by the backend API
      // No need to manually update account balance here

      // Reload expenses with forceRefresh to bypass guard
      debugPrint('🔄 إعادة تحميل المصروفات بعد التعديل...');
      add(const LoadExpenses(forceRefresh: true));
    } catch (error) {
      debugPrint('❌ خطأ في تعديل المصروف: $error');
      emit(state.copyWith(error: 'Failed to edit expense: $error'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    final expenseId = event.expenseId;
    
    // Find the expense to be deleted (for rollback if needed)
    final expenseToDelete = state.allExpenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => throw StateError('Expense not found: $expenseId'),
    );
    
    // Optimistic update: Remove expense immediately from state for instant UI feedback
    final updatedExpenses = List<Expense>.from(state.allExpenses)
      ..removeWhere((e) => e.id == expenseId);
    
    // Sort by date descending (newest first)
    updatedExpenses.sort((a, b) => b.date.compareTo(a.date));
    
    final filteredExpenses = _applyFilters(updatedExpenses);
    
    // Update state immediately (remove expense, set mutation flag)
    emit(
      state.copyWith(
        allExpenses: updatedExpenses,
        filteredExpenses: filteredExpenses,
        isMutating: true, // Set mutation flag
        clearError: true,
      ),
    );
    
    debugPrint('✅ Expense removed optimistically from UI: $expenseId');

    try {
      debugPrint('🗑️ Deleting expense via API: $expenseId');

      // Delete expense via API
      await _expenseApiService.deleteExpense(expenseId);

      debugPrint('✅ Expense deleted successfully from API: $expenseId');

      // Note: Account balance updates are handled by the backend API
      // No need to manually update account balance here

      // Clear mutation flag on success
      // No need to reload - expense already removed via optimistic update
      emit(state.copyWith(isMutating: false));
    } catch (error) {
      debugPrint('❌ Error deleting expense: $error');
      
      // Rollback: Re-add the optimistically removed expense on error
      final rolledBackExpenses = List<Expense>.from(state.allExpenses);
      rolledBackExpenses.add(expenseToDelete);
      rolledBackExpenses.sort((a, b) => b.date.compareTo(a.date));
      final filteredExpenses = _applyFilters(rolledBackExpenses);
      
      String errorMessage = 'Failed to delete expense';
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to delete expense: ${error.toString().replaceAll('Exception: ', '')}';
      }
      
      // Rollback state: restore expense, clear mutation flag, show error
      emit(
        state.copyWith(
          allExpenses: rolledBackExpenses,
          filteredExpenses: filteredExpenses,
          isMutating: false, // Clear mutation flag on error
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> _onDeleteAllExpenses(
    DeleteAllExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      debugPrint('🗑️ حذف جميع المصروفات...');

      // Get all expenses and delete them one by one
      final expenses = await _expenseApiService.getExpenses();
      for (final expense in expenses) {
        await _expenseApiService.deleteExpense(expense.id);
      }

      debugPrint('✅ تم حذف جميع المصروفات');

      // Reload expenses with forceRefresh to bypass guard
      add(const LoadExpenses(forceRefresh: true));
    } catch (error) {
      debugPrint('❌ خطأ في حذف جميع المصروفات: $error');
      emit(state.copyWith(error: 'Failed to delete all expenses: $error'));
    }
  }

  void _onFilterExpensesByDate(
    FilterExpensesByDate event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDate: event.date,
        filteredExpenses: _applyFilters(state.allExpenses),
      ),
    );
  }

  void _onFilterExpensesByMonth(
    FilterExpensesByMonth event,
    Emitter<ExpenseState> emit,
  ) {
    final filteredExpenses =
        state.allExpenses.where((expense) {
          return expense.date.year == event.year &&
              expense.date.month == event.month;
        }).toList();

    emit(state.copyWith(filteredExpenses: filteredExpenses));
  }

  void _onSearchExpenses(SearchExpenses event, Emitter<ExpenseState> emit) {
    emit(
      state.copyWith(
        searchQuery: event.searchQuery.isEmpty ? null : event.searchQuery,
        filteredExpenses: _applyFilters(state.allExpenses),
      ),
    );
  }

  void _onFilterExpensesByCategory(
    FilterExpensesByCategory event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredExpenses: _applyFilters(state.allExpenses),
      ),
    );
  }

  void _onFilterExpensesByDateRange(
    FilterExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
        filteredExpenses: _applyFilters(state.allExpenses),
      ),
    );
  }

  void _onFilterExpensesByAmountRange(
    FilterExpensesByAmountRange event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        minAmount: event.minAmount,
        maxAmount: event.maxAmount,
        filteredExpenses: _applyFilters(state.allExpenses),
      ),
    );
  }

  void _onClearExpenseFilters(
    ClearExpenseFilters event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        clearSearchQuery: true,
        clearSelectedCategory: true,
        clearFilterDates: true,
        clearAmountRange: true,
        clearSelectedDate: true,
        filteredExpenses: state.allExpenses,
      ),
    );
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    var filtered = List<Expense>.from(expenses);

    // Search filter
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      filtered =
          filtered.where((expense) {
            return expense.notes.toLowerCase().contains(
                  state.searchQuery!.toLowerCase(),
                ) ||
                expense.category.toLowerCase().contains(
                  state.searchQuery!.toLowerCase(),
                );
          }).toList();
    }

    // Category filter
    if (state.selectedCategory != null) {
      filtered =
          filtered.where((expense) {
            return expense.category == state.selectedCategory;
          }).toList();
    }

    // Date filter (single date)
    if (state.selectedDate != null) {
      filtered =
          filtered.where((expense) {
            return expense.date.year == state.selectedDate!.year &&
                expense.date.month == state.selectedDate!.month &&
                expense.date.day == state.selectedDate!.day;
          }).toList();
    }

    // Date range filter
    if (state.filterStartDate != null) {
      filtered =
          filtered.where((expense) {
            return expense.date.isAfter(state.filterStartDate!) ||
                expense.date.isAtSameMomentAs(state.filterStartDate!);
          }).toList();
    }

    if (state.filterEndDate != null) {
      filtered =
          filtered.where((expense) {
            return expense.date.isBefore(
              state.filterEndDate!.add(const Duration(days: 1)),
            );
          }).toList();
    }

    // Amount range filter
    if (state.minAmount != null) {
      filtered =
          filtered.where((expense) {
            return expense.amount >= state.minAmount!;
          }).toList();
    }

    if (state.maxAmount != null) {
      filtered =
          filtered.where((expense) {
            return expense.amount <= state.maxAmount!;
          }).toList();
    }

    return filtered;
  }

  Future<void> _onReloadExpensesForCurrentMode(
    ReloadExpensesForCurrentMode event,
    Emitter<ExpenseState> emit,
  ) async {
    // إعادة تحميل المصروفات للوضع الحالي (force refresh)
    add(const LoadExpenses(forceRefresh: true));
  }

  /// Refresh expenses - ALWAYS re-fetches data, ignoring hasLoaded guard
  /// Used for manual refresh (pull-to-refresh)
  /// This bypasses the initial-load guard to ensure refresh always works
  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    debugPrint('🔄 RefreshExpenses - Force refreshing expenses (ignoring hasLoaded)');
    
    // Preserve current expenses before clearing (for error recovery)
    final previousExpenses = state.allExpenses;
    
    // Set refreshing state (keep existing expenses visible during refresh)
    emit(
      state.copyWith(
        isRefreshing: true,
        clearError: true,
      ),
    );

    try {
      debugPrint('🔄 RefreshExpenses - Fetching expenses from API...');
      final allExpenses = await _expenseApiService.getExpenses();

      debugPrint(
        '📊 RefreshExpenses - API returned ${allExpenses.length} expenses',
      );

      // Sort by date descending (newest first)
      allExpenses.sort((a, b) => b.date.compareTo(a.date));
      
      final filteredExpenses = _applyFilters(allExpenses);

      final newState = state.copyWith(
        allExpenses: allExpenses,
        filteredExpenses: filteredExpenses,
        isRefreshing: false,
        hasLoaded: true,
      );

      debugPrint(
        '✅ RefreshExpenses - Refresh complete: '
        'allExpenses=${newState.allExpenses.length}, '
        'filteredExpenses=${newState.filteredExpenses.length}',
      );

      emit(newState);
    } catch (error) {
      debugPrint('❌ RefreshExpenses - Error: $error');
      String errorMessage = 'Failed to refresh expenses';

      // Handle specific error types
      if (error.toString().contains('ForbiddenException') ||
          error.toString().contains('403')) {
        errorMessage =
            'You do not have permission to view expenses. Please contact your administrator.';
      } else if (error.toString().contains('UnauthorizedException') ||
          error.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to refresh expenses: ${error.toString().replaceAll('Exception: ', '')}';
      }

      // Ensure isRefreshing is always cleared on error to prevent stuck state
      // Keep existing expenses on error (don't clear them)
      emit(
        state.copyWith(
          isRefreshing: false,
          error: errorMessage,
          allExpenses: previousExpenses,
          filteredExpenses: _applyFilters(previousExpenses),
        ),
      );
    }
  }
}
