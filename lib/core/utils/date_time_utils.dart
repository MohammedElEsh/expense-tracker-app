// ✅ Shared DateTime utilities for consistent date/time formatting across the app
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Utility class for consistent expense date/time formatting
class DateTimeUtils {
  /// Parse ISO string from API (handles UTC 'Z' suffix)
  /// Returns local DateTime
  static DateTime parseApiDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    try {
      if (dateValue is String) {
        // Parse ISO string - DateTime.parse handles UTC 'Z' automatically
        final parsed = DateTime.parse(dateValue);
        // If string ends with 'Z', it's UTC - convert to local
        if (dateValue.toString().endsWith('Z')) {
          return parsed.toLocal();
        }
        // If already has timezone info, return as-is
        return parsed.isUtc ? parsed.toLocal() : parsed;
      } else if (dateValue is int) {
        // Parse milliseconds since epoch (assume UTC if > threshold)
        return DateTime.fromMillisecondsSinceEpoch(
          dateValue,
          isUtc: true,
        ).toLocal();
      }
    } catch (e) {
      debugPrint(
        '❌ DateTimeUtils.parseApiDateTime error: $e for value: $dateValue',
      );
    }

    return DateTime.now();
  }

  /// Format expense date for list view (compact)
  /// Uses expense.date for date, expense.createdAt for time (if available)
  static String formatExpenseDateTime({
    required DateTime expenseDate,
    DateTime? createdAt,
    bool isRTL = false,
  }) {
    final locale = isRTL ? 'ar' : 'en';

    // Date part from expense.date
    final datePart = DateFormat('dd MMM yyyy', locale).format(expenseDate);

    // Time part from createdAt (if available), otherwise don't show time
    if (createdAt != null) {
      final timePart = DateFormat('h:mm a', locale).format(createdAt);
      return '$datePart • $timePart';
    }

    // If no createdAt, just show date (like Details view does)
    return datePart;
  }

  /// Format expense date for details view header (date only)
  static String formatExpenseDateHeader({
    required DateTime expenseDate,
    bool isRTL = false,
  }) {
    final locale = isRTL ? 'ar' : 'en';
    return DateFormat('dd MMMM yyyy', locale).format(expenseDate);
  }

  /// Format expense date for details view basic card (full date)
  static String formatExpenseDateDetails({
    required DateTime expenseDate,
    bool isRTL = false,
  }) {
    final locale = isRTL ? 'ar' : 'en';
    return DateFormat('EEEE, dd MMMM yyyy', locale).format(expenseDate);
  }

  /// Format createdAt/updatedAt for details view (date + time)
  static String formatTimestampDetails({
    required DateTime timestamp,
    bool isRTL = false,
  }) {
    final locale = isRTL ? 'ar' : 'en';
    return DateFormat('EEEE, dd MMMM yyyy • hh:mm a', locale).format(timestamp);
  }

  /// Debug helper: Log date/time parsing and formatting
  static void debugDateTimeParsing({
    required String rawApiValue,
    required DateTime parsedDateTime,
    required String renderedString,
    String? context,
  }) {
    if (kDebugMode) {
      debugPrint('🔍 DateTimeUtils Debug [${context ?? "unknown"}]:');
      debugPrint('   Raw API: $rawApiValue');
      debugPrint('   Parsed (UTC): ${parsedDateTime.toUtc()}');
      debugPrint('   Parsed (Local): $parsedDateTime');
      debugPrint('   Rendered: $renderedString');
    }
  }
}
