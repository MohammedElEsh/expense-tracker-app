// ✅ Clean Architecture - Presentation BLoC
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_api_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'recurring_expense_event.dart';
import 'recurring_expense_state.dart';

class RecurringExpenseBloc
    extends Bloc<RecurringExpenseEvent, RecurringExpenseState> {
  final RecurringExpenseApiService _apiService;

  RecurringExpenseBloc({RecurringExpenseApiService? apiService})
    : _apiService = apiService ?? serviceLocator.recurringExpenseService,
      super(const RecurringExpenseState()) {
    on<LoadRecurringExpenses>(_onLoadRecurringExpenses);
    on<AddRecurringExpense>(_onAddRecurringExpense);
    on<UpdateRecurringExpense>(_onUpdateRecurringExpense);
    on<DeleteRecurringExpense>(_onDeleteRecurringExpense);
    on<ToggleRecurringExpense>(_onToggleRecurringExpense);
    on<FilterRecurringExpensesByCategory>(_onFilterRecurringExpensesByCategory);
    on<FilterRecurringExpensesByStatus>(_onFilterRecurringExpensesByStatus);
    on<FilterRecurringExpensesByFrequency>(
      _onFilterRecurringExpensesByFrequency,
    );
    on<ClearRecurringExpenseFilters>(_onClearRecurringExpenseFilters);
    on<RefreshRecurringExpenses>(_onRefreshRecurringExpenses);
  }

  Future<void> _onLoadRecurringExpenses(
    LoadRecurringExpenses event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    // Guard: Skip if already loading or already loaded with data
    if (state.isLoading || (state.hasLoaded && state.allRecurringExpenses.isNotEmpty)) {
      debugPrint('⏭️ Skipping LoadRecurringExpenses - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}, expenses: ${state.allRecurringExpenses.length}');
      return;
    }

    // Clear state immediately when loading starts (for context changes)
    emit(
      state.copyWith(
        allRecurringExpenses: const [],
        filteredRecurringExpenses: const [],
        monthlyTotal: 0.0,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final recurringExpenses = await _apiService.loadRecurringExpenses();
      final monthlyTotal = await _apiService.calculateMonthlyRecurringTotal();

      emit(
        state.copyWith(
          allRecurringExpenses: recurringExpenses,
          filteredRecurringExpenses: _applyFilters(recurringExpenses),
          monthlyTotal: monthlyTotal,
          isLoading: false,
          hasLoaded: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          allRecurringExpenses: const [],
          filteredRecurringExpenses: const [],
          monthlyTotal: 0.0,
          isLoading: false,
          error: 'Failed to load recurring expenses: $error',
        ),
      );
    }
  }

  /// Refresh recurring expenses - ALWAYS re-fetches data, ignoring hasLoaded guard
  /// Used for manual refresh (pull-to-refresh)
  /// This bypasses the initial-load guard to ensure refresh always works
  Future<void> _onRefreshRecurringExpenses(
    RefreshRecurringExpenses event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    debugPrint('🔄 RefreshRecurringExpenses - Force refreshing (ignoring hasLoaded)');
    
    // Preserve current expenses before clearing (for error recovery)
    final previousExpenses = state.allRecurringExpenses;
    final previousMonthlyTotal = state.monthlyTotal;
    
    // Set loading state (keep existing expenses visible during refresh)
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      _apiService.clearCache();
      debugPrint('🔄 RefreshRecurringExpenses - Fetching from API...');
      final recurringExpenses = await _apiService.loadRecurringExpenses(
        forceRefresh: true,
      );
      final monthlyTotal = await _apiService.calculateMonthlyRecurringTotal();

      debugPrint(
        '📊 RefreshRecurringExpenses - API returned ${recurringExpenses.length} expenses',
      );

      final filteredExpenses = _applyFilters(recurringExpenses);

      final newState = state.copyWith(
        allRecurringExpenses: recurringExpenses,
        filteredRecurringExpenses: filteredExpenses,
        monthlyTotal: monthlyTotal,
        isLoading: false,
        hasLoaded: true,
        clearError: true,
      );

      debugPrint(
        '✅ RefreshRecurringExpenses - Refresh complete: '
        'allExpenses=${newState.allRecurringExpenses.length}, '
        'filteredExpenses=${newState.filteredRecurringExpenses.length}',
      );

      emit(newState);
    } catch (error) {
      debugPrint('❌ RefreshRecurringExpenses - Error: $error');
      String errorMessage = 'Failed to refresh recurring expenses';

      // Handle specific error types
      if (error.toString().contains('ForbiddenException') ||
          error.toString().contains('403')) {
        errorMessage =
            'You do not have permission to view recurring expenses. Please contact your administrator.';
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
            'Failed to refresh recurring expenses: ${error.toString().replaceAll('Exception: ', '')}';
      }

      // Ensure isLoading is always cleared on error to prevent stuck state
      // Keep existing expenses on error (don't clear them)
      emit(
        state.copyWith(
          isLoading: false,
          error: errorMessage,
          allRecurringExpenses: previousExpenses,
          filteredRecurringExpenses: _applyFilters(previousExpenses),
          monthlyTotal: previousMonthlyTotal,
        ),
      );
    }
  }

  Future<void> _onAddRecurringExpense(
    AddRecurringExpense event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    final expense = event.expense;
    
    // Optimistic update: Add expense immediately to state for instant UI feedback
    final updatedExpenses = List<RecurringExpense>.from(state.allRecurringExpenses);
    updatedExpenses.add(expense);
    // Sort by creation date or category (newest first)
    updatedExpenses.sort((a, b) => b.category.compareTo(a.category));
    
    final filteredExpenses = _applyFilters(updatedExpenses);
    
    // Calculate monthly total with new expense
    double newMonthlyTotal = state.monthlyTotal;
    if (expense.isActive) {
      switch (expense.recurrenceType) {
        case RecurrenceType.daily:
          newMonthlyTotal += expense.amount * 30;
          break;
        case RecurrenceType.weekly:
          newMonthlyTotal += expense.amount * 4;
          break;
        case RecurrenceType.monthly:
          newMonthlyTotal += expense.amount;
          break;
        case RecurrenceType.yearly:
          newMonthlyTotal += expense.amount / 12;
          break;
      }
    }
    
    // Update state immediately with the new expense
    emit(
      state.copyWith(
        allRecurringExpenses: updatedExpenses,
        filteredRecurringExpenses: filteredExpenses,
        monthlyTotal: newMonthlyTotal,
        clearError: true,
      ),
    );
    
    debugPrint('✅ Recurring expense added optimistically to UI: ${expense.id}');

    try {
      debugPrint('💰 Creating recurring expense via API...');

      // Create expense via API (get server response with real ID if needed)
      final createdExpense = await _apiService.createRecurringExpense(expense);

      debugPrint('✅ Recurring expense created successfully in API: ${createdExpense.id}');

      // If server returned a different ID, update the expense in state
      // Otherwise, the optimistic update already has the correct expense
      if (createdExpense.id != expense.id) {
        final serverUpdatedExpenses = List<RecurringExpense>.from(state.allRecurringExpenses);
        final index = serverUpdatedExpenses.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          serverUpdatedExpenses[index] = createdExpense;
          serverUpdatedExpenses.sort((a, b) => b.category.compareTo(a.category));
          final filteredExpenses = _applyFilters(serverUpdatedExpenses);
          
          // Recalculate monthly total with server data
          final serverMonthlyTotal = await _apiService.calculateMonthlyRecurringTotal();
          
          emit(
            state.copyWith(
              allRecurringExpenses: serverUpdatedExpenses,
              filteredRecurringExpenses: filteredExpenses,
              monthlyTotal: serverMonthlyTotal,
            ),
          );
        }
      } else {
        // Recalculate monthly total to ensure accuracy
        final serverMonthlyTotal = await _apiService.calculateMonthlyRecurringTotal();
        emit(
          state.copyWith(
            monthlyTotal: serverMonthlyTotal,
          ),
        );
      }

      // No need to reload - expense already in state via optimistic update
    } catch (error) {
      debugPrint('❌ خطأ في إضافة المصروف المتكرر: $error');
      
      // Rollback: Remove the optimistically added expense on error
      final rolledBackExpenses = List<RecurringExpense>.from(state.allRecurringExpenses)
        ..removeWhere((e) => e.id == expense.id);
      rolledBackExpenses.sort((a, b) => b.category.compareTo(a.category));
      final filteredExpenses = _applyFilters(rolledBackExpenses);
      
      // Restore original monthly total (recalculate from rolled back expenses)
      double rolledBackMonthlyTotal = 0.0;
      for (final exp in rolledBackExpenses.where((e) => e.isActive)) {
        switch (exp.recurrenceType) {
          case RecurrenceType.daily:
            rolledBackMonthlyTotal += exp.amount * 30;
            break;
          case RecurrenceType.weekly:
            rolledBackMonthlyTotal += exp.amount * 4;
            break;
          case RecurrenceType.monthly:
            rolledBackMonthlyTotal += exp.amount;
            break;
          case RecurrenceType.yearly:
            rolledBackMonthlyTotal += exp.amount / 12;
            break;
        }
      }
      
      String errorMessage = 'Failed to add recurring expense';
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to add recurring expense: ${error.toString().replaceAll('Exception: ', '')}';
      }
      
      emit(
        state.copyWith(
          allRecurringExpenses: rolledBackExpenses,
          filteredRecurringExpenses: filteredExpenses,
          monthlyTotal: rolledBackMonthlyTotal,
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> _onUpdateRecurringExpense(
    UpdateRecurringExpense event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Send full expense object to API for complete update
      await _apiService.updateRecurringExpense(event.expense);

      // Reload all recurring expenses
      add(const LoadRecurringExpenses());
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update recurring expense: $error',
        ),
      );
    }
  }

  Future<void> _onDeleteRecurringExpense(
    DeleteRecurringExpense event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    final expenseId = event.expenseId;
    
    // Find the expense to be deleted (for rollback if needed)
    final expenseToDelete = state.allRecurringExpenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => throw StateError('Recurring expense not found: $expenseId'),
    );
    
    // Optimistic update: Remove expense immediately from state for instant UI feedback
    final updatedExpenses = List<RecurringExpense>.from(state.allRecurringExpenses)
      ..removeWhere((e) => e.id == expenseId);
    
    // Sort by category (same as add)
    updatedExpenses.sort((a, b) => b.category.compareTo(a.category));
    
    final filteredExpenses = _applyFilters(updatedExpenses);
    
    // Calculate monthly total without deleted expense
    double newMonthlyTotal = state.monthlyTotal;
    if (expenseToDelete.isActive) {
      switch (expenseToDelete.recurrenceType) {
        case RecurrenceType.daily:
          newMonthlyTotal -= expenseToDelete.amount * 30;
          break;
        case RecurrenceType.weekly:
          newMonthlyTotal -= expenseToDelete.amount * 4;
          break;
        case RecurrenceType.monthly:
          newMonthlyTotal -= expenseToDelete.amount;
          break;
        case RecurrenceType.yearly:
          newMonthlyTotal -= expenseToDelete.amount / 12;
          break;
      }
    }
    
    // Update state immediately (remove expense)
    emit(
      state.copyWith(
        allRecurringExpenses: updatedExpenses,
        filteredRecurringExpenses: filteredExpenses,
        monthlyTotal: newMonthlyTotal,
        clearError: true,
      ),
    );
    
    debugPrint('✅ Recurring expense removed optimistically from UI: $expenseId');

    try {
      debugPrint('🗑️ Deleting recurring expense via API: $expenseId');

      // Delete expense via API
      await _apiService.deleteRecurringExpense(expenseId);

      debugPrint('✅ Recurring expense deleted successfully from API: $expenseId');

      // No need to reload - expense already removed via optimistic update
    } catch (error) {
      debugPrint('❌ Error deleting recurring expense: $error');
      
      // Rollback: Re-add the optimistically removed expense on error
      final rolledBackExpenses = List<RecurringExpense>.from(state.allRecurringExpenses);
      rolledBackExpenses.add(expenseToDelete);
      rolledBackExpenses.sort((a, b) => b.category.compareTo(a.category));
      final filteredExpenses = _applyFilters(rolledBackExpenses);
      
      // Restore original monthly total
      double rolledBackMonthlyTotal = state.monthlyTotal;
      if (expenseToDelete.isActive) {
        switch (expenseToDelete.recurrenceType) {
          case RecurrenceType.daily:
            rolledBackMonthlyTotal += expenseToDelete.amount * 30;
            break;
          case RecurrenceType.weekly:
            rolledBackMonthlyTotal += expenseToDelete.amount * 4;
            break;
          case RecurrenceType.monthly:
            rolledBackMonthlyTotal += expenseToDelete.amount;
            break;
          case RecurrenceType.yearly:
            rolledBackMonthlyTotal += expenseToDelete.amount / 12;
            break;
        }
      }
      
      String errorMessage = 'Failed to delete recurring expense';
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to delete recurring expense: ${error.toString().replaceAll('Exception: ', '')}';
      }
      
      // Rollback state: restore expense, restore monthly total, show error
      emit(
        state.copyWith(
          allRecurringExpenses: rolledBackExpenses,
          filteredRecurringExpenses: filteredExpenses,
          monthlyTotal: rolledBackMonthlyTotal,
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> _onToggleRecurringExpense(
    ToggleRecurringExpense event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    // Optimistic update for better UX
    final updatedExpenses =
        state.allRecurringExpenses.map((expense) {
          if (expense.id == event.expenseId) {
            return expense.copyWith(isActive: event.isActive);
          }
          return expense;
        }).toList();

    emit(
      state.copyWith(
        allRecurringExpenses: updatedExpenses,
        filteredRecurringExpenses: _applyFilters(updatedExpenses),
        clearError: true,
      ),
    );

    try {
      await _apiService.toggleRecurringExpense(event.expenseId, event.isActive);

      // Reload to get accurate monthly total
      add(const RefreshRecurringExpenses());
    } catch (error) {
      // Revert optimistic update on error
      add(const LoadRecurringExpenses());
      emit(state.copyWith(error: 'Failed to toggle recurring expense: $error'));
    }
  }

  void _onFilterRecurringExpensesByCategory(
    FilterRecurringExpensesByCategory event,
    Emitter<RecurringExpenseState> emit,
  ) {
    final newState = state.copyWith(selectedCategory: event.category);
    emit(
      newState.copyWith(
        filteredRecurringExpenses: _applyFilters(
          state.allRecurringExpenses,
          category: event.category,
          status: state.selectedStatus,
          frequency: state.selectedFrequency,
        ),
      ),
    );
  }

  void _onFilterRecurringExpensesByStatus(
    FilterRecurringExpensesByStatus event,
    Emitter<RecurringExpenseState> emit,
  ) {
    final newState = state.copyWith(selectedStatus: event.isActive);
    emit(
      newState.copyWith(
        filteredRecurringExpenses: _applyFilters(
          state.allRecurringExpenses,
          category: state.selectedCategory,
          status: event.isActive,
          frequency: state.selectedFrequency,
        ),
      ),
    );
  }

  void _onFilterRecurringExpensesByFrequency(
    FilterRecurringExpensesByFrequency event,
    Emitter<RecurringExpenseState> emit,
  ) {
    final newState = state.copyWith(selectedFrequency: event.frequency);
    emit(
      newState.copyWith(
        filteredRecurringExpenses: _applyFilters(
          state.allRecurringExpenses,
          category: state.selectedCategory,
          status: state.selectedStatus,
          frequency: event.frequency,
        ),
      ),
    );
  }

  void _onClearRecurringExpenseFilters(
    ClearRecurringExpenseFilters event,
    Emitter<RecurringExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        clearSelectedCategory: true,
        clearSelectedStatus: true,
        clearSelectedFrequency: true,
        filteredRecurringExpenses: state.allRecurringExpenses,
      ),
    );
  }

  List<RecurringExpense> _applyFilters(
    List<RecurringExpense> expenses, {
    String? category,
    bool? status,
    RecurrenceType? frequency,
  }) {
    var filtered = List<RecurringExpense>.from(expenses);

    // Use provided values or fall back to current state
    final filterCategory = category ?? state.selectedCategory;
    final filterStatus = status ?? state.selectedStatus;
    final filterFrequency = frequency ?? state.selectedFrequency;

    // Category filter
    if (filterCategory != null) {
      filtered =
          filtered.where((expense) {
            return expense.category == filterCategory;
          }).toList();
    }

    // Status filter
    if (filterStatus != null) {
      filtered =
          filtered.where((expense) {
            return expense.isActive == filterStatus;
          }).toList();
    }

    // Frequency filter
    if (filterFrequency != null) {
      filtered =
          filtered.where((expense) {
            return expense.recurrenceType == filterFrequency;
          }).toList();
    }

    return filtered;
  }

  // Helper method to get summary for dashboard
  Map<String, dynamic> getSummary() {
    return {
      'totalActive': state.totalActiveRecurringExpenses,
      'totalInactive': state.totalInactiveRecurringExpenses,
      'monthlyTotal': state.monthlyTotal,
      'yearlyTotal': state.totalYearlyRecurringAmount,
    };
  }
}
