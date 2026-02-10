import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

// =============================================================================
// DELETE EXPENSE USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Deletes an expense by its ID.
///
/// This use case validates the input and delegates deletion
/// to the [ExpenseRepository].
class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Deletes the expense identified by [expenseId].
  ///
  /// Throws an [ArgumentError] if [expenseId] is empty.
  Future<void> call(String expenseId) {
    if (expenseId.trim().isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }
    return repository.deleteExpense(expenseId);
  }
}
