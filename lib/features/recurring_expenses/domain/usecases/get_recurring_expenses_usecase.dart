import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class GetRecurringExpensesUseCase {
  final RecurringExpenseRepository _repository;

  GetRecurringExpensesUseCase(this._repository);

  Future<List<RecurringExpenseEntity>> call({bool forceRefresh = false}) {
    return _repository.getRecurringExpenses(forceRefresh: forceRefresh);
  }
}
