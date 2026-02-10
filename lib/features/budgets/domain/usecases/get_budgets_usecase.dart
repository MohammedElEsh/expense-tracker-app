import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

// =============================================================================
// GET BUDGETS USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Retrieves the list of budgets for a specific month and year.
///
/// This use case encapsulates the logic for fetching budgets,
/// delegating to the [BudgetRepository] for data access.
class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Loads budgets for the given [month] and [year].
  /// If [excludeZeroLimit] is `true`, budgets with a limit of 0
  /// (effectively deleted) are filtered out.
  Future<List<Budget>> call({
    required int month,
    required int year,
    bool excludeZeroLimit = true,
  }) async {
    final budgets = await repository.loadBudgets(month: month, year: year);

    if (excludeZeroLimit) {
      return budgets.where((budget) => budget.limit > 0).toList();
    }
    return budgets;
  }
}
