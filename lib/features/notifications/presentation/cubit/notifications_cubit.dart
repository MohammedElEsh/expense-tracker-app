import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/disable_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/enable_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/get_notifications_enabled_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/reschedule_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/get_recurring_reminders_enabled_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/reschedule_all_recurring_reminders_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/set_recurring_reminders_enabled_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/show_test_recurring_reminder_usecase.dart';

/// Notifications Cubit: communicates only with use cases (no direct service access).
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetNotificationsEnabledUseCase getNotificationsEnabledUseCase,
    required EnableNotificationsUseCase enableNotificationsUseCase,
    required DisableNotificationsUseCase disableNotificationsUseCase,
    required RescheduleNotificationsUseCase rescheduleNotificationsUseCase,
    required GetRecurringRemindersEnabledUseCase getRecurringRemindersEnabledUseCase,
    required SetRecurringRemindersEnabledUseCase setRecurringRemindersEnabledUseCase,
    required RescheduleAllRecurringRemindersUseCase rescheduleAllRecurringRemindersUseCase,
    required ShowTestRecurringReminderUseCase showTestRecurringReminderUseCase,
    required RequestNotificationPermissionUseCase requestNotificationPermissionUseCase,
  })  : _getEnabled = getNotificationsEnabledUseCase,
        _enable = enableNotificationsUseCase,
        _disable = disableNotificationsUseCase,
        _reschedule = rescheduleNotificationsUseCase,
        _getRecurringEnabled = getRecurringRemindersEnabledUseCase,
        _setRecurringEnabled = setRecurringRemindersEnabledUseCase,
        _rescheduleAll = rescheduleAllRecurringRemindersUseCase,
        _showTest = showTestRecurringReminderUseCase,
        _requestPermission = requestNotificationPermissionUseCase,
        super(const NotificationsLoading());

  final GetNotificationsEnabledUseCase _getEnabled;
  final EnableNotificationsUseCase _enable;
  final DisableNotificationsUseCase _disable;
  final RescheduleNotificationsUseCase _reschedule;
  final GetRecurringRemindersEnabledUseCase _getRecurringEnabled;
  final SetRecurringRemindersEnabledUseCase _setRecurringEnabled;
  final RescheduleAllRecurringRemindersUseCase _rescheduleAll;
  final ShowTestRecurringReminderUseCase _showTest;
  final RequestNotificationPermissionUseCase _requestPermission;

  /// Load current enabled state and recurring reminders state.
  Future<void> load() async {
    emit(const NotificationsLoading());
    try {
      final enabled = await _getEnabled();
      final recurringEnabled = await _getRecurringEnabled();
      emit(enabled
          ? NotificationsEnabled(recurringRemindersEnabled: recurringEnabled)
          : NotificationsDisabled(recurringRemindersEnabled: recurringEnabled));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Enable notifications.
  Future<void> enable() async {
    emit(const NotificationsLoading());
    try {
      await _enable();
      final recurringEnabled = state.recurringRemindersEnabled ?? await _getRecurringEnabled();
      emit(NotificationsEnabled(recurringRemindersEnabled: recurringEnabled));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Disable notifications.
  Future<void> disable() async {
    emit(const NotificationsLoading());
    try {
      await _disable();
      final recurringEnabled = state.recurringRemindersEnabled ?? await _getRecurringEnabled();
      emit(NotificationsDisabled(recurringRemindersEnabled: recurringEnabled));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Reschedule notifications (e.g. after data change).
  Future<void> reschedule() async {
    try {
      await _reschedule();
      final enabled = await _getEnabled();
      final recurringEnabled = state.recurringRemindersEnabled ?? await _getRecurringEnabled();
      emit(enabled
          ? NotificationsEnabled(recurringRemindersEnabled: recurringEnabled)
          : NotificationsDisabled(recurringRemindersEnabled: recurringEnabled));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Set recurring reminders on/off. Requests permission when enabling.
  Future<void> setRecurringRemindersEnabled(bool value) async {
    if (state.isApplyingToggle) return;
    final prev = state.recurringRemindersEnabled;
    emit(NotificationsLoading(recurringRemindersEnabled: prev, isApplyingToggle: true));
    try {
      if (value) await _requestPermission();
      await _setRecurringEnabled(value);
      emit(value
          ? NotificationsEnabled(recurringRemindersEnabled: value, isApplyingToggle: false)
          : NotificationsDisabled(recurringRemindersEnabled: value, isApplyingToggle: false));
    } catch (e) {
      emit(NotificationsError(e.toString(), recurringRemindersEnabled: prev, isApplyingToggle: false));
    }
  }

  /// Reschedule all recurring reminders.
  Future<void> rescheduleAll() async {
    try {
      await _rescheduleAll();
      final recurringEnabled = state.recurringRemindersEnabled ?? await _getRecurringEnabled();
      if (state is NotificationsEnabled) {
        emit(NotificationsEnabled(recurringRemindersEnabled: recurringEnabled));
      } else if (state is NotificationsDisabled) {
        emit(NotificationsDisabled(recurringRemindersEnabled: recurringEnabled));
      } else {
        emit(NotificationsEnabled(recurringRemindersEnabled: recurringEnabled));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Send a test recurring reminder notification.
  Future<void> sendTest() async {
    try {
      await _showTest();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}
