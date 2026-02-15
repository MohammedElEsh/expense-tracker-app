import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class GetRecurringRemindersEnabledUseCase {
  final RecurringExpenseRepository _repository;

  GetRecurringRemindersEnabledUseCase(this._repository);

  Future<bool> call() => _repository.getRemindersEnabled();
}
