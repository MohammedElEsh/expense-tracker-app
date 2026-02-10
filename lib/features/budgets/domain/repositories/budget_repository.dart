import 'package:expense_tracker/features/budgets/data/models/budget.dart';

// =============================================================================
// BUDGET REPOSITORY - Clean Architecture Domain Layer
// =============================================================================

/// Abstract repository interface for budget operations.
///
/// Defines the contract that any budget data source implementation
/// must fulfill. This allows the domain/presentation layers to remain
/// independent of the concrete data source (REST API, local DB, etc.).
abstract class BudgetRepository {
  // ===========================================================================
  // CRUD OPERATIONS
  // ===========================================================================

  /// Load budgets for a specific [month] and [year].
  ///
  /// Returns a list of [Budget] objects for the given time period.
  Future<List<Budget>> loadBudgets({required int month, required int year});

  /// Create or update a budget.
  ///
  /// The API uses an upsert approach: if a budget for the given [category],
  /// [month], and [year] already exists, it is updated; otherwise a new
  /// budget is created.
  ///
  /// Returns the created or updated [Budget].
  Future<Budget> createOrUpdateBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  });

  /// Delete a budget by setting its limit to 0.
  ///
  /// Since the API uses upsert semantics, deleting a budget is
  /// accomplished by setting its limit to 0, effectively removing it
  /// from active budgets.
  Future<void> deleteBudget({
    required String category,
    required int month,
    required int year,
  });

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached budget data to force a fresh reload.
  void clearCache();
}
