import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class UpdateRecurringExpenseUseCase {
  final RecurringExpenseRepository _repository;

  UpdateRecurringExpenseUseCase(this._repository);

  Future<RecurringExpenseEntity> call(RecurringExpenseEntity entity) {
    return _repository.updateRecurringExpense(entity);
  }
}
