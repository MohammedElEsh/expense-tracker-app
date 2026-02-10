import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

// =============================================================================
// GET EXPENSES USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Retrieves expenses with optional filtering and pagination.
///
/// This use case encapsulates the logic for fetching expenses,
/// delegating to the [ExpenseRepository] for data access.
class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Loads expenses with optional filters for date range, [category],
  /// [accountId], [projectId], and pagination via [page] and [limit].
  Future<List<Expense>> call({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? accountId,
    String? projectId,
    int? page,
    int? limit,
  }) {
    return repository.getExpenses(
      startDate: startDate,
      endDate: endDate,
      category: category,
      accountId: accountId,
      projectId: projectId,
      page: page,
      limit: limit,
    );
  }
}
