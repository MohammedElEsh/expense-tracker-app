// Expense Filter - BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'expense_filter_event.dart';
import 'expense_filter_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseFilterBloc extends Bloc<ExpenseFilterEvent, ExpenseFilterState> {
  final List<Expense> allExpenses;

  ExpenseFilterBloc({required this.allExpenses})
    : super(
        ExpenseFilterState(
          filteredExpenses: allExpenses,
          totalCount: allExpenses.length,
          totalAmount: allExpenses.fold(0.0, (sum, e) => sum + e.amount),
        ),
      ) {
    on<ChangeSearchQueryEvent>(_onChangeSearchQuery);
    on<ChangeCategoryFilterEvent>(_onChangeCategoryFilter);
    on<ChangeDateRangeFilterEvent>(_onChangeDateRangeFilter);
    on<ChangeAmountRangeFilterEvent>(_onChangeAmountRangeFilter);
    on<ToggleFilterVisibilityEvent>(_onToggleFilterVisibility);
    on<ResetFiltersEvent>(_onResetFilters);
    on<ApplyFiltersEvent>(_onApplyFilters);
  }

  void _onChangeSearchQuery(
    ChangeSearchQueryEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onChangeCategoryFilter(
    ChangeCategoryFilterEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
      ),
    );
    _applyFilters(emit);
  }

  void _onChangeDateRangeFilter(
    ChangeDateRangeFilterEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    emit(
      state.copyWith(
        dateRange: event.dateRange,
        clearDateRange: event.dateRange == null,
      ),
    );
    _applyFilters(emit);
  }

  void _onChangeAmountRangeFilter(
    ChangeAmountRangeFilterEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    emit(
      state.copyWith(
        minAmount: event.minAmount,
        maxAmount: event.maxAmount,
        clearMinAmount: event.minAmount == null,
        clearMaxAmount: event.maxAmount == null,
      ),
    );
    _applyFilters(emit);
  }

  void _onToggleFilterVisibility(
    ToggleFilterVisibilityEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    final newVisibility = !state.isFilterVisible;
    debugPrint('🔍 تبديل رؤية الفلاتر: $newVisibility');
    emit(state.copyWith(isFilterVisible: newVisibility));
  }

  void _onResetFilters(
    ResetFiltersEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    debugPrint('🔄 إعادة تعيين جميع الفلاتر');
    emit(
      ExpenseFilterState(
        filteredExpenses: allExpenses,
        totalCount: allExpenses.length,
        totalAmount: allExpenses.fold(0.0, (sum, e) => sum + e.amount),
        isFilterVisible: state.isFilterVisible,
      ),
    );
  }

  void _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<ExpenseFilterState> emit,
  ) {
    _applyFilters(emit);
  }

  // منطق تطبيق الفلاتر
  void _applyFilters(Emitter<ExpenseFilterState> emit) {
    var filtered = List<Expense>.from(allExpenses);

    // فلترة حسب البحث
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered =
          filtered.where((expense) {
            return expense.notes.toLowerCase().contains(query) ||
                expense.category.toLowerCase().contains(query) ||
                expense.amount.toString().contains(query);
          }).toList();
    }

    // فلترة حسب الفئة
    if (state.selectedCategory != null) {
      filtered =
          filtered
              .where((expense) => expense.category == state.selectedCategory)
              .toList();
    }

    // فلترة حسب التاريخ
    if (state.dateRange != null) {
      filtered =
          filtered.where((expense) {
            return expense.date.isAfter(
                  state.dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(
                  state.dateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
    }

    // فلترة حسب المبلغ
    if (state.minAmount != null) {
      filtered =
          filtered
              .where((expense) => expense.amount >= state.minAmount!)
              .toList();
    }
    if (state.maxAmount != null) {
      filtered =
          filtered
              .where((expense) => expense.amount <= state.maxAmount!)
              .toList();
    }

    // حساب الإحصائيات
    final totalAmount = filtered.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    debugPrint(
      '🔍 تطبيق الفلاتر: ${filtered.length} من ${allExpenses.length} مصروف',
    );

    emit(
      state.copyWith(
        filteredExpenses: filtered,
        totalCount: filtered.length,
        totalAmount: totalAmount,
      ),
    );
  }
}
