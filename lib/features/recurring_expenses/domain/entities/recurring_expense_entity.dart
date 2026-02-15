import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';

/// Pure domain entity for a recurring expense (no Flutter/data imports).
class RecurringExpenseEntity {
  final String id;
  final String accountId;
  final String? accountName;
  final double amount;
  final String category;
  final String notes;
  final RecurrenceType recurrenceType;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastProcessed;
  final DateTime? nextDue;
  /// App mode as string: 'personal' | 'business'
  final String appMode;

  const RecurringExpenseEntity({
    required this.id,
    required this.accountId,
    this.accountName,
    required this.amount,
    required this.category,
    required this.notes,
    required this.recurrenceType,
    this.dayOfMonth,
    this.dayOfWeek,
    this.isActive = true,
    required this.createdAt,
    this.lastProcessed,
    this.nextDue,
    this.appMode = 'personal',
  });

  RecurringExpenseEntity copyWith({
    String? id,
    String? accountId,
    String? accountName,
    double? amount,
    String? category,
    String? notes,
    RecurrenceType? recurrenceType,
    int? dayOfMonth,
    int? dayOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastProcessed,
    DateTime? nextDue,
    String? appMode,
  }) {
    return RecurringExpenseEntity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      nextDue: nextDue ?? this.nextDue,
      appMode: appMode ?? this.appMode,
    );
  }
}
