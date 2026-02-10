import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

// =============================================================================
// UPDATE BUDGET USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Updates an existing budget's limit for a specific category and time period.
///
/// This use case validates the input and delegates the update
/// to the [BudgetRepository]. Uses the API's upsert behavior internally.
class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Updates the budget for [category] in the given [month]/[year]
  /// with a new [limit]. Returns the updated [Budget].
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
