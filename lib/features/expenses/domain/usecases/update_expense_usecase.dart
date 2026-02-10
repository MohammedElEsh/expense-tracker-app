import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

// =============================================================================
// UPDATE EXPENSE USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Updates an existing expense.
///
/// This use case validates the input and delegates the update
/// to the [ExpenseRepository]. Only provided (non-null) fields are updated.
class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Updates the expense identified by [expenseId] with the provided fields.
  /// Returns the updated [Expense].
  ///
  /// Throws an [ArgumentError] if [expenseId] is empty.
  Future<Expense> call(
    String expenseId, {
    String? accountId,
    double? amount,
    String? category,
    String? customCategory,
    DateTime? date,
    String? vendorName,
    String? invoiceNumber,
    String? notes,
    String? projectId,
    String? employeeId,
  }) {
    if (expenseId.trim().isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }
    if (amount != null && amount <= 0) {
      throw ArgumentError('Expense amount must be greater than 0');
    }

    return repository.updateExpense(
      expenseId,
      accountId: accountId,
      amount: amount,
      category: category,
      customCategory: customCategory,
      date: date,
      vendorName: vendorName,
      invoiceNumber: invoiceNumber,
      notes: notes,
      projectId: projectId,
      employeeId: employeeId,
    );
  }
}
