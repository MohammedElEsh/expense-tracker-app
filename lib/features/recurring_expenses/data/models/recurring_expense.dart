import 'package:expense_tracker/core/domain/app_mode.dart';

/// Recurring Expense Model
/// Supports API format with accountId, dayOfWeek, and all recurrence types
class RecurringExpense {
  final String id;
  final String accountId;
  final String? accountName; // Populated from API response (accountId.name)
  final double amount;
  final String category;
  final String notes;
  final RecurrenceType recurrenceType;
  final int? dayOfMonth; // For monthly/yearly (1-31)
  final int? dayOfWeek; // For weekly (1=Monday, 7=Sunday)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastProcessed;
  final DateTime? nextDue;
  final AppMode appMode;

  RecurringExpense({
    required this.id,
    required this.accountId,
    this.accountName,
    required this.amount,
    required this.category,
    required this.notes,
    required this.recurrenceType,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.appMode,
    this.isActive = true,
    DateTime? createdAt,
    this.lastProcessed,
    this.nextDue,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for API POST/PUT requests
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'accountId': accountId,
      'amount': amount,
      'category': category,
      'notes': notes,
      'recurrenceType': recurrenceType.apiValue,
    };

    // Add dayOfMonth for monthly/yearly recurrence
    if (recurrenceType == RecurrenceType.monthly ||
        recurrenceType == RecurrenceType.yearly) {
      json['dayOfMonth'] = dayOfMonth ?? DateTime.now().day;
    }

    // Add dayOfWeek for weekly recurrence
    if (recurrenceType == RecurrenceType.weekly) {
      json['dayOfWeek'] = dayOfWeek ?? DateTime.now().weekday;
    }

    return json;
  }

  /// Convert to Map for local storage (legacy support)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'accountName': accountName,
      'amount': amount,
      'category': category,
      'notes': notes,
      'recurrenceType': recurrenceType.index,
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastProcessed': lastProcessed?.millisecondsSinceEpoch,
      'nextDue': nextDue?.millisecondsSinceEpoch,
      'appMode': appMode.name,
    };
  }

  /// Create from API JSON response
  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    // Handle accountId - can be a string or an object with _id and name
    String accountId;
    String? accountName;

    final accountIdValue = json['accountId'];
    if (accountIdValue is Map) {
      accountId = accountIdValue['_id']?.toString() ?? '';
      accountName = accountIdValue['name']?.toString();
    } else {
      accountId = accountIdValue?.toString() ?? '';
    }

    // Parse recurrence type from API string
    final recurrenceTypeStr = json['recurrenceType']?.toString() ?? 'monthly';
    final recurrenceType = RecurrenceTypeExtension.fromString(
      recurrenceTypeStr,
    );

    // Parse nextDue date
    DateTime? nextDue;
    if (json['nextDue'] != null) {
      nextDue = _parseDateTime(json['nextDue']);
    }

    // Parse createdAt date
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      createdAt = _parseDateTime(json['createdAt']) ?? DateTime.now();
    }

    // Parse lastProcessed date
    DateTime? lastProcessed;
    if (json['lastProcessed'] != null) {
      lastProcessed = _parseDateTime(json['lastProcessed']);
    }

    // Parse appMode
    final appModeStr = json['appMode']?.toString() ?? 'personal';
    final appMode = AppMode.values.firstWhere(
      (mode) => mode.name == appModeStr,
      orElse: () => AppMode.personal,
    );

    return RecurringExpense(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      accountId: accountId,
      accountName: accountName,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      recurrenceType: recurrenceType,
      dayOfMonth: json['dayOfMonth'] as int?,
      dayOfWeek: json['dayOfWeek'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: createdAt,
      lastProcessed: lastProcessed,
      nextDue: nextDue,
      appMode: appMode,
    );
  }

  /// Create from local storage Map (legacy support)
  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    // Check if this is API format
    if (map.containsKey('_id') || map['recurrenceType'] is String) {
      return RecurringExpense.fromJson(map);
    }

    return RecurringExpense(
      id: map['id']?.toString() ?? '',
      accountId: map['accountId']?.toString() ?? '',
      accountName: map['accountName']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      recurrenceType: RecurrenceType.values[map['recurrenceType'] as int? ?? 2],
      dayOfMonth: map['dayOfMonth'] as int?,
      dayOfWeek: map['dayOfWeek'] as int?,
      appMode: AppMode.values.firstWhere(
        (mode) => mode.name == map['appMode'],
        orElse: () => AppMode.personal,
      ),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      lastProcessed: _parseDateTime(map['lastProcessed']),
      nextDue: _parseDateTime(map['nextDue']),
    );
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Create a copy with updated fields
  RecurringExpense copyWith({
    String? id,
    String? accountId,
    String? accountName,
    double? amount,
    String? category,
    String? notes,
    RecurrenceType? recurrenceType,
    int? dayOfMonth,
    int? dayOfWeek,
    AppMode? appMode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastProcessed,
    DateTime? nextDue,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      appMode: appMode ?? this.appMode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      nextDue: nextDue ?? this.nextDue,
    );
  }

  /// Calculate the next due date based on recurrence type
  DateTime calculateNextDue() {
    final now = DateTime.now();

    switch (recurrenceType) {
      case RecurrenceType.daily:
        return now.add(const Duration(days: 1));

      case RecurrenceType.weekly:
        final targetWeekday = dayOfWeek ?? 1; // Default to Monday
        var nextDate = now;

        while (nextDate.weekday != targetWeekday) {
          nextDate = nextDate.add(const Duration(days: 1));
        }

        // If it's today, move to next week
        if (nextDate.day == now.day &&
            nextDate.month == now.month &&
            nextDate.year == now.year) {
          nextDate = nextDate.add(const Duration(days: 7));
        }

        return nextDate;

      case RecurrenceType.monthly:
        final targetDay = dayOfMonth ?? 1;
        var nextDate = DateTime(now.year, now.month, targetDay);

        if (nextDate.isBefore(now) || _isSameDay(nextDate, now)) {
          nextDate = DateTime(now.year, now.month + 1, targetDay);
        }

        // Handle months with fewer days
        if (targetDay > 28) {
          final lastDayOfMonth =
              DateTime(nextDate.year, nextDate.month + 1, 0).day;
          if (targetDay > lastDayOfMonth) {
            nextDate = DateTime(nextDate.year, nextDate.month, lastDayOfMonth);
          }
        }

        return nextDate;

      case RecurrenceType.yearly:
        final targetDay = dayOfMonth ?? 1;
        var nextDate = DateTime(now.year, now.month, targetDay);

        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year + 1, now.month, targetDay);
        }

        return nextDate;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if this expense should be processed
  bool shouldProcess() {
    if (!isActive) return false;

    final now = DateTime.now();
    final next = nextDue ?? calculateNextDue();

    return now.isAfter(next) || _isSameDay(now, next);
  }

  /// Get all missed dates that need to be processed
  /// Returns a list of all missed dates (up to a reasonable max limit)
  List<DateTime> getMissedDates({
    DateTime? referenceDate,
    int maxDaysBack = 30,
  }) {
    if (!isActive) return [];

    final now = referenceDate ?? DateTime.now();
    final startDate = lastProcessed ?? createdAt;

    // Determine start date: either lastProcessed or createdAt
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);

    // Limit how far back we go
    final limitDate = now.subtract(Duration(days: maxDaysBack));
    if (currentDate.isBefore(limitDate)) {
      currentDate = limitDate;
    }

    final missedDates = <DateTime>[];

    switch (recurrenceType) {
      case RecurrenceType.daily:
        var date = currentDate.add(const Duration(days: 1));
        while (date.isBefore(now) || _isSameDay(date, now)) {
          missedDates.add(DateTime(date.year, date.month, date.day));
          date = date.add(const Duration(days: 1));
          if (missedDates.length > maxDaysBack) break;
        }
        break;

      case RecurrenceType.weekly:
        final targetWeekday = dayOfWeek ?? 1;
        var date = currentDate;

        // Find the next target weekday
        while (date.weekday != targetWeekday) {
          date = date.add(const Duration(days: 1));
        }

        // Skip if it's the same day as lastProcessed
        if (_isSameDay(date, currentDate) && lastProcessed != null) {
          date = date.add(const Duration(days: 7));
        }

        while (date.isBefore(now) || _isSameDay(date, now)) {
          missedDates.add(DateTime(date.year, date.month, date.day));
          date = date.add(const Duration(days: 7));
          if (missedDates.length > 8) break; // Max 8 weeks
        }
        break;

      case RecurrenceType.monthly:
        final targetDay = dayOfMonth ?? 1;
        var year = currentDate.year;
        var month = currentDate.month;
        var date = _getValidMonthlyDate(year, month, targetDay);

        if (date.isBefore(currentDate) ||
            (_isSameDay(date, currentDate) && lastProcessed != null)) {
          month++;
          if (month > 12) {
            month = 1;
            year++;
          }
          date = _getValidMonthlyDate(year, month, targetDay);
        }

        while (date.isBefore(now) || _isSameDay(date, now)) {
          missedDates.add(DateTime(date.year, date.month, date.day));
          month++;
          if (month > 12) {
            month = 1;
            year++;
          }
          date = _getValidMonthlyDate(year, month, targetDay);
          if (missedDates.length > 12) break; // Max 12 months
        }
        break;

      case RecurrenceType.yearly:
        final targetMonth = createdAt.month;
        final targetDay = dayOfMonth ?? 1;
        var year = currentDate.year;
        var date = DateTime(year, targetMonth, targetDay);

        if (date.isBefore(currentDate) ||
            (_isSameDay(date, currentDate) && lastProcessed != null)) {
          year++;
          date = DateTime(year, targetMonth, targetDay);
        }

        while (date.isBefore(now) || _isSameDay(date, now)) {
          missedDates.add(DateTime(date.year, date.month, date.day));
          year++;
          date = DateTime(year, targetMonth, targetDay);
          if (missedDates.length > 3) break; // Max 3 years
        }
        break;
    }

    return missedDates;
  }

  /// Get a valid date for a month, handling months with fewer days
  DateTime _getValidMonthlyDate(int year, int month, int targetDay) {
    if (targetDay > 28) {
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      if (targetDay > lastDayOfMonth) {
        return DateTime(year, month, lastDayOfMonth);
      }
    }
    return DateTime(year, month, targetDay);
  }

  /// Get display text for the schedule
  String get scheduleDisplayText {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'يومياً';
      case RecurrenceType.weekly:
        return 'أسبوعياً - ${_getWeekdayName(dayOfWeek ?? 1)}';
      case RecurrenceType.monthly:
        return 'شهرياً - يوم ${dayOfMonth ?? 1}';
      case RecurrenceType.yearly:
        return 'سنوياً - يوم ${dayOfMonth ?? 1}';
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      '',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekdays[weekday.clamp(1, 7)];
  }

  @override
  String toString() {
    return 'RecurringExpense(id: $id, amount: $amount, category: $category, '
        'recurrenceType: ${recurrenceType.name}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringExpense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Recurrence type enum
enum RecurrenceType { daily, weekly, monthly, yearly }

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
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

  String get englishName {
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

  /// API value for recurrence type
  String get apiValue {
    switch (this) {
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.monthly:
        return 'monthly';
      case RecurrenceType.yearly:
        return 'yearly';
    }
  }

  /// Parse from API string value
  static RecurrenceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'monthly':
        return RecurrenceType.monthly;
      case 'yearly':
        return RecurrenceType.yearly;
      default:
        return RecurrenceType.monthly;
    }
  }
}
