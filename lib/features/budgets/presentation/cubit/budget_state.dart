// ✅ Clean Architecture - Cubit State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';

class BudgetState extends Equatable {
  final List<Budget> allBudgets;
  final Map<String, Budget> monthlyBudgets;
  final Budget? selectedBudget;
  final bool isLoading;
  final String? error;
  final int? selectedYear;
  final int? selectedMonth;

  const BudgetState({
    this.allBudgets = const [],
    this.monthlyBudgets = const {},
    this.selectedBudget,
    this.isLoading = false,
    this.error,
    this.selectedYear,
    this.selectedMonth,
  });

  @override
  List<Object?> get props => [
    allBudgets,
    monthlyBudgets,
    selectedBudget,
    isLoading,
    error,
    selectedYear,
    selectedMonth,
  ];

  BudgetState copyWith({
    List<Budget>? allBudgets,
    Map<String, Budget>? monthlyBudgets,
    Budget? selectedBudget,
    bool? isLoading,
    String? error,
    int? selectedYear,
    int? selectedMonth,
    bool clearError = false,
    bool clearSelectedBudget = false,
    bool clearSelectedMonth = false,
  }) {
    return BudgetState(
      allBudgets: allBudgets ?? this.allBudgets,
      monthlyBudgets: monthlyBudgets ?? this.monthlyBudgets,
      selectedBudget:
          clearSelectedBudget ? null : (selectedBudget ?? this.selectedBudget),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedYear:
          clearSelectedMonth ? null : (selectedYear ?? this.selectedYear),
      selectedMonth:
          clearSelectedMonth ? null : (selectedMonth ?? this.selectedMonth),
    );
  }

  // Helper getters
  List<Budget> getBudgetsForMonth(int year, int month) {
    return allBudgets
        .where((budget) => budget.year == year && budget.month == month)
        .toList();
  }

  Budget? getBudgetForCategory(String category, int year, int month) {
    try {
      return allBudgets.firstWhere(
        (budget) =>
            budget.category == category &&
            budget.year == year &&
            budget.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  List<Budget> get currentMonthBudgets {
    if (selectedYear == null || selectedMonth == null) {
      final now = DateTime.now();
      return getBudgetsForMonth(now.year, now.month);
    }
    return getBudgetsForMonth(selectedYear!, selectedMonth!);
  }

  double get totalBudgetAmount {
    return currentMonthBudgets.fold(0.0, (sum, budget) => sum + budget.limit);
  }

  double get totalSpentAmount {
    return currentMonthBudgets.fold(0.0, (sum, budget) => sum + budget.spent);
  }

  double get totalRemainingAmount {
    return totalBudgetAmount - totalSpentAmount;
  }

  double get budgetUsagePercentage {
    if (totalBudgetAmount <= 0) return 0.0;
    return (totalSpentAmount / totalBudgetAmount) * 100;
  }

  List<Budget> get overBudgetCategories {
    return currentMonthBudgets.where((budget) => budget.isOverBudget).toList();
  }

  List<Budget> get nearLimitCategories {
    return currentMonthBudgets
        .where((budget) => budget.usagePercentage >= 80 && !budget.isOverBudget)
        .toList();
  }

  bool get hasOverBudgetCategories => overBudgetCategories.isNotEmpty;

  bool get hasNearLimitCategories => nearLimitCategories.isNotEmpty;

  int get categoriesWithBudgets => currentMonthBudgets.length;

  List<String> get categoriesWithoutBudgets {
    // This would need to be populated from expense categories
    // For now, return empty list - will be updated when integrated with expenses
    return [];
  }

  Map<String, double> get budgetBreakdown {
    final Map<String, double> breakdown = {};
    for (final budget in currentMonthBudgets) {
      breakdown[budget.category] = budget.usagePercentage;
    }
    return breakdown;
  }

  List<Budget> get topSpendingCategories {
    final sortedBudgets = List<Budget>.from(currentMonthBudgets);
    sortedBudgets.sort((a, b) => b.spent.compareTo(a.spent));
    return sortedBudgets.take(5).toList();
  }

  // Budget health score (0-100)
  double get budgetHealthScore {
    if (currentMonthBudgets.isEmpty) return 100.0;

    double totalScore = 0.0;
    for (final budget in currentMonthBudgets) {
      if (budget.isOverBudget) {
        totalScore += 0; // 0 points for over budget
      } else if (budget.usagePercentage >= 90) {
        totalScore += 20; // 20 points for very close to limit
      } else if (budget.usagePercentage >= 80) {
        totalScore += 50; // 50 points for close to limit
      } else if (budget.usagePercentage >= 60) {
        totalScore += 80; // 80 points for moderate usage
      } else {
        totalScore += 100; // 100 points for low usage
      }
    }

    return totalScore / currentMonthBudgets.length;
  }

  String get budgetHealthStatus {
    final score = budgetHealthScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }

  // Year/Month navigation helpers
  bool get canNavigateToPreviousMonth {
    if (selectedYear == null || selectedMonth == null) return true;
    // Allow navigation back to reasonable limits (e.g., 2 years)
    final now = DateTime.now();
    final selected = DateTime(selectedYear!, selectedMonth!);
    final twoYearsAgo = DateTime(now.year - 2, now.month);
    return selected.isAfter(twoYearsAgo);
  }

  bool get canNavigateToNextMonth {
    if (selectedYear == null || selectedMonth == null) return true;
    // Allow navigation up to 1 year in the future
    final now = DateTime.now();
    final selected = DateTime(selectedYear!, selectedMonth!);
    final oneYearLater = DateTime(now.year + 1, now.month);
    return selected.isBefore(oneYearLater);
  }
}
