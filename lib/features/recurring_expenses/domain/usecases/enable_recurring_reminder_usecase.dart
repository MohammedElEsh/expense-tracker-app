import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class EnableRecurringReminderUseCase {
  final RecurringExpenseRepository _repository;

  EnableRecurringReminderUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.enableReminder(id);
  }
}
