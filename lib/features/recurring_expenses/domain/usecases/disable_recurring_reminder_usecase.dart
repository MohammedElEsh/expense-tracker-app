import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class DisableRecurringReminderUseCase {
  final RecurringExpenseRepository _repository;

  DisableRecurringReminderUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.disableReminder(id);
  }
}
