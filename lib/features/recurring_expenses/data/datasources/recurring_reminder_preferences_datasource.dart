/// Abstraction for recurring reminder preferences (avoids direct PrefHelper in repository).
abstract class RecurringReminderPreferencesDataSource {
  Future<bool> getRemindersEnabled();
  Future<void> setRemindersEnabled(bool enabled);
}
