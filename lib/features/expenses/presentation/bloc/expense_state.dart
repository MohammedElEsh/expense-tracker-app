// ✅ Clean Architecture - BLoC State
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseState extends Equatable {
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final bool isInitialLoading; // Only for first load
  final bool isRefreshing; // Pull-to-refresh
  final bool isMutating; // Create/update/delete operations
  final bool hasLoaded;
  final String? error;
  final String? searchQuery;
  final String? selectedCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? selectedDate;

  const ExpenseState({
    this.allExpenses = const [],
    this.filteredExpenses = const [],
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isMutating = false,
    this.hasLoaded = false,
    this.error,
    this.searchQuery,
    this.selectedCategory,
    this.filterStartDate,
    this.filterEndDate,
    this.minAmount,
    this.maxAmount,
    this.selectedDate,
  });

  @override
  List<Object?> get props => [
    allExpenses,
    filteredExpenses,
    isInitialLoading,
    isRefreshing,
    isMutating,
    hasLoaded,
    error,
    searchQuery,
    selectedCategory,
    filterStartDate,
    filterEndDate,
    minAmount,
    maxAmount,
    selectedDate,
  ];

  ExpenseState copyWith({
    List<Expense>? allExpenses,
    List<Expense>? filteredExpenses,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isMutating,
    bool? hasLoaded,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    double? minAmount,
    double? maxAmount,
    DateTime? selectedDate,
    bool clearError = false,
    bool clearSearchQuery = false,
    bool clearSelectedCategory = false,
    bool clearFilterDates = false,
    bool clearAmountRange = false,
    bool clearSelectedDate = false,
  }) {
    return ExpenseState(
      allExpenses: allExpenses ?? this.allExpenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isMutating: isMutating ?? this.isMutating,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedCategory:
          clearSelectedCategory
              ? null
              : (selectedCategory ?? this.selectedCategory),
      filterStartDate:
          clearFilterDates ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilterDates ? null : (filterEndDate ?? this.filterEndDate),
      minAmount: clearAmountRange ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmountRange ? null : (maxAmount ?? this.maxAmount),
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
    );
  }

  // Helper getters
  List<Expense> get expenses => filteredExpenses;
  
  // Computed property for backwards compatibility and UI checks
  bool get isLoading => isInitialLoading || isRefreshing;

  List<Expense> getExpensesForDate(DateTime date) {
    final filtered =
        allExpenses.where((expense) {
          return expense.date.year == date.year &&
              expense.date.month == date.month &&
              expense.date.day == date.day;
        }).toList();
    debugPrint(
      '📅 getExpensesForDate - التاريخ: $date, المصروفات: ${filtered.length}',
    );
    return filtered;
  }

  List<Expense> getExpensesForMonth(int year, int month) {
    final filtered =
        allExpenses.where((expense) {
          return expense.date.year == year && expense.date.month == month;
        }).toList();
    debugPrint(
      '📅 getExpensesForMonth - السنة: $year, الشهر: $month, المصروفات: ${filtered.length}',
    );
    return filtered;
  }

  double get totalAmount {
    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // إجمالي جميع المصروفات (بدون فلترة)
  double get totalExpenses {
    return allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getTotalForDate(DateTime date) {
    return getExpensesForDate(
      date,
    ).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getTotalForMonth(int year, int month) {
    return getExpensesForMonth(
      year,
      month,
    ).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryTotals() {
    final Map<String, double> categoryTotals = {};
    for (final expense in filteredExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  Map<String, double> getCategoryTotalsForMonth(int year, int month) {
    final Map<String, double> categoryTotals = {};
    final monthExpenses = getExpensesForMonth(year, month);
    for (final expense in monthExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  bool get hasActiveFilters {
    return searchQuery != null ||
        selectedCategory != null ||
        filterStartDate != null ||
        filterEndDate != null ||
        minAmount != null ||
        maxAmount != null ||
        selectedDate != null;
  }
}
