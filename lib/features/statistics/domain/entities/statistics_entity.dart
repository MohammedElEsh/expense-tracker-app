import 'package:equatable/equatable.dart';

/// Domain entity for aggregated statistics.
/// Holds totals, category breakdown, optional trend data and budget summary.
class StatisticsEntity extends Equatable {
  final double totalAmount;
  final int expenseCount;
  final Map<String, double> categoryTotals;
  /// Last 6 months totals (oldest to newest) for trend charts.
  final List<double> last6MonthsTotals;
  /// Number of budgets set for the selected month (for budget message card).
  final int budgetCountForMonth;
  /// Yearly view: total per month (1..12).
  final Map<int, double> monthlyBreakdownForYear;
  /// For business tab: previous period total (e.g. last month).
  final double previousPeriodTotal;
  /// Weekly: total per day (0=Monday .. 6=Sunday), length 7.
  final List<double> dailyTotalsForWeek;

  const StatisticsEntity({
    required this.totalAmount,
    required this.expenseCount,
    required this.categoryTotals,
    this.last6MonthsTotals = const [],
    this.budgetCountForMonth = 0,
    this.monthlyBreakdownForYear = const {},
    this.previousPeriodTotal = 0.0,
    this.dailyTotalsForWeek = const [],
  });

  double get changePercentage =>
      previousPeriodTotal > 0
          ? ((totalAmount - previousPeriodTotal) / previousPeriodTotal * 100)
          : 0.0;

  @override
  List<Object?> get props => [
        totalAmount,
        expenseCount,
        categoryTotals,
        last6MonthsTotals,
        budgetCountForMonth,
        monthlyBreakdownForYear,
        previousPeriodTotal,
        dailyTotalsForWeek,
      ];
}
