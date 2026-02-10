import 'dart:io';

import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Default reminder time (9:00 AM)
const int _defaultReminderHour = 9;
const int _defaultReminderMinute = 0;

/// IMPORTANT:
/// Android notification channel importance is locked on first creation.
/// If notifications were shown before, either uninstall/reinstall
/// OR change this channel id.
const String _channelId = 'recurring_expense_reminders_v2';
const String _channelName = 'Recurring Expense Reminders';
const String _channelDescription =
    'Reminders for recurring expenses (rent, bills, etc.)';

/// Dedicated ID for test notifications (won’t conflict with recurring ones)
const int _testNotificationId = 0x0FFFFFFF;

class RecurringExpenseNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  final Set<String> _scheduledExpenseIds = {};

  /// Stable notification id derived from expense id
  static int notificationIdFromExpenseId(String expenseId) {
    if (expenseId.isEmpty) return 0;
    return 0x10000000 | (expenseId.hashCode & 0x0FFFFFFF);
  }

  /// Initialize plugin + timezone + Android channel
  Future<void> initialize() async {
    if (_initialized) return;

    // ---------- Timezone init ----------
    tz.initializeTimeZones();
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();

      String timeZoneName;
      if (tzInfo is String) {
        timeZoneName = tzInfo;
      } else {
        timeZoneName = (tzInfo as dynamic).identifier as String;
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint(
        'RecurringExpenseNotificationService: timezone fallback to UTC ($e)',
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // ---------- Plugin init ----------
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ---------- Android channel + permission ----------
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high, // heads-up
      );
      await androidPlugin?.createNotificationChannel(channel);

      // Android 13+ runtime permission
      await androidPlugin?.requestNotificationsPermission();
    }

    _initialized = true;
    debugPrint('RecurringExpenseNotificationService: initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('Notification tapped: payload=$payload');
    }
  }

  // ---------- Notification details ----------

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  DarwinNotificationDetails _iosDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: false,
    );
  }

  NotificationDetails get _notificationDetails =>
      NotificationDetails(android: _androidDetails(), iOS: _iosDetails());

  // ---------- Scheduling helpers ----------

  tz.TZDateTime _scheduledDateAtReminderTime(RecurringExpense expense) {
    final nextDue = expense.nextDue ?? expense.calculateNextDue();

    var scheduled = tz.TZDateTime(
      tz.local,
      nextDue.year,
      nextDue.month,
      nextDue.day,
      _defaultReminderHour,
      _defaultReminderMinute,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) {
      scheduled = now.add(const Duration(minutes: 1));
    }

    return scheduled;
  }

  // ---------- Public API ----------

  Future<void> scheduleReminder(RecurringExpense expense) async {
    if (!_initialized) return;

    if (!expense.isActive || expense.id.isEmpty) {
      if (expense.id.isNotEmpty) await cancelReminder(expense.id);
      return;
    }

    final id = notificationIdFromExpenseId(expense.id);
    final scheduledDate = _scheduledDateAtReminderTime(expense);

    final title = 'Recurring: ${expense.category}';
    final body = expense.amount.toStringAsFixed(2);
    final payload = 'recurring:${expense.id}';

    DateTimeComponents? matchComponents;
    switch (expense.recurrenceType) {
      case RecurrenceType.daily:
        matchComponents = DateTimeComponents.time;
        break;
      case RecurrenceType.weekly:
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      case RecurrenceType.monthly:
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
        break;
      case RecurrenceType.yearly:
        matchComponents = null; // one-shot
        break;
    }

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchComponents,
        payload: payload,
      );

      _scheduledExpenseIds.add(expense.id);
      debugPrint('Scheduled reminder for ${expense.id}');
    } catch (e) {
      debugPrint('Schedule failed: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) return;

    try {
      await _plugin.show(
        id: _testNotificationId,
        title: 'Test reminder',
        body: 'Recurring expense reminder test',
        notificationDetails: _notificationDetails,
        payload: 'test',
      );
    } catch (e) {
      debugPrint('Test notification failed: $e');
    }
  }

  Future<void> cancelReminder(String expenseId) async {
    if (!_initialized || expenseId.isEmpty) return;

    final id = notificationIdFromExpenseId(expenseId);
    await _plugin.cancel(id: id);
    _scheduledExpenseIds.remove(expenseId);
  }

  Future<void> rescheduleAll(List<RecurringExpense> expenses) async {
    if (!_initialized) return;

    final currentIds =
        expenses.map((e) => e.id).where((id) => id.isNotEmpty).toSet();

    for (final oldId in _scheduledExpenseIds.toList()) {
      if (!currentIds.contains(oldId)) {
        await cancelReminder(oldId);
      }
    }

    for (final expense in expenses) {
      if (expense.isActive && expense.id.isNotEmpty) {
        await scheduleReminder(expense);
      }
    }
  }
}
