// Expense Filter - Cubit State
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseFilterState extends Equatable {
  final String searchQuery;
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final double? minAmount;
  final double? maxAmount;
  final bool isFilterVisible;

  // المصروفات المفلترة
  final List<Expense> filteredExpenses;

  // إحصائيات الفلترة
  final int totalCount;
  final double totalAmount;

  const ExpenseFilterState({
    this.searchQuery = '',
    this.selectedCategory,
    this.dateRange,
    this.minAmount,
    this.maxAmount,
    this.isFilterVisible = false,
    this.filteredExpenses = const [],
    this.totalCount = 0,
    this.totalAmount = 0.0,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    selectedCategory,
    dateRange,
    minAmount,
    maxAmount,
    isFilterVisible,
    filteredExpenses,
    totalCount,
    totalAmount,
  ];

  ExpenseFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    DateTimeRange? dateRange,
    double? minAmount,
    double? maxAmount,
    bool? isFilterVisible,
    List<Expense>? filteredExpenses,
    int? totalCount,
    double? totalAmount,
    bool clearCategory = false,
    bool clearDateRange = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return ExpenseFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      isFilterVisible: isFilterVisible ?? this.isFilterVisible,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      totalCount: totalCount ?? this.totalCount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  // التحقق من وجود فلاتر نشطة
  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        selectedCategory != null ||
        dateRange != null ||
        minAmount != null ||
        maxAmount != null;
  }

  // عدد الفلاتر النشطة
  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (selectedCategory != null) count++;
    if (dateRange != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }
}
