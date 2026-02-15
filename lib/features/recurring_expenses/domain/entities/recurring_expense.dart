import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:uuid/uuid.dart';

class RecurringExpense {
  final String id;
  final double amount;
  final String category;
  final String notes;
  final RecurrenceType recurrenceType;
  final int dayOfMonth; // للمصروفات الشهرية (1-31)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastProcessed;
  final DateTime? nextDue;
  final AppMode appMode; // نوع الوضع (شخصي أو تجاري)

  RecurringExpense({
    String? id,
    required this.amount,
    required this.category,
    required this.notes,
    required this.recurrenceType,
    required this.dayOfMonth,
    required this.appMode,
    this.isActive = true,
    DateTime? createdAt,
    this.lastProcessed,
    this.nextDue,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // تحويل إلى Map للحفظ في Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'notes': notes,
      'recurrenceType': recurrenceType.index,
      'dayOfMonth': dayOfMonth,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastProcessed': lastProcessed?.millisecondsSinceEpoch,
      'nextDue': nextDue?.millisecondsSinceEpoch,
      'appMode': appMode.name,
    };
  }

  // تحويل من Map للقراءة من Firebase/Hive
  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      notes: map['notes'],
      recurrenceType: RecurrenceType.values[map['recurrenceType']],
      dayOfMonth: map['dayOfMonth'],
      appMode: AppMode.values.firstWhere(
        (mode) => mode.name == map['appMode'],
        orElse: () => AppMode.personal, // افتراضي للبيانات القديمة
      ),
      isActive: map['isActive'],
      createdAt: _parseDateTime(map['createdAt']),
      lastProcessed:
          map['lastProcessed'] != null
              ? _parseDateTime(map['lastProcessed'])
              : null,
      nextDue: map['nextDue'] != null ? _parseDateTime(map['nextDue']) : null,
    );
  }

  // Helper method لتحويل int إلى DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  // نسخة محدثة من المصروف المتكرر
  RecurringExpense copyWith({
    String? id,
    double? amount,
    String? category,
    String? notes,
    RecurrenceType? recurrenceType,
    int? dayOfMonth,
    AppMode? appMode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastProcessed,
    DateTime? nextDue,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      appMode: appMode ?? this.appMode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      nextDue: nextDue ?? this.nextDue,
    );
  }

  // حساب التاريخ القادم للمصروف المتكرر
  DateTime calculateNextDue() {
    final now = DateTime.now();

    switch (recurrenceType) {
      case RecurrenceType.daily:
        // للمصروف اليومي، نفس اليوم في اليوم التالي
        return now.add(const Duration(days: 1));

      case RecurrenceType.monthly:
        // العثور على التاريخ القادم في الشهر الحالي أو القادم
        var nextDate = DateTime(now.year, now.month, dayOfMonth);

        // إذا كان التاريخ قد مضى في الشهر الحالي، انتقل للشهر القادم
        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year, now.month + 1, dayOfMonth);
        }

        // التعامل مع الشهور التي لا تحتوي على 31 يوم
        if (dayOfMonth > 28) {
          final lastDayOfMonth =
              DateTime(nextDate.year, nextDate.month + 1, 0).day;
          if (dayOfMonth > lastDayOfMonth) {
            nextDate = DateTime(nextDate.year, nextDate.month, lastDayOfMonth);
          }
        }

        return nextDate;

      case RecurrenceType.weekly:
        // للأسبوعي، استخدم يوم الأسبوع
        final targetWeekday = dayOfMonth; // 1=Monday, 7=Sunday
        var nextDate = now;

        while (nextDate.weekday != targetWeekday) {
          nextDate = nextDate.add(const Duration(days: 1));
        }

        // إذا كان اليوم هو نفسه، انتقل للأسبوع القادم
        if (nextDate.day == now.day) {
          nextDate = nextDate.add(const Duration(days: 7));
        }

        return nextDate;

      case RecurrenceType.yearly:
        // للسنوي، نفس اليوم والشهر في السنة القادمة
        var nextDate = DateTime(now.year, now.month, dayOfMonth);

        if (nextDate.isBefore(now)) {
          nextDate = DateTime(now.year + 1, now.month, dayOfMonth);
        }

        return nextDate;
    }
  }

  // التحقق من أن المصروف يحتاج إلى إضافة
  bool shouldProcess() {
    if (!isActive) return false;

    final now = DateTime.now();
    final next = nextDue ?? calculateNextDue();

    return now.isAfter(next) ||
        (now.year == next.year &&
            now.month == next.month &&
            now.day == next.day);
  }
}

enum RecurrenceType {
  daily, // يومي
  weekly, // أسبوعي
  monthly, // شهري
  yearly, // سنوي
}

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
}
