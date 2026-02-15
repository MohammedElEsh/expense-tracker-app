import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';

class ClearBudgetCacheUseCase {
  final BudgetRepository repository;

  ClearBudgetCacheUseCase(this.repository);

  void call() => repository.clearCache();
}
