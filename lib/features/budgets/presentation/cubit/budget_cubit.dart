import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/clear_budget_cache_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit({
    required GetBudgetsUseCase getBudgetsUseCase,
    required CreateBudgetUseCase createBudgetUseCase,
    required UpdateBudgetUseCase updateBudgetUseCase,
    required DeleteBudgetUseCase deleteBudgetUseCase,
    required ClearBudgetCacheUseCase clearBudgetCacheUseCase,
  })  : _getBudgets = getBudgetsUseCase,
        _createBudget = createBudgetUseCase,
        _updateBudget = updateBudgetUseCase,
        _deleteBudget = deleteBudgetUseCase,
        _clearCache = clearBudgetCacheUseCase,
        super(const BudgetState());

  final GetBudgetsUseCase _getBudgets;
  final CreateBudgetUseCase _createBudget;
  final UpdateBudgetUseCase _updateBudget;
  final DeleteBudgetUseCase _deleteBudget;
  final ClearBudgetCacheUseCase _clearCache;

  Future<void> loadBudgets() async {
    emit(state.copyWith(
      allBudgets: const [],
      monthlyBudgets: const {},
      isLoading: true,
      clearError: true,
    ));

    try {
      final now = DateTime.now();
      final budgets = await _getBudgets(
        month: state.selectedMonth ?? now.month,
        year: state.selectedYear ?? now.year,
      );

      final Map<String, Budget> monthlyBudgets = {};
      for (final budget in budgets) {
        monthlyBudgets[budget.category] = budget;
      }

      emit(state.copyWith(
        allBudgets: budgets,
        monthlyBudgets: monthlyBudgets,
        isLoading: false,
      ));
    } catch (error) {
      debugPrint('❌ Error loading budgets: $error');
      emit(state.copyWith(
        allBudgets: const [],
        monthlyBudgets: const {},
        isLoading: false,
        error: 'خطأ في تحميل الميزانيات: $error',
      ));
    }
  }

  Future<void> loadBudgetsForMonth(int year, int month) async {
    emit(state.copyWith(
      allBudgets: const [],
      monthlyBudgets: const {},
      isLoading: true,
      clearError: true,
    ));

    try {
      final budgets = await _getBudgets(month: month, year: year);

      final Map<String, Budget> monthlyBudgets = {};
      for (final budget in budgets) {
        monthlyBudgets[budget.category] = budget;
      }

      emit(state.copyWith(
        allBudgets: budgets,
        monthlyBudgets: monthlyBudgets,
        selectedYear: year,
        selectedMonth: month,
        isLoading: false,
      ));
    } catch (error) {
      debugPrint('❌ Error loading monthly budgets: $error');
      emit(state.copyWith(
        isLoading: false,
        error: 'خطأ في تحميل ميزانيات الشهر: $error',
      ));
    }
  }

  Future<void> createBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _createBudget(
        category: category,
        limit: limit,
        month: month,
        year: year,
      );
      loadBudgetsForMonth(year, month);
    } catch (error) {
      debugPrint('❌ Error creating budget: $error');
      emit(state.copyWith(
        isLoading: false,
        error: 'خطأ في إنشاء الميزانية: $error',
      ));
    }
  }

  Future<void> saveBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _updateBudget(
        category: category,
        limit: limit,
        month: month,
        year: year,
      );
      loadBudgetsForMonth(year, month);
    } catch (error) {
      debugPrint('❌ Error saving budget: $error');
      emit(state.copyWith(
        isLoading: false,
        error: 'خطأ في حفظ الميزانية: $error',
      ));
    }
  }

  Future<void> updateBudgetSpent(
    String category,
    int year,
    int month,
    double spentAmount,
  ) async {
    try {
      loadBudgetsForMonth(year, month);
    } catch (error) {
      debugPrint('❌ Error updating budget spent: $error');
      emit(state.copyWith(error: 'خطأ في تحديث المبلغ المصروف: $error'));
    }
  }

  Future<void> deleteBudget(String category, int year, int month) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _deleteBudget(category: category, month: month, year: year);
      loadBudgetsForMonth(year, month);
    } catch (error) {
      debugPrint('❌ Error deleting budget: $error');
      emit(state.copyWith(
        isLoading: false,
        error: 'خطأ في حذف الميزانية: $error',
      ));
    }
  }

  Future<void> refreshBudgets(int year, int month) async {
    _clearCache();
    loadBudgetsForMonth(year, month);
  }
}
