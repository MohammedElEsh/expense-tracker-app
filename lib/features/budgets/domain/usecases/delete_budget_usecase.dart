import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

// =============================================================================
// DELETE BUDGET USE CASE - Clean Architecture Domain Layer
// =============================================================================

/// Deletes a budget for a specific category and time period.
///
/// This use case validates the input and delegates deletion
/// to the [BudgetRepository]. Under the hood, deletion is achieved
/// by setting the budget limit to 0 (API upsert semantics).
class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Deletes the budget for [category] in the given [month]/[year].
  ///
  /// Throws an [ArgumentError] if:
  /// - [category] is empty
  /// - [month] is not between 1 and 12
  Future<void> call({
    required String category,
    required int month,
    required int year,
  }) {
    if (category.trim().isEmpty) {
      throw ArgumentError('Budget category cannot be empty');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    return repository.deleteBudget(
      category: category,
      month: month,
      year: year,
    );
  }
}
