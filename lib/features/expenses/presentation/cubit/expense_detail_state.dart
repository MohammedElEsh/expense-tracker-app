import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseDetailState extends Equatable {
  final Expense? expense;
  final bool isRefreshing;
  final String? error;

  const ExpenseDetailState({
    this.expense,
    this.isRefreshing = false,
    this.error,
  });

  ExpenseDetailState copyWith({
    Expense? expense,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return ExpenseDetailState(
      expense: expense ?? this.expense,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [expense, isRefreshing, error];
}
