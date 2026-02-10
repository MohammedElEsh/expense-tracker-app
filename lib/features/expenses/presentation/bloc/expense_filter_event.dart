// Expense Filter - BLoC Events
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ExpenseFilterEvent extends Equatable {
  const ExpenseFilterEvent();

  @override
  List<Object?> get props => [];
}

// تغيير نص البحث
class ChangeSearchQueryEvent extends ExpenseFilterEvent {
  final String query;

  const ChangeSearchQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// تغيير الفئة المحددة
class ChangeCategoryFilterEvent extends ExpenseFilterEvent {
  final String? category;

  const ChangeCategoryFilterEvent(this.category);

  @override
  List<Object?> get props => [category];
}

// تغيير نطاق التاريخ
class ChangeDateRangeFilterEvent extends ExpenseFilterEvent {
  final DateTimeRange? dateRange;

  const ChangeDateRangeFilterEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

// تغيير نطاق المبلغ
class ChangeAmountRangeFilterEvent extends ExpenseFilterEvent {
  final double? minAmount;
  final double? maxAmount;

  const ChangeAmountRangeFilterEvent({this.minAmount, this.maxAmount});

  @override
  List<Object?> get props => [minAmount, maxAmount];
}

// تبديل رؤية الفلاتر
class ToggleFilterVisibilityEvent extends ExpenseFilterEvent {
  const ToggleFilterVisibilityEvent();
}

// إعادة تعيين كل الفلاتر
class ResetFiltersEvent extends ExpenseFilterEvent {
  const ResetFiltersEvent();
}

// تطبيق الفلاتر
class ApplyFiltersEvent extends ExpenseFilterEvent {
  const ApplyFiltersEvent();
}
