// Budget Calculations - حسابات الميزانية
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class BudgetCalculations {
  /// حساب إجمالي الميزانية
  static double calculateTotalBudget(List<Budget> budgets) {
    return budgets.fold(0.0, (sum, budget) => sum + budget.limit);
  }

  /// حساب إجمالي المصروفات للميزانيات المحددة
  static double calculateTotalSpent(
    List<Expense> allExpenses,
    List<Budget> budgets,
    DateTime selectedMonth,
  ) {
    return budgets.fold(0.0, (sum, budget) {
      return sum +
          calculateCategorySpent(allExpenses, budget.category, selectedMonth);
    });
  }

  /// حساب المصروفات لفئة معينة في شهر محدد
  static double calculateCategorySpent(
    List<Expense> allExpenses,
    String category,
    DateTime selectedMonth,
  ) {
    final monthExpenses = allExpenses.where((expense) {
      return expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month &&
          expense.category == category;
    });
    return monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// حساب المتبقي
  static double calculateRemaining(double totalBudget, double totalSpent) {
    return totalBudget - totalSpent;
  }

  /// حساب النسبة المئوية للمصروفات
  static double calculateSpentPercentage(double spent, double budget) {
    return budget > 0 ? (spent / budget) * 100 : 0.0;
  }
}
