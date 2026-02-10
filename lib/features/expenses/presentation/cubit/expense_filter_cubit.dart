// Expense Filter - Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'expense_filter_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseFilterCubit extends Cubit<ExpenseFilterState> {
  final List<Expense> allExpenses;

  ExpenseFilterCubit({required this.allExpenses})
    : super(
        ExpenseFilterState(
          filteredExpenses: allExpenses,
          totalCount: allExpenses.length,
          totalAmount: allExpenses.fold(0.0, (sum, e) => sum + e.amount),
        ),
      );

  void changeSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void changeCategoryFilter(String? category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        clearCategory: category == null,
      ),
    );
    _applyFilters();
  }

  void changeDateRangeFilter(DateTimeRange? dateRange) {
    emit(
      state.copyWith(dateRange: dateRange, clearDateRange: dateRange == null),
    );
    _applyFilters();
  }

  void changeAmountRangeFilter({double? minAmount, double? maxAmount}) {
    emit(
      state.copyWith(
        minAmount: minAmount,
        maxAmount: maxAmount,
        clearMinAmount: minAmount == null,
        clearMaxAmount: maxAmount == null,
      ),
    );
    _applyFilters();
  }

  void toggleFilterVisibility() {
    final newVisibility = !state.isFilterVisible;
    debugPrint('🔍 تبديل رؤية الفلاتر: $newVisibility');
    emit(state.copyWith(isFilterVisible: newVisibility));
  }

  void resetFilters() {
    debugPrint('🔄 إعادة تعيين جميع الفلاتر');
    emit(
      ExpenseFilterState(
        filteredExpenses: allExpenses,
        totalCount: allExpenses.length,
        totalAmount: allExpenses.fold(0.0, (sum, e) => sum + e.amount),
        isFilterVisible: state.isFilterVisible,
      ),
    );
  }

  void applyFilters() {
    _applyFilters();
  }

  // منطق تطبيق الفلاتر
  void _applyFilters() {
    var filtered = List<Expense>.from(allExpenses);

    // فلترة حسب البحث
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered =
          filtered.where((expense) {
            return expense.notes.toLowerCase().contains(query) ||
                expense.category.toLowerCase().contains(query) ||
                expense.amount.toString().contains(query);
          }).toList();
    }

    // فلترة حسب الفئة
    if (state.selectedCategory != null) {
      filtered =
          filtered
              .where((expense) => expense.category == state.selectedCategory)
              .toList();
    }

    // فلترة حسب التاريخ
    if (state.dateRange != null) {
      filtered =
          filtered.where((expense) {
            return expense.date.isAfter(
                  state.dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(
                  state.dateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
    }

    // فلترة حسب المبلغ
    if (state.minAmount != null) {
      filtered =
          filtered
              .where((expense) => expense.amount >= state.minAmount!)
              .toList();
    }
    if (state.maxAmount != null) {
      filtered =
          filtered
              .where((expense) => expense.amount <= state.maxAmount!)
              .toList();
    }

    // حساب الإحصائيات
    final totalAmount = filtered.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    debugPrint(
      '🔍 تطبيق الفلاتر: ${filtered.length} من ${allExpenses.length} مصروف',
    );

    emit(
      state.copyWith(
        filteredExpenses: filtered,
        totalCount: filtered.length,
        totalAmount: totalAmount,
      ),
    );
  }
}
