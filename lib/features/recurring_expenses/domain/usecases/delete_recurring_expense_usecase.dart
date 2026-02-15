import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class DeleteRecurringExpenseUseCase {
  final RecurringExpenseRepository _repository;

  DeleteRecurringExpenseUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteRecurringExpense(id);
  }
}
