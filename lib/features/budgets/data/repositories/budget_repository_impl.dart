import 'package:expense_tracker/features/budgets/data/datasources/budget_service.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({required BudgetService budgetService})
      : _service = budgetService;

  final BudgetService _service;

  @override
  Future<List<Budget>> loadBudgets({required int month, required int year}) =>
      _service.loadBudgets(month: month, year: year);

  @override
  Future<Budget> createOrUpdateBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) =>
      _service.createOrUpdateBudget(
        category: category,
        limit: limit,
        month: month,
        year: year,
      );

  @override
  Future<void> deleteBudget({
    required String category,
    required int month,
    required int year,
  }) async {
    await _service.createOrUpdateBudget(
      category: category,
      limit: 0,
      month: month,
      year: year,
    );
  }

  @override
  void clearCache() => _service.clearCache();
}
