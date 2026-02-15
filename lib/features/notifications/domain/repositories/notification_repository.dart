/// Repository interface for notification settings (domain only).
abstract class NotificationRepository {
  /// Whether notifications are enabled.
  Future<bool> areEnabled();

  /// Enable notifications (e.g. persist preference, request permission).
  Future<void> enable();

  /// Disable notifications (e.g. persist preference, cancel scheduled).
  Future<void> disable();

  /// Reschedule all notifications (e.g. after enabling or data change).
  Future<void> reschedule();

  /// Request runtime notification permission (Android 13+ / iOS).
  Future<void> requestPermission();
}
