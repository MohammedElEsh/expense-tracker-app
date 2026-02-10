// ✅ Clean Architecture - BLoC Events
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';

abstract class RecurringExpenseEvent extends Equatable {
  const RecurringExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Load all recurring expenses from API
class LoadRecurringExpenses extends RecurringExpenseEvent {
  const LoadRecurringExpenses();
}

/// Force refresh recurring expenses (clear cache and reload)
class RefreshRecurringExpenses extends RecurringExpenseEvent {
  const RefreshRecurringExpenses();
}

/// Add a new recurring expense
class AddRecurringExpense extends RecurringExpenseEvent {
  final RecurringExpense expense;

  const AddRecurringExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

/// Update an existing recurring expense
class UpdateRecurringExpense extends RecurringExpenseEvent {
  final RecurringExpense expense;

  const UpdateRecurringExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

/// Delete a recurring expense
class DeleteRecurringExpense extends RecurringExpenseEvent {
  final String expenseId;

  const DeleteRecurringExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

/// Toggle recurring expense active/inactive status
class ToggleRecurringExpense extends RecurringExpenseEvent {
  final String expenseId;
  final bool isActive;

  const ToggleRecurringExpense(this.expenseId, this.isActive);

  @override
  List<Object> get props => [expenseId, isActive];
}

/// Filter recurring expenses by category
class FilterRecurringExpensesByCategory extends RecurringExpenseEvent {
  final String? category;

  const FilterRecurringExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter recurring expenses by active/inactive status
class FilterRecurringExpensesByStatus extends RecurringExpenseEvent {
  final bool? isActive;

  const FilterRecurringExpensesByStatus(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

/// Filter recurring expenses by recurrence frequency
class FilterRecurringExpensesByFrequency extends RecurringExpenseEvent {
  final RecurrenceType? frequency;

  const FilterRecurringExpensesByFrequency(this.frequency);

  @override
  List<Object?> get props => [frequency];
}

/// Clear all filters
class ClearRecurringExpenseFilters extends RecurringExpenseEvent {
  const ClearRecurringExpenseFilters();
}
