import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class RescheduleAllRecurringRemindersUseCase {
  final RecurringExpenseRepository _repository;

  RescheduleAllRecurringRemindersUseCase(this._repository);

  Future<void> call() => _repository.rescheduleAllReminders();
}
