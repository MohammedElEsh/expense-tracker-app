import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

// =============================================================================
// CREATE BUDGET USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Creates a new budget for a specific category and time period.
///
/// This use case validates the input and delegates creation
/// to the [BudgetRepository]. If a budget for the same category
/// and period already exists, it will be updated (upsert behavior).
class CreateBudgetUseCase {
  final BudgetRepository repository;

  CreateBudgetUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Creates a budget with the given [category], [limit], [month], and [year].
  /// Returns the newly created [Budget].
  ///
  /// Throws an [ArgumentError] if:
  /// - [category] is empty
  /// - [limit] is not positive
  /// - [month] is not between 1 and 12
  Future<Budget> call({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) {
    if (category.trim().isEmpty) {
      throw ArgumentError('Budget category cannot be empty');
    }
    if (limit <= 0) {
      throw ArgumentError('Budget limit must be greater than 0');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    return repository.createOrUpdateBudget(
      category: category,
      limit: limit,
      month: month,
      year: year,
    );
  }
}
