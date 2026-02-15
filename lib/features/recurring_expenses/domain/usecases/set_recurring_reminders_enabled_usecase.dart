import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class SetRecurringRemindersEnabledUseCase {
  final RecurringExpenseRepository _repository;

  SetRecurringRemindersEnabledUseCase(this._repository);

  Future<void> call(bool enabled) => _repository.setRemindersEnabled(enabled);
}
