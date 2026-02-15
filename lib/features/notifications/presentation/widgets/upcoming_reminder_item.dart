import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';
import 'package:timezone/timezone.dart' as tz;

/// Keep in sync with RecurringExpenseNotificationService defaults.
const int defaultReminderHour = 9;
const int defaultReminderMinute = 0;

/// Upcoming window for in-app reminders list.
const int defaultUpcomingDays = 30;

/// Lightweight view-model for a single upcoming reminder row.
class UpcomingItem {
  const UpcomingItem({
    required this.expenseId,
    required this.title,
    required this.amountLabel,
    required this.dateLabel,
    required this.relativeLabel,
    required this.isToday,
    required this.isTomorrow,
    required this.date,
  });

  final String expenseId;
  final String title;
  final String amountLabel;
  final String dateLabel;
  final String relativeLabel;
  final bool isToday;
  final bool isTomorrow;
  final tz.TZDateTime date;
}

/// Pure helper that converts a list of [RecurringExpenseEntity] into sorted
/// [UpcomingItem]s falling within the next [defaultUpcomingDays] days.
class UpcomingItemsBuilder {
  const UpcomingItemsBuilder._();

  static List<UpcomingItem> build(List<RecurringExpenseEntity> expenses) {
    final now = tz.TZDateTime.now(tz.local);
    final end = now.add(const Duration(days: defaultUpcomingDays));

    final List<UpcomingItem> items = [];

    for (final e in expenses) {
      if (!e.isActive || e.id.isEmpty) continue;

      final next = _nextReminderDate(e, now);
      if (next.isBefore(now) || next.isAfter(end)) continue;

      final diffDays = next.difference(now).inDays;
      final isToday = diffDays == 0 && next.day == now.day;
      final isTomorrow = diffDays <= 1 && !isToday;

      items.add(
        UpcomingItem(
          expenseId: e.id,
          title: 'Recurring: ${e.category}',
          amountLabel: e.amount.toStringAsFixed(2),
          dateLabel:
              '${_two(next.day)}/${_two(next.month)}/${next.year} • ${_two(next.hour)}:${_two(next.minute)}',
          relativeLabel:
              isToday
                  ? 'Today'
                  : isTomorrow
                  ? 'Tomorrow'
                  : 'In $diffDays days',
          isToday: isToday,
          isTomorrow: isTomorrow,
          date: next,
        ),
      );
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  // ---------------------- Date helpers ----------------------

  /// Next due date for entity (date only); used as base for reminder time.
  static DateTime _entityNextDueDate(RecurringExpenseEntity e) {
    final now = DateTime.now();
    switch (e.recurrenceType) {
      case RecurrenceType.daily:
        return now.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        final targetWeekday = e.dayOfWeek ?? 1;
        var next = now;
        while (next.weekday != targetWeekday) {
          next = next.add(const Duration(days: 1));
        }
        if (_isSameDay(next, now)) {
          next = next.add(const Duration(days: 7));
        }
        return next;
      case RecurrenceType.monthly:
        final targetDay = e.dayOfMonth ?? 1;
        var next = DateTime(now.year, now.month, targetDay);
        if (next.isBefore(now) || _isSameDay(next, now)) {
          next = DateTime(now.year, now.month + 1, targetDay);
        }
        if (targetDay > 28) {
          final lastDay = DateTime(next.year, next.month + 1, 0).day;
          if (targetDay > lastDay) {
            next = DateTime(next.year, next.month, lastDay);
          }
        }
        return next;
      case RecurrenceType.yearly:
        final targetDay = e.dayOfMonth ?? 1;
        var next = DateTime(now.year, now.month, targetDay);
        if (next.isBefore(now)) {
          next = DateTime(now.year + 1, now.month, targetDay);
        }
        return next;
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static tz.TZDateTime _nextReminderDate(
    RecurringExpenseEntity expense,
    tz.TZDateTime now,
  ) {
    final base = expense.nextDue ?? _entityNextDueDate(expense);
    var candidate = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day,
      defaultReminderHour,
      defaultReminderMinute,
    );

    if (!candidate.isBefore(now)) return candidate;

    switch (expense.recurrenceType) {
      case RecurrenceType.daily:
        while (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;

      case RecurrenceType.weekly:
        while (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 7));
        }
        return candidate;

      case RecurrenceType.monthly:
        while (candidate.isBefore(now)) {
          final nextMonth = _addMonths(candidate, 1);
          final day = candidate.day;
          final clampedDay = _clampDayOfMonth(
            nextMonth.year,
            nextMonth.month,
            day,
          );
          candidate = tz.TZDateTime(
            tz.local,
            nextMonth.year,
            nextMonth.month,
            clampedDay,
            defaultReminderHour,
            defaultReminderMinute,
          );
        }
        return candidate;

      case RecurrenceType.yearly:
        while (candidate.isBefore(now)) {
          candidate = tz.TZDateTime(
            tz.local,
            candidate.year + 1,
            candidate.month,
            candidate.day,
            defaultReminderHour,
            defaultReminderMinute,
          );
        }
        return candidate;
    }
  }

  static tz.TZDateTime _addMonths(tz.TZDateTime date, int monthsToAdd) {
    final y = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
    final m = ((date.month - 1 + monthsToAdd) % 12) + 1;
    return tz.TZDateTime(tz.local, y, m, 1, date.hour, date.minute);
  }

  static int _clampDayOfMonth(int year, int month, int day) {
    final last = DateTime(year, month + 1, 0).day;
    return day <= last ? day : last;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
