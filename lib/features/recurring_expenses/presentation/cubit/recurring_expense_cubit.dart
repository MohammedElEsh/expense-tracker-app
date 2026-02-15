import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurrence_type.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/create_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/delete_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/disable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/enable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/get_recurring_expenses_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/update_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_state.dart';

class RecurringExpenseCubit extends Cubit<RecurringExpenseState> {
  final GetRecurringExpensesUseCase getRecurringExpensesUseCase;
  final CreateRecurringExpenseUseCase createRecurringExpenseUseCase;
  final UpdateRecurringExpenseUseCase updateRecurringExpenseUseCase;
  final DeleteRecurringExpenseUseCase deleteRecurringExpenseUseCase;
  final EnableRecurringReminderUseCase enableReminderUseCase;
  final DisableRecurringReminderUseCase disableReminderUseCase;

  RecurringExpenseCubit({
    required this.getRecurringExpensesUseCase,
    required this.createRecurringExpenseUseCase,
    required this.updateRecurringExpenseUseCase,
    required this.deleteRecurringExpenseUseCase,
    required this.enableReminderUseCase,
    required this.disableReminderUseCase,
  }) : super(const RecurringExpenseInitial());

  static double _monthlyTotal(List<RecurringExpenseEntity> expenses) {
    double total = 0.0;
    for (final e in expenses.where((x) => x.isActive)) {
      switch (e.recurrenceType) {
        case RecurrenceType.daily:
          total += e.amount * 30;
          break;
        case RecurrenceType.weekly:
          total += e.amount * 4;
          break;
        case RecurrenceType.monthly:
          total += e.amount;
          break;
        case RecurrenceType.yearly:
          total += e.amount / 12;
          break;
      }
    }
    return total;
  }

  static String _messageFromError(Object error) {
    final s = error.toString();
    if (s.contains('NetworkException') || s.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    if (s.contains('ServerException')) return 'Server error. Please try again later.';
    if (s.contains('403') || s.contains('Forbidden')) {
      return 'You do not have permission to view recurring expenses.';
    }
    if (s.contains('401') || s.contains('Unauthorized')) {
      return 'Authentication failed. Please log in again.';
    }
    return s.replaceAll('Exception: ', '');
  }

  Future<void> loadRecurringExpenses() async {
    if (state.isLoading || (state.hasLoaded && state.allRecurringExpenses.isNotEmpty)) {
      return;
    }
    emit(const RecurringExpenseLoading());
    try {
      final list = await getRecurringExpensesUseCase(forceRefresh: false);
      final total = _monthlyTotal(list);
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: list,
        filteredRecurringExpenses: list,
        monthlyTotal: total,
      ));
    } catch (e) {
      debugPrint('RecurringExpenseCubit loadRecurringExpenses error: $e');
      emit(RecurringExpenseError(_messageFromError(e)));
    }
  }

  Future<void> refreshRecurringExpenses() async {
    emit(const RecurringExpenseLoading());
    final previous = state.allRecurringExpenses;
    try {
      final list = await getRecurringExpensesUseCase(forceRefresh: true);
      final total = _monthlyTotal(list);
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: list,
        filteredRecurringExpenses: _applyFilters(list),
        monthlyTotal: total,
        selectedCategory: state is RecurringExpenseLoaded
            ? (state as RecurringExpenseLoaded).selectedCategory
            : null,
        selectedStatus: state is RecurringExpenseLoaded
            ? (state as RecurringExpenseLoaded).selectedStatus
            : null,
        selectedFrequency: state is RecurringExpenseLoaded
            ? (state as RecurringExpenseLoaded).selectedFrequency
            : null,
      ));
    } catch (e) {
      debugPrint('RecurringExpenseCubit refreshRecurringExpenses error: $e');
      emit(RecurringExpenseError(_messageFromError(e)));
      if (previous.isNotEmpty) {
        emit(RecurringExpenseLoaded(
          allRecurringExpenses: previous,
          filteredRecurringExpenses: previous,
          monthlyTotal: _monthlyTotal(previous),
        ));
      }
    }
  }

  Future<void> addRecurringExpense(RecurringExpenseEntity entity) async {
    final prev = state is RecurringExpenseLoaded ? state as RecurringExpenseLoaded : null;
    final list = List<RecurringExpenseEntity>.from(state.allRecurringExpenses)..add(entity);
    final total = _monthlyTotal(list);
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: list,
      filteredRecurringExpenses: _applyFilters(list, existing: prev),
      monthlyTotal: total,
      selectedCategory: prev?.selectedCategory,
      selectedStatus: prev?.selectedStatus,
      selectedFrequency: prev?.selectedFrequency,
    ));

    try {
      final created = await createRecurringExpenseUseCase(entity);
      final updated = list.map((e) => e.id == entity.id ? created : e).toList();
      final newTotal = _monthlyTotal(updated);
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: updated,
        filteredRecurringExpenses: _applyFilters(updated, existing: prev),
        monthlyTotal: newTotal,
        selectedCategory: prev?.selectedCategory,
        selectedStatus: prev?.selectedStatus,
        selectedFrequency: prev?.selectedFrequency,
      ));
    } catch (e) {
      debugPrint('RecurringExpenseCubit addRecurringExpense error: $e');
      final rolledBack = list.where((x) => x.id != entity.id).toList();
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: rolledBack,
        filteredRecurringExpenses: _applyFilters(rolledBack, existing: prev),
        monthlyTotal: _monthlyTotal(rolledBack),
        selectedCategory: prev?.selectedCategory,
        selectedStatus: prev?.selectedStatus,
        selectedFrequency: prev?.selectedFrequency,
        lastError: _messageFromError(e),
      ));
    }
  }

  Future<void> updateRecurringExpense(RecurringExpenseEntity entity) async {
    final prev = state is RecurringExpenseLoaded ? state as RecurringExpenseLoaded : null;
    emit(const RecurringExpenseLoading());
    try {
      final updated = await updateRecurringExpenseUseCase(entity);
      final list = prev?.allRecurringExpenses ?? [];
      final newList = list.map((e) => e.id == entity.id ? updated : e).toList();
      final total = _monthlyTotal(newList);
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: newList,
        filteredRecurringExpenses: _applyFilters(newList, existing: prev),
        monthlyTotal: total,
        selectedCategory: prev?.selectedCategory,
        selectedStatus: prev?.selectedStatus,
        selectedFrequency: prev?.selectedFrequency,
      ));
    } catch (e) {
      debugPrint('RecurringExpenseCubit updateRecurringExpense error: $e');
      if (prev != null) {
        emit(prev);
      }
      emit(RecurringExpenseError(_messageFromError(e)));
    }
  }

  Future<void> deleteRecurringExpense(String id) async {
    final prev = state is RecurringExpenseLoaded ? state as RecurringExpenseLoaded : null;
    final toDelete = state.allRecurringExpenses.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Recurring expense not found: $id'),
    );
    final list = state.allRecurringExpenses.where((e) => e.id != id).toList();
    final total = _monthlyTotal(list);
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: list,
      filteredRecurringExpenses: _applyFilters(list, existing: prev),
      monthlyTotal: total,
      selectedCategory: prev?.selectedCategory,
      selectedStatus: prev?.selectedStatus,
      selectedFrequency: prev?.selectedFrequency,
    ));

    try {
      await deleteRecurringExpenseUseCase(id);
    } catch (e) {
      debugPrint('RecurringExpenseCubit deleteRecurringExpense error: $e');
      final rolledBack = List<RecurringExpenseEntity>.from(list)..add(toDelete);
      emit(RecurringExpenseLoaded(
        allRecurringExpenses: rolledBack,
        filteredRecurringExpenses: _applyFilters(rolledBack, existing: prev),
        monthlyTotal: _monthlyTotal(rolledBack),
        selectedCategory: prev?.selectedCategory,
        selectedStatus: prev?.selectedStatus,
        selectedFrequency: prev?.selectedFrequency,
        lastError: _messageFromError(e),
      ));
    }
  }

  Future<void> toggleRecurringExpense(String id, bool isActive) async {
    final list = state.allRecurringExpenses;
    final entity = list.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Recurring expense not found: $id'),
    );
    await updateRecurringExpense(entity.copyWith(isActive: isActive));
  }

  void filterByCategory(String? category) {
    final s = state;
    if (s is! RecurringExpenseLoaded) return;
    final loaded = s;
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: loaded.allRecurringExpenses,
      filteredRecurringExpenses: _applyFilters(
        loaded.allRecurringExpenses,
        category: category,
        status: loaded.selectedStatus,
        frequency: loaded.selectedFrequency,
      ),
      monthlyTotal: loaded.monthlyTotal,
      selectedCategory: category,
      selectedStatus: loaded.selectedStatus,
      selectedFrequency: loaded.selectedFrequency,
    ));
  }

  void filterByStatus(bool? isActive) {
    final s = state;
    if (s is! RecurringExpenseLoaded) return;
    final loaded = s;
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: loaded.allRecurringExpenses,
      filteredRecurringExpenses: _applyFilters(
        loaded.allRecurringExpenses,
        category: loaded.selectedCategory,
        status: isActive,
        frequency: loaded.selectedFrequency,
      ),
      monthlyTotal: loaded.monthlyTotal,
      selectedCategory: loaded.selectedCategory,
      selectedStatus: isActive,
      selectedFrequency: loaded.selectedFrequency,
    ));
  }

  void filterByFrequency(RecurrenceType? frequency) {
    final s = state;
    if (s is! RecurringExpenseLoaded) return;
    final loaded = s;
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: loaded.allRecurringExpenses,
      filteredRecurringExpenses: _applyFilters(
        loaded.allRecurringExpenses,
        category: loaded.selectedCategory,
        status: loaded.selectedStatus,
        frequency: frequency,
      ),
      monthlyTotal: loaded.monthlyTotal,
      selectedCategory: loaded.selectedCategory,
      selectedStatus: loaded.selectedStatus,
      selectedFrequency: frequency,
    ));
  }

  void clearFilters() {
    final s = state;
    if (s is! RecurringExpenseLoaded) return;
    emit(RecurringExpenseLoaded(
      allRecurringExpenses: s.allRecurringExpenses,
      filteredRecurringExpenses: s.allRecurringExpenses,
      monthlyTotal: s.monthlyTotal,
    ));
  }

  /// Enable reminder for a recurring expense (e.g. after user toggles on).
  Future<void> enableReminder(String id) async {
    try {
      await enableReminderUseCase(id);
    } catch (e) {
      debugPrint('RecurringExpenseCubit enableReminder error: $e');
    }
  }

  /// Disable reminder for a recurring expense (e.g. after user toggles off).
  Future<void> disableReminder(String id) async {
    try {
      await disableReminderUseCase(id);
    } catch (e) {
      debugPrint('RecurringExpenseCubit disableReminder error: $e');
    }
  }

  List<RecurringExpenseEntity> _applyFilters(
    List<RecurringExpenseEntity> expenses, {
    String? category,
    bool? status,
    RecurrenceType? frequency,
    RecurringExpenseLoaded? existing,
  }) {
    var filtered = List<RecurringExpenseEntity>.from(expenses);
    final c = category ?? existing?.selectedCategory;
    final s = status ?? existing?.selectedStatus;
    final f = frequency ?? existing?.selectedFrequency;
    if (c != null) filtered = filtered.where((e) => e.category == c).toList();
    if (s != null) filtered = filtered.where((e) => e.isActive == s).toList();
    if (f != null) filtered = filtered.where((e) => e.recurrenceType == f).toList();
    return filtered;
  }
}
