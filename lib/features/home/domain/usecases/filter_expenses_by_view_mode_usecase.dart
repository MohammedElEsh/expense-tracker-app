// Home Feature - Domain Layer - Use Case
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class FilterExpensesByViewModeUseCase {
  List<Expense> call({
    required List<Expense> allExpenses,
    required String viewMode,
    required DateTime selectedDate,
    String? accountId, // Optional: filter by selected account
  }) {
    // First, filter by account if provided
    List<Expense> filteredExpenses = allExpenses;
    if (accountId != null && accountId.isNotEmpty) {
      filteredExpenses =
          filteredExpenses
              .where((expense) => expense.accountId == accountId)
              .toList();
    }

    // Then, filter by view mode
    switch (viewMode) {
      case 'day':
        return _getExpensesForDate(filteredExpenses, selectedDate);
      case 'week':
        return _getExpensesForWeek(filteredExpenses, selectedDate);
      case 'month':
        return _getExpensesForMonth(filteredExpenses, selectedDate);
      case 'all':
        return filteredExpenses;
      default:
        return filteredExpenses;
    }
  }

  List<Expense> _getExpensesForDate(List<Expense> expenses, DateTime date) {
    return expenses.where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  List<Expense> _getExpensesForWeek(List<Expense> expenses, DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return expenses.where((expense) {
      return expense.date.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<Expense> _getExpensesForMonth(List<Expense> expenses, DateTime date) {
    return expenses.where((expense) {
      return expense.date.year == date.year && expense.date.month == date.month;
    }).toList();
  }
}
