// =============================================================================
// BUDGET BLOC - Clean Architecture Presentation Layer
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_service.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// BLoC for managing budget state
/// Uses API-based BudgetService for all operations
/// No Firebase dependencies
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetService _budgetService;

  BudgetBloc({BudgetService? budgetService})
    : _budgetService = budgetService ?? serviceLocator.budgetService,
      super(const BudgetState()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<LoadBudgetsForMonth>(_onLoadBudgetsForMonth);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<SaveBudget>(_onSaveBudget);
    // on<DeleteBudget>(_onDeleteBudget);
    // on<GetBudgetForCategory>(_onGetBudgetForCategory);
    on<UpdateBudgetSpent>(_onUpdateBudgetSpent);
    on<RefreshBudgets>(_onRefreshBudgets);
  }

  /// Load all budgets (current month by default)
  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    // Clear state immediately when loading starts (for context changes)
    emit(
      state.copyWith(
        allBudgets: const [],
        monthlyBudgets: const {},
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final now = DateTime.now();
      final budgets = await _budgetService.loadBudgets(
        month: state.selectedMonth ?? now.month,
        year: state.selectedYear ?? now.year,
      );

      // Filter out deleted budgets (limit = 0)
      final activeBudgets = budgets.where((b) => b.limit > 0).toList();

      // Create monthly budgets map
      final Map<String, Budget> monthlyBudgets = {};
      for (final budget in activeBudgets) {
        monthlyBudgets[budget.category] = budget;
      }

      emit(
        state.copyWith(
          allBudgets: activeBudgets,
          monthlyBudgets: monthlyBudgets,
          isLoading: false,
        ),
      );

      debugPrint('✅ Loaded ${activeBudgets.length} budgets');
    } catch (error) {
      debugPrint('❌ Error loading budgets: $error');
      emit(
        state.copyWith(
          allBudgets: const [],
          monthlyBudgets: const {},
          isLoading: false,
          error: 'خطأ في تحميل الميزانيات: $error',
        ),
      );
    }
  }

  /// Load budgets for a specific month and year
  Future<void> _onLoadBudgetsForMonth(
    LoadBudgetsForMonth event,
    Emitter<BudgetState> emit,
  ) async {
    // Clear state immediately when loading starts (for context changes)
    emit(
      state.copyWith(
        allBudgets: const [],
        monthlyBudgets: const {},
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final budgets = await _budgetService.loadBudgets(
        month: event.month,
        year: event.year,
      );

      // Filter out deleted budgets (limit = 0)
      final activeBudgets = budgets.where((b) => b.limit > 0).toList();

      // Create monthly budgets map
      final Map<String, Budget> monthlyBudgets = {};
      for (final budget in activeBudgets) {
        monthlyBudgets[budget.category] = budget;
      }

      emit(
        state.copyWith(
          allBudgets: activeBudgets,
          monthlyBudgets: monthlyBudgets,
          selectedYear: event.year,
          selectedMonth: event.month,
          isLoading: false,
        ),
      );

      debugPrint(
        '✅ Loaded ${activeBudgets.length} budgets for ${event.month}/${event.year}',
      );
    } catch (error) {
      debugPrint('❌ Error loading monthly budgets: $error');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'خطأ في تحميل ميزانيات الشهر: $error',
        ),
      );
    }
  }

  /// Create or update a budget
  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint(
        '📤 Creating budget: ${event.category} - ${event.limit} for ${event.month}/${event.year}',
      );

      await _budgetService.createOrUpdateBudget(
        category: event.category,
        limit: event.limit,
        month: event.month,
        year: event.year,
      );

      // Reload budgets for the month
      add(LoadBudgetsForMonth(event.year, event.month));

      debugPrint('✅ Budget created/updated successfully');
    } catch (error) {
      debugPrint('❌ Error creating budget: $error');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'خطأ في إنشاء الميزانية: $error',
        ),
      );
    }
  }

  /// Save budget (backward compatible with UI code)
  Future<void> _onSaveBudget(
    SaveBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint(
        '📤 Saving budget: ${event.category} - ${event.limit} for ${event.month}/${event.year}',
      );

      await _budgetService.createOrUpdateBudget(
        category: event.category,
        limit: event.limit,
        month: event.month,
        year: event.year,
      );

      // Reload budgets for the month
      add(LoadBudgetsForMonth(event.year, event.month));

      debugPrint('✅ Budget saved successfully');
    } catch (error) {
      debugPrint('❌ Error saving budget: $error');
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في حفظ الميزانية: $error'),
      );
    }
  }

  // /// Delete a budget
  // Future<void> _onDeleteBudget(
  //   DeleteBudget event,
  //   Emitter<BudgetState> emit,
  // ) async {
  //   emit(state.copyWith(isLoading: true, clearError: true));
  //
  //   try {
  //     debugPrint(
  //       '🗑️ Deleting budget: ${event.category} for ${event.month}/${event.year}',
  //     );
  //
  //     await _budgetService.deleteBudget(
  //       event.category,
  //       event.year,
  //       event.month,
  //     );
  //
  //     // Reload budgets for the month
  //     add(LoadBudgetsForMonth(event.year, event.month));
  //
  //     debugPrint('✅ Budget deleted successfully');
  //   } catch (error) {
  //     debugPrint('❌ Error deleting budget: $error');
  //     emit(
  //       state.copyWith(isLoading: false, error: 'خطأ في حذف الميزانية: $error'),
  //     );
  //   }
  // }

  /// Get budget for a specific category
  // Future<void> _onGetBudgetForCategory(
  //   GetBudgetForCategory event,
  //   Emitter<BudgetState> emit,
  // ) async {
  //   try {
  //     final budget = await _budgetService.getBudgetForCategory(
  //       event.category,
  //       event.year,
  //       event.month,
  //     );
  //
  //     emit(state.copyWith(selectedBudget: budget));
  //   } catch (error) {
  //     debugPrint('❌ Error getting budget for category: $error');
  //     emit(state.copyWith(error: 'خطأ في الحصول على الميزانية: $error'));
  //   }
  // }

  /// Update spent amount for a category
  /// Note: In API mode, spent is calculated server-side
  /// This event is kept for compatibility but may trigger a refresh
  Future<void> _onUpdateBudgetSpent(
    UpdateBudgetSpent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      // In API mode, we just refresh to get the latest spent amounts
      // The backend calculates spent based on actual expenses
      add(LoadBudgetsForMonth(event.year, event.month));
    } catch (error) {
      debugPrint('❌ Error updating budget spent: $error');
      emit(state.copyWith(error: 'خطأ في تحديث المبلغ المصروف: $error'));
    }
  }

  /// Refresh budgets (clear cache and reload)
  Future<void> _onRefreshBudgets(
    RefreshBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    _budgetService.clearCache();
    add(LoadBudgetsForMonth(event.year, event.month));
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Update budget spent from expenses (for UI calculations)
  // void updateBudgetSpentFromExpenses(
  //   Map<String, double> categorySpending,
  //   int year,
  //   int month,
  // ) {
  //   // In API mode, this triggers a refresh
  //   // The API returns updated spent amounts
  //   add(LoadBudgetsForMonth(year, month));
  // }

  /// Check if any budgets have alerts
  // bool hasAlerts() {
  //   final overBudgetCategories = state.overBudgetCategories;
  //   final nearLimitCategories = state.nearLimitCategories;
  //
  //   return overBudgetCategories.isNotEmpty || nearLimitCategories.isNotEmpty;
  // }

  /// Get budget health status
  // String getBudgetHealthStatus() {
  //   return state.budgetHealthStatus;
  // }

  /// Get budget health score
  // double getBudgetHealthScore() {
  //   return state.budgetHealthScore;
  // }
}
