import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';

abstract class RecurringExpenseRepository {
  Future<List<RecurringExpenseEntity>> getRecurringExpenses({
    bool forceRefresh = false,
  });

  Future<RecurringExpenseEntity> createRecurringExpense(
    RecurringExpenseEntity entity,
  );

  Future<RecurringExpenseEntity> updateRecurringExpense(
    RecurringExpenseEntity entity,
  );

  Future<void> deleteRecurringExpense(String id);

  Future<void> enableReminder(String id);

  Future<void> disableReminder(String id);

  Future<bool> getRemindersEnabled();

  Future<void> setRemindersEnabled(bool enabled);

  /// Re-fetches recurring expenses and reschedules all reminders (respects reminders-enabled).
  Future<void> rescheduleAllReminders();

  Future<void> showTestReminderNotification();

  void clearCache();
}
