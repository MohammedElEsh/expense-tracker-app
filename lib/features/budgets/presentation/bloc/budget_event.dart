// =============================================================================
// BUDGET BLOC EVENTS - Clean Architecture Presentation Layer
// =============================================================================

import 'package:equatable/equatable.dart';

/// Base class for all budget events
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Load all budgets (from cache or current month)
class LoadBudgets extends BudgetEvent {
  const LoadBudgets();
}

/// Load budgets for a specific month and year
class LoadBudgetsForMonth extends BudgetEvent {
  final int year;
  final int month;

  const LoadBudgetsForMonth(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}

/// Create a new budget or update existing one
/// POST /api/budgets handles both create and update
class CreateBudgetEvent extends BudgetEvent {
  final String category;
  final double limit;
  final int month;
  final int year;

  const CreateBudgetEvent({
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  @override
  List<Object> get props => [category, limit, month, year];
}

/// Save a budget (legacy event for backward compatibility)
/// Uses CreateBudgetEvent internally
class SaveBudget extends BudgetEvent {
  final String category;
  final double limit;
  final int month;
  final int year;

  const SaveBudget.fromParams({
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  // Constructor for backward compatibility with UI code that uses Budget object
  SaveBudget(dynamic budget)
    : category = budget.category as String,
      limit = budget.limit as double,
      month = budget.month as int,
      year = budget.year as int;

  @override
  List<Object> get props => [category, limit, month, year];
}

/// Delete a budget (sets limit to 0)
class DeleteBudget extends BudgetEvent {
  final String category;
  final int year;
  final int month;

  const DeleteBudget(this.category, this.year, this.month);

  @override
  List<Object> get props => [category, year, month];
}

/// Get budget for a specific category
class GetBudgetForCategory extends BudgetEvent {
  final String category;
  final int year;
  final int month;

  const GetBudgetForCategory(this.category, this.year, this.month);

  @override
  List<Object> get props => [category, year, month];
}

/// Update spent amount for a budget category
/// Note: Spent amount is calculated by the API based on expenses
class UpdateBudgetSpent extends BudgetEvent {
  final String category;
  final int year;
  final int month;
  final double spentAmount;

  const UpdateBudgetSpent(
    this.category,
    this.year,
    this.month,
    this.spentAmount,
  );

  @override
  List<Object> get props => [category, year, month, spentAmount];
}

/// Clear budget cache and refresh
class RefreshBudgets extends BudgetEvent {
  final int year;
  final int month;

  const RefreshBudgets(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}
