// Statistics Feature - Cubit
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_state.dart';

/// Statistics Cubit for managing time period selections
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit() : super(StatisticsState());

  /// Change the active statistics tab (monthly, yearly, weekly, etc.)
  void changeTab(int index) {
    debugPrint('📊 StatisticsCubit: Changing tab to $index');
    emit(state.copyWith(selectedTabIndex: index));
  }

  /// Change the selected year for statistics
  void changeYear(int year) {
    debugPrint('📊 StatisticsCubit: Changing year to $year');
    emit(state.copyWith(selectedYear: year));
  }

  /// Change the selected month for statistics
  void changeMonth(int month) {
    debugPrint('📊 StatisticsCubit: Changing month to $month');
    emit(state.copyWith(selectedMonth: month));
  }

  /// Navigate to the previous month, adjusting year if needed
  void navigateToPreviousMonth() {
    int newMonth = state.selectedMonth - 1;
    int newYear = state.selectedYear;

    if (newMonth < 1) {
      newMonth = 12;
      newYear -= 1;
    }

    debugPrint(
      '📊 StatisticsCubit: Navigating to previous month: $newYear-$newMonth',
    );
    emit(state.copyWith(selectedMonth: newMonth, selectedYear: newYear));
  }

  /// Navigate to the next month, adjusting year if needed
  void navigateToNextMonth() {
    int newMonth = state.selectedMonth + 1;
    int newYear = state.selectedYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear += 1;
    }

    debugPrint(
      '📊 StatisticsCubit: Navigating to next month: $newYear-$newMonth',
    );
    emit(state.copyWith(selectedMonth: newMonth, selectedYear: newYear));
  }
}
