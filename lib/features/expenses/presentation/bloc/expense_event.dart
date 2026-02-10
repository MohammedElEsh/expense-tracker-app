import 'package:equatable/equatable.dart';
// ✅ Clean Architecture - BLoC Events
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final bool forceRefresh;
  
  const LoadExpenses({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class EditExpense extends ExpenseEvent {
  final Expense expense;

  const EditExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class DeleteAllExpenses extends ExpenseEvent {
  const DeleteAllExpenses();
}

class FilterExpensesByDate extends ExpenseEvent {
  final DateTime date;

  const FilterExpensesByDate(this.date);

  @override
  List<Object> get props => [date];
}

class FilterExpensesByMonth extends ExpenseEvent {
  final int year;
  final int month;

  const FilterExpensesByMonth(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}

class SearchExpenses extends ExpenseEvent {
  final String searchQuery;

  const SearchExpenses(this.searchQuery);

  @override
  List<Object> get props => [searchQuery];
}

class FilterExpensesByCategory extends ExpenseEvent {
  final String? category;

  const FilterExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class FilterExpensesByDateRange extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterExpensesByDateRange(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterExpensesByAmountRange extends ExpenseEvent {
  final double? minAmount;
  final double? maxAmount;

  const FilterExpensesByAmountRange(this.minAmount, this.maxAmount);

  @override
  List<Object?> get props => [minAmount, maxAmount];
}

class ClearExpenseFilters extends ExpenseEvent {
  const ClearExpenseFilters();
}

class ReloadExpensesForCurrentMode extends ExpenseEvent {
  const ReloadExpensesForCurrentMode();
}

class RefreshExpenses extends ExpenseEvent {
  const RefreshExpenses();
}
