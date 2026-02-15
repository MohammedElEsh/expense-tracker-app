import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/get_statistics_usecase.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_period.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_tab.dart';

/// Statistics Cubit: holds UI state and aggregated statistics from use cases only.
/// No direct service/API/Cubit access.
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({
    required GetStatisticsUseCase getStatisticsUseCase,
  })  : _getStatisticsUseCase = getStatisticsUseCase,
        super(StatisticsState());

  final GetStatisticsUseCase _getStatisticsUseCase;

  StatisticsPeriod get selectedPeriod => state.period;
  StatisticsTab get selectedTab => state.tab;

  void selectPeriod(StatisticsPeriod period) {
    emit(state.copyWith(period: period));
    loadStatistics();
  }

  void selectTab(StatisticsTab tab) {
    emit(state.copyWith(tab: tab));
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  void changeYear(int year) {
    emit(state.copyWith(selectedYear: year));
    loadStatistics();
  }

  void changeMonth(int month) {
    emit(state.copyWith(selectedMonth: month));
    loadStatistics();
  }

  void navigateToPreviousMonth() {
    int newMonth = state.selectedMonth - 1;
    int newYear = state.selectedYear;
    if (newMonth < 1) {
      newMonth = 12;
      newYear -= 1;
    }
    emit(state.copyWith(selectedMonth: newMonth, selectedYear: newYear));
    loadStatistics();
  }

  void navigateToNextMonth() {
    int newMonth = state.selectedMonth + 1;
    int newYear = state.selectedYear;
    if (newMonth > 12) {
      newMonth = 1;
      newYear += 1;
    }
    emit(state.copyWith(selectedMonth: newMonth, selectedYear: newYear));
    loadStatistics();
  }

  /// Load statistics for current period/year/month via use case.
  Future<void> loadStatistics() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entity = await _getStatisticsUseCase(
        period: state.period,
        year: state.selectedYear,
        month: state.selectedMonth,
      );
      emit(state.copyWith(
        statistics: entity,
        isLoading: false,
        clearError: true,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        clearError: false,
      ));
      // ignore: avoid_print
      print('StatisticsCubit.loadStatistics error: $e $st');
    }
  }
}
