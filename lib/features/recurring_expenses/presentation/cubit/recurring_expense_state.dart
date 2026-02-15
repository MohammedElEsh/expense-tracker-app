import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';

sealed class RecurringExpenseState extends Equatable {
  const RecurringExpenseState();

  @override
  List<Object?> get props => [];
}

final class RecurringExpenseInitial extends RecurringExpenseState {
  const RecurringExpenseInitial();
}

final class RecurringExpenseLoading extends RecurringExpenseState {
  const RecurringExpenseLoading();
}

final class RecurringExpenseLoaded extends RecurringExpenseState {
  final List<RecurringExpenseEntity> allRecurringExpenses;
  final List<RecurringExpenseEntity> filteredRecurringExpenses;
  final double monthlyTotal;
  final String? selectedCategory;
  final bool? selectedStatus;
  final RecurrenceType? selectedFrequency;
  /// Shown in snackbar after e.g. failed add/delete rollback
  final String? lastError;

  const RecurringExpenseLoaded({
    required this.allRecurringExpenses,
    required this.filteredRecurringExpenses,
    this.monthlyTotal = 0.0,
    this.selectedCategory,
    this.selectedStatus,
    this.selectedFrequency,
    this.lastError,
  });

  int get totalActiveRecurringExpenses =>
      allRecurringExpenses.where((e) => e.isActive).length;
  int get totalInactiveRecurringExpenses =>
      allRecurringExpenses.where((e) => !e.isActive).length;

  bool get hasActiveFilters =>
      selectedCategory != null ||
      selectedStatus != null ||
      selectedFrequency != null;

  @override
  List<Object?> get props => [
        allRecurringExpenses,
        filteredRecurringExpenses,
        monthlyTotal,
        selectedCategory,
        selectedStatus,
        selectedFrequency,
        lastError,
      ];
}

final class RecurringExpenseError extends RecurringExpenseState {
  final String message;

  const RecurringExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

extension RecurringExpenseStateX on RecurringExpenseState {
  bool get isLoading => this is RecurringExpenseLoading;
  bool get hasLoaded => this is RecurringExpenseLoaded;
  List<RecurringExpenseEntity> get allRecurringExpenses =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).allRecurringExpenses
          : [];
  List<RecurringExpenseEntity> get filteredRecurringExpenses =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).filteredRecurringExpenses
          : [];
  double get monthlyTotal =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).monthlyTotal
          : 0.0;
  int get totalActiveRecurringExpenses =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).totalActiveRecurringExpenses
          : 0;
  int get totalInactiveRecurringExpenses =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).totalInactiveRecurringExpenses
          : 0;
  String? get errorMessage =>
      this is RecurringExpenseError ? (this as RecurringExpenseError).message : null;
  String? get lastError =>
      this is RecurringExpenseLoaded
          ? (this as RecurringExpenseLoaded).lastError
          : null;
}
