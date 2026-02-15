import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expense_by_id_usecase.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_detail_state.dart';

/// Cubit for a single expense detail screen.
/// Handles refresh via [GetExpenseByIdUseCase]; UI must not call API directly.
class ExpenseDetailCubit extends Cubit<ExpenseDetailState> {
  ExpenseDetailCubit({
    required GetExpenseByIdUseCase getExpenseByIdUseCase,
    Expense? initialExpense,
  })  : _getExpenseById = getExpenseByIdUseCase,
        super(ExpenseDetailState(expense: initialExpense));

  final GetExpenseByIdUseCase _getExpenseById;

  void setInitialExpense(Expense expense) {
    emit(state.copyWith(expense: expense, clearError: true));
  }

  /// Refresh expense from API via use case. Call this instead of calling API/service from UI.
  Future<void> refreshExpense() async {
    final current = state.expense;
    if (current == null) return;
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true, clearError: true));

    try {
      debugPrint('🔄 ExpenseDetailCubit - Refreshing expense: ${current.id}');
      final updated = await _getExpenseById(current.id);
      debugPrint('✅ ExpenseDetailCubit - Expense refreshed: ${updated.id}');
      if (state.expense != null) {
        emit(state.copyWith(expense: updated, isRefreshing: false));
      }
    } catch (e) {
      debugPrint('❌ ExpenseDetailCubit - Error refreshing expense: $e');
      String errorMessage = 'Failed to refresh expense';
      if (e.toString().contains('NetworkException') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage = 'Failed to refresh expense: ${e.toString().replaceAll('Exception: ', '')}';
      }
      emit(state.copyWith(isRefreshing: false, error: errorMessage));
    }
  }
}
