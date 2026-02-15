import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_notification_service.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_reminder_preferences_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';

/// Wraps notification scheduling/canceling. No UI or Cubit should call notifications directly.
/// Reads "reminders enabled" from [RecurringReminderPreferencesDataSource] inside rescheduleAll.
class RecurringExpenseNotificationDataSource {
  final RecurringExpenseNotificationService _notificationService;
  final RecurringReminderPreferencesDataSource _reminderPrefs;

  RecurringExpenseNotificationDataSource({
    required RecurringExpenseNotificationService notificationService,
    required RecurringReminderPreferencesDataSource reminderPrefs,
  })  : _notificationService = notificationService,
        _reminderPrefs = reminderPrefs;

  Future<void> scheduleReminder(RecurringExpense model) async {
    await _notificationService.scheduleReminder(model);
  }

  Future<void> cancelReminder(String expenseId) async {
    await _notificationService.cancelReminder(expenseId);
  }

  /// Reschedules all reminders. Reads reminders-enabled from preferences;
  /// if disabled, effectively cancels all.
  Future<void> rescheduleAll(List<RecurringExpense> models) async {
    final enabled = await _reminderPrefs.getRemindersEnabled();
    await _notificationService.rescheduleAll(enabled ? models : []);
  }

  Future<void> showTestNotification() async {
    await _notificationService.showTestNotification();
  }
}
