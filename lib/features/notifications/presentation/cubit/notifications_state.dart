import 'package:equatable/equatable.dart';

/// Base state for notification settings (enabled / disabled / loading).
sealed class NotificationsState extends Equatable {
  const NotificationsState({
    this.recurringRemindersEnabled,
    this.isApplyingToggle = false,
  });

  /// Recurring reminders on/off (from recurring_expenses use cases).
  final bool? recurringRemindersEnabled;
  final bool isApplyingToggle;

  @override
  List<Object?> get props => [recurringRemindersEnabled, isApplyingToggle];
}

/// Loading current state or applying change.
final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading({super.recurringRemindersEnabled, super.isApplyingToggle});
}

/// Notifications are enabled.
final class NotificationsEnabled extends NotificationsState {
  const NotificationsEnabled({super.recurringRemindersEnabled, super.isApplyingToggle});
}

/// Notifications are disabled.
final class NotificationsDisabled extends NotificationsState {
  const NotificationsDisabled({super.recurringRemindersEnabled, super.isApplyingToggle});
}

/// An error occurred (e.g. permission denied).
final class NotificationsError extends NotificationsState {
  const NotificationsError(this.message, {super.recurringRemindersEnabled, super.isApplyingToggle});

  final String message;

  @override
  List<Object?> get props => [message, ...super.props];
}
