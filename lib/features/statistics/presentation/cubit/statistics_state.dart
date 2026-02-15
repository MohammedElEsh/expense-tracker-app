import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_period.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_tab.dart';

class StatisticsState extends Equatable {
  final StatisticsPeriod period;
  final StatisticsTab tab;
  final int selectedTabIndex;
  final int selectedYear;
  final int selectedMonth;
  final bool isLoading;
  final String? error;
  final StatisticsEntity? statistics;

  StatisticsState({
    this.period = StatisticsPeriod.monthly,
    this.tab = StatisticsTab.expenses,
    this.selectedTabIndex = 0,
    int? selectedYear,
    int? selectedMonth,
    this.isLoading = false,
    this.error,
    this.statistics,
  })  : selectedYear = selectedYear ?? DateTime.now().year,
        selectedMonth = selectedMonth ?? DateTime.now().month;

  @override
  List<Object?> get props => [
        period,
        tab,
        selectedTabIndex,
        selectedYear,
        selectedMonth,
        isLoading,
        error,
        statistics,
      ];

  StatisticsState copyWith({
    StatisticsPeriod? period,
    StatisticsTab? tab,
    int? selectedTabIndex,
    int? selectedYear,
    int? selectedMonth,
    bool? isLoading,
    String? error,
    StatisticsEntity? statistics,
    bool clearError = false,
  }) {
    return StatisticsState(
      period: period ?? this.period,
      tab: tab ?? this.tab,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statistics: statistics ?? this.statistics,
    );
  }
}
