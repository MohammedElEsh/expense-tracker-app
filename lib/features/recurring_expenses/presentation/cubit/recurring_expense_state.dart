// ✅ Clean Architecture - Cubit State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';

class RecurringExpenseState extends Equatable {
  final List<RecurringExpense> allRecurringExpenses;
  final List<RecurringExpense> filteredRecurringExpenses;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;
  final String? selectedCategory;
  final bool? selectedStatus;
  final RecurrenceType? selectedFrequency;
  final double monthlyTotal;

  const RecurringExpenseState({
    this.allRecurringExpenses = const [],
    this.filteredRecurringExpenses = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedFrequency,
    this.monthlyTotal = 0.0,
  });

  @override
  List<Object?> get props => [
    allRecurringExpenses,
    filteredRecurringExpenses,
    isLoading,
    hasLoaded,
    error,
    selectedCategory,
    selectedStatus,
    selectedFrequency,
    monthlyTotal,
  ];

  RecurringExpenseState copyWith({
    List<RecurringExpense>? allRecurringExpenses,
    List<RecurringExpense>? filteredRecurringExpenses,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    String? selectedCategory,
    bool? selectedStatus,
    RecurrenceType? selectedFrequency,
    double? monthlyTotal,
    bool clearError = false,
    bool clearSelectedCategory = false,
    bool clearSelectedStatus = false,
    bool clearSelectedFrequency = false,
  }) {
    return RecurringExpenseState(
      allRecurringExpenses: allRecurringExpenses ?? this.allRecurringExpenses,
      filteredRecurringExpenses:
          filteredRecurringExpenses ?? this.filteredRecurringExpenses,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      selectedCategory:
          clearSelectedCategory
              ? null
              : (selectedCategory ?? this.selectedCategory),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedFrequency:
          clearSelectedFrequency
              ? null
              : (selectedFrequency ?? this.selectedFrequency),
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
    );
  }

  // ============================================================================
  // HELPER GETTERS
  // ============================================================================

  /// Get filtered expenses (uses filter results)
  List<RecurringExpense> get recurringExpenses => filteredRecurringExpenses;

  /// Get all active recurring expenses
  List<RecurringExpense> get activeRecurringExpenses =>
      allRecurringExpenses.where((expense) => expense.isActive).toList();

  /// Get all inactive recurring expenses
  List<RecurringExpense> get inactiveRecurringExpenses =>
      allRecurringExpenses.where((expense) => !expense.isActive).toList();

  /// Get count of active recurring expenses
  int get totalActiveRecurringExpenses => activeRecurringExpenses.length;

  /// Get count of inactive recurring expenses
  int get totalInactiveRecurringExpenses => inactiveRecurringExpenses.length;

  /// Calculate yearly recurring amount
  double get totalYearlyRecurringAmount {
    double total = 0.0;
    for (final expense in activeRecurringExpenses) {
      switch (expense.recurrenceType) {
        case RecurrenceType.daily:
          total += expense.amount * 365;
          break;
        case RecurrenceType.weekly:
          total += expense.amount * 52;
          break;
        case RecurrenceType.monthly:
          total += expense.amount * 12;
          break;
        case RecurrenceType.yearly:
          total += expense.amount;
          break;
      }
    }
    return total;
  }

  /// Get category breakdown for active expenses
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};
    for (final expense in activeRecurringExpenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  /// Get frequency breakdown for active expenses
  Map<RecurrenceType, int> get frequencyBreakdown {
    final Map<RecurrenceType, int> breakdown = {};
    for (final expense in activeRecurringExpenses) {
      breakdown[expense.recurrenceType] =
          (breakdown[expense.recurrenceType] ?? 0) + 1;
    }
    return breakdown;
  }

  /// Get expenses by category
  List<RecurringExpense> getRecurringExpensesByCategory(String category) {
    return allRecurringExpenses
        .where((expense) => expense.category == category)
        .toList();
  }

  /// Get expenses by frequency
  List<RecurringExpense> getRecurringExpensesByFrequency(
    RecurrenceType frequency,
  ) {
    return allRecurringExpenses
        .where((expense) => expense.recurrenceType == frequency)
        .toList();
  }

  /// Get a single expense by ID
  RecurringExpense? getRecurringExpenseById(String id) {
    try {
      return allRecurringExpenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return selectedCategory != null ||
        selectedStatus != null ||
        selectedFrequency != null;
  }

  /// Get average recurring expense amount
  double get averageRecurringExpenseAmount {
    if (activeRecurringExpenses.isEmpty) return 0.0;
    final total = activeRecurringExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    return total / activeRecurringExpenses.length;
  }

  /// Get largest recurring expense
  RecurringExpense? get largestRecurringExpense {
    if (activeRecurringExpenses.isEmpty) return null;
    return activeRecurringExpenses.reduce(
      (a, b) => a.amount > b.amount ? a : b,
    );
  }

  /// Get smallest recurring expense
  RecurringExpense? get smallestRecurringExpense {
    if (activeRecurringExpenses.isEmpty) return null;
    return activeRecurringExpenses.reduce(
      (a, b) => a.amount < b.amount ? a : b,
    );
  }
}
