import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';

extension RecurrenceTypeDisplay on RecurrenceType {
  String displayName(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case RecurrenceType.daily:
          return 'يومي';
        case RecurrenceType.weekly:
          return 'أسبوعي';
        case RecurrenceType.monthly:
          return 'شهري';
        case RecurrenceType.yearly:
          return 'سنوي';
      }
    }
    switch (this) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }
}

extension RecurringExpenseEntityDisplay on RecurringExpenseEntity {
  /// Next due date: from entity or calculated from recurrence rules.
  DateTime get nextDueDate => nextDue ?? _calculateNextDue();

  DateTime _calculateNextDue() {
    final now = DateTime.now();
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return now.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        final targetWeekday = dayOfWeek ?? 1;
        var next = now;
        while (next.weekday != targetWeekday) {
          next = next.add(const Duration(days: 1));
        }
        if (_isSameDay(next, now)) {
          next = next.add(const Duration(days: 7));
        }
        return next;
      case RecurrenceType.monthly:
        final targetDay = dayOfMonth ?? 1;
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
        final targetDay = dayOfMonth ?? 1;
        var next = DateTime(now.year, now.month, targetDay);
        if (next.isBefore(now)) {
          next = DateTime(now.year + 1, now.month, targetDay);
        }
        return next;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
