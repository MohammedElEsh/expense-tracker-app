import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class ShowTestRecurringReminderUseCase {
  final RecurringExpenseRepository _repository;

  ShowTestRecurringReminderUseCase(this._repository);

  Future<void> call() => _repository.showTestReminderNotification();
}
