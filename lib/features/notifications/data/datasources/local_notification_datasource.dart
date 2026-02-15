/// Local data source for notification settings (prefs / platform).
/// TODO: Inject SharedPreferences or PrefHelper; integrate permission request on enable.
class LocalNotificationDataSource {
  const LocalNotificationDataSource();
  // TODO: Add PrefHelper prefHelper and FlutterLocalNotificationsPlugin for reschedule.

  /// Read whether notifications are enabled.
  Future<bool> getEnabled() async {
    // TODO: return prefHelper.getRecurringExpenseRemindersEnabled() or dedicated key.
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  /// Persist enabled state.
  Future<void> setEnabled(bool enabled) async {
    // TODO: await prefHelper.setRecurringExpenseRemindersEnabled(enabled);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Reschedule all notifications (e.g. after enabling).
  Future<void> reschedule() async {
    // TODO: Call notification service reschedule or delegate to recurring reminders.
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
