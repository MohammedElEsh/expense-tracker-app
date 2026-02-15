import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class CreateRecurringExpenseUseCase {
  final RecurringExpenseRepository _repository;

  CreateRecurringExpenseUseCase(this._repository);

  Future<RecurringExpenseEntity> call(RecurringExpenseEntity entity) {
    return _repository.createRecurringExpense(entity);
  }
}
