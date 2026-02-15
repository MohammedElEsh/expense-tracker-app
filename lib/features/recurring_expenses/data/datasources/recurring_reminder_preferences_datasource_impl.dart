import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_reminder_preferences_datasource.dart';

/// Implementation using PrefHelper (injected); keeps repository/datasource free of direct PrefHelper usage.
class RecurringReminderPreferencesDataSourceImpl
    implements RecurringReminderPreferencesDataSource {
  final PrefHelper _prefHelper;

  RecurringReminderPreferencesDataSourceImpl(this._prefHelper);

  @override
  Future<bool> getRemindersEnabled() =>
      _prefHelper.getRecurringExpenseRemindersEnabled();

  @override
  Future<void> setRemindersEnabled(bool enabled) =>
      _prefHelper.setRecurringExpenseRemindersEnabled(enabled);
}
