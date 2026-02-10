import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

// =============================================================================
// ADD EXPENSE USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Creates a new expense entry.
///
/// This use case validates the input and delegates creation
/// to the [ExpenseRepository].
class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Creates a new expense with the given parameters and returns
  /// the created [Expense] with server-assigned fields.
  ///
  /// Throws an [ArgumentError] if:
  /// - [accountId] is empty
  /// - [amount] is not positive
  /// - [category] is empty
  Future<Expense> call({
    required String accountId,
    required double amount,
    required String category,
    String? customCategory,
    required DateTime date,
    String? vendorName,
    String? invoiceNumber,
    String? notes,
    String? projectId,
    String? employeeId,
  }) {
    if (accountId.trim().isEmpty) {
      throw ArgumentError('Account ID cannot be empty');
    }
    if (amount <= 0) {
      throw ArgumentError('Expense amount must be greater than 0');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('Expense category cannot be empty');
    }

    return repository.createExpense(
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
