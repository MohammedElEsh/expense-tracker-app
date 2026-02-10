// =============================================================================
// BUDGET CUBIT - Clean Architecture Presentation Layer
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_service.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// Cubit for managing budget state
/// Uses API-based BudgetService for all operations
/// No Firebase dependencies
class BudgetCubit extends Cubit<BudgetState> {
  final BudgetService _budgetService;

  BudgetCubit({BudgetService? budgetService})
    : _budgetService = budgetService ?? serviceLocator.budgetService,
      super(const BudgetState());

  /// Load all budgets (current month by default)
  Future<void> loadBudgets() async {
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
  Future<void> loadBudgetsForMonth(int year, int month) async {
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
        month: month,
        year: year,
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
          selectedYear: year,
          selectedMonth: month,
          isLoading: false,
        ),
      );

      debugPrint('✅ Loaded ${activeBudgets.length} budgets for $month/$year');
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
  Future<void> createBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('📤 Creating budget: $category - $limit for $month/$year');

      await _budgetService.createOrUpdateBudget(
        category: category,
        limit: limit,
        month: month,
        year: year,
      );

      // Reload budgets for the month
      loadBudgetsForMonth(year, month);

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
  Future<void> saveBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('📤 Saving budget: $category - $limit for $month/$year');

      await _budgetService.createOrUpdateBudget(
        category: category,
        limit: limit,
        month: month,
        year: year,
      );

      // Reload budgets for the month
      loadBudgetsForMonth(year, month);

      debugPrint('✅ Budget saved successfully');
    } catch (error) {
      debugPrint('❌ Error saving budget: $error');
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في حفظ الميزانية: $error'),
      );
    }
  }

  /// Update spent amount for a category
  /// Note: In API mode, spent is calculated server-side
  /// This method is kept for compatibility but may trigger a refresh
  Future<void> updateBudgetSpent(
    String category,
    int year,
    int month,
    double spentAmount,
  ) async {
    try {
      // In API mode, we just refresh to get the latest spent amounts
      // The backend calculates spent based on actual expenses
      loadBudgetsForMonth(year, month);
    } catch (error) {
      debugPrint('❌ Error updating budget spent: $error');
      emit(state.copyWith(error: 'خطأ في تحديث المبلغ المصروف: $error'));
    }
  }

  /// Delete a budget (sets limit to 0 for soft delete)
  Future<void> deleteBudget(String category, int year, int month) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🗑️ Deleting budget: $category for $month/$year');

      // Soft delete by setting limit to 0
      await _budgetService.createOrUpdateBudget(
        category: category,
        limit: 0,
        month: month,
        year: year,
      );

      // Reload budgets for the month
      loadBudgetsForMonth(year, month);

      debugPrint('✅ Budget deleted successfully');
    } catch (error) {
      debugPrint('❌ Error deleting budget: $error');
      emit(
        state.copyWith(isLoading: false, error: 'خطأ في حذف الميزانية: $error'),
      );
    }
  }

  /// Refresh budgets (clear cache and reload)
  Future<void> refreshBudgets(int year, int month) async {
    _budgetService.clearCache();
    loadBudgetsForMonth(year, month);
  }
}
