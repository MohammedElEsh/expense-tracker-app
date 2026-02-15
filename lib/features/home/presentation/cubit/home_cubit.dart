// Home Feature - Presentation Layer - Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/home/domain/usecases/calculate_total_amount_usecase.dart';
import 'package:expense_tracker/features/home/domain/usecases/filter_expenses_by_view_mode_usecase.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_state.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final LogoutUseCase _logoutUseCase;
  final FilterExpensesByViewModeUseCase _filterExpensesByViewModeUseCase;
  final CalculateTotalAmountUseCase _calculateTotalAmountUseCase;

  HomeCubit({
    required LogoutUseCase logoutUseCase,
    required FilterExpensesByViewModeUseCase filterExpensesByViewModeUseCase,
    required CalculateTotalAmountUseCase calculateTotalAmountUseCase,
  })  : _logoutUseCase = logoutUseCase,
        _filterExpensesByViewModeUseCase = filterExpensesByViewModeUseCase,
        _calculateTotalAmountUseCase = calculateTotalAmountUseCase,
        super(HomeState(selectedDate: DateTime.now()));

  void changeViewMode(String viewMode) {
    debugPrint('🏠 تغيير وضع العرض إلى: $viewMode');
    emit(state.copyWith(viewMode: viewMode));
  }

  void changeSelectedDate(DateTime selectedDate) {
    debugPrint('📅 تغيير التاريخ المحدد إلى: $selectedDate');
    emit(state.copyWith(selectedDate: selectedDate));
  }

  void toggleSearchVisibility() {
    final newVisibility = !state.isSearchVisible;
    debugPrint('🔍 تبديل رؤية البحث: $newVisibility');
    emit(state.copyWith(isSearchVisible: newVisibility));
  }

  /// Updates filtered expenses and total from use cases. Call when expenses or filters change.
  /// Only emits if filtered list or total changed to avoid unnecessary rebuilds.
  void updateDisplayData(List<Expense> allExpenses, {String? accountId}) {
    final filtered = _filterExpensesByViewModeUseCase.call(
      allExpenses: allExpenses,
      viewMode: state.viewMode,
      selectedDate: state.selectedDate,
      accountId: accountId,
    );
    final total = _calculateTotalAmountUseCase.call(filtered);
    if (_listEquals(filtered, state.filteredExpenses) && total == state.totalAmount) {
      return;
    }
    emit(state.copyWith(filteredExpenses: filtered, totalAmount: total));
  }

  static bool _listEquals(List<Expense> a, List<Expense> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> logout() async {
    try {
      debugPrint('🚪 بدء عملية تسجيل الخروج...');
      emit(state.copyWith(isLoggingOut: true, clearError: true));

      await _logoutUseCase.call();

      debugPrint('✅ تم تسجيل الخروج بنجاح');
      emit(state.copyWith(isLoggingOut: false));
    } catch (error) {
      debugPrint('❌ خطأ في تسجيل الخروج: $error');
      emit(state.copyWith(isLoggingOut: false, logoutError: error.toString()));
    }
  }
}
