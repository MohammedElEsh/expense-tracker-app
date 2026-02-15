import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_period.dart';
import 'package:expense_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Maps data from expenses and budgets (via use cases) to [StatisticsEntity].
/// No direct API/service calls; dependencies injected.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final GetExpensesUseCase getExpensesUseCase;
  final GetBudgetsUseCase getBudgetsUseCase;

  StatisticsRepositoryImpl({
    required this.getExpensesUseCase,
    required this.getBudgetsUseCase,
  });

  @override
  Future<StatisticsEntity> getStatistics({
    required StatisticsPeriod period,
    required int year,
    required int month,
  }) async {
    final startEnd = _dateRangeFor(period, year, month);
    final startDate = startEnd.$1;
    final endDate = startEnd.$2;

    final expenses = await getExpensesUseCase(
      startDate: startDate,
      endDate: endDate,
    );

    final totalAmount =
        expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final categoryTotals = <String, double>{};
    for (final e in expenses) {
      final key = e.displayCategory ?? e.category;
      categoryTotals[key] = (categoryTotals[key] ?? 0) + e.amount;
    }

    List<double> last6MonthsTotals = [];
    if (period == StatisticsPeriod.monthly) {
      last6MonthsTotals = await _last6MonthsTotals(year, month);
    }

    int budgetCountForMonth = 0;
    if (period == StatisticsPeriod.monthly || period == StatisticsPeriod.yearly) {
      final budgets = await getBudgetsUseCase(month: month, year: year);
      budgetCountForMonth = budgets.length;
    }

    Map<int, double> monthlyBreakdownForYear = {};
    if (period == StatisticsPeriod.yearly) {
      monthlyBreakdownForYear = await _monthlyBreakdownForYear(year);
    }

    double previousPeriodTotal = 0.0;
    if (period == StatisticsPeriod.monthly) {
      previousPeriodTotal = await _previousMonthTotal(year, month);
    }

    List<double> dailyTotalsForWeek = [];
    if (period == StatisticsPeriod.weekly) {
      dailyTotalsForWeek = _dailyTotalsFromExpenses(expenses);
    }

    return StatisticsEntity(
      totalAmount: totalAmount,
      expenseCount: expenses.length,
      categoryTotals: categoryTotals,
      last6MonthsTotals: last6MonthsTotals,
      budgetCountForMonth: budgetCountForMonth,
      monthlyBreakdownForYear: monthlyBreakdownForYear,
      previousPeriodTotal: previousPeriodTotal,
      dailyTotalsForWeek: dailyTotalsForWeek,
    );
  }

  List<double> _dailyTotalsFromExpenses(List<Expense> expenses) {
    final list = List<double>.filled(7, 0.0);
    for (final e in expenses) {
      final weekday = e.date.weekday;
      if (weekday >= 1 && weekday <= 7) {
        list[weekday - 1] += e.amount;
      }
    }
    return list;
  }

  Future<Map<int, double>> _monthlyBreakdownForYear(int year) async {
    final map = <int, double>{};
    for (int m = 1; m <= 12; m++) {
      final start = DateTime(year, m, 1);
      final end = DateTime(year, m + 1, 0);
      final list = await getExpensesUseCase(startDate: start, endDate: end);
      map[m] = list.fold<double>(0.0, (sum, e) => sum + e.amount);
    }
    return map;
  }

  Future<double> _previousMonthTotal(int year, int month) async {
    int pm = month - 1, py = year;
    if (pm < 1) {
      pm += 12;
      py -= 1;
    }
    final start = DateTime(py, pm, 1);
    final end = DateTime(py, pm + 1, 0);
    final list = await getExpensesUseCase(startDate: start, endDate: end);
    return list.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  (DateTime, DateTime) _dateRangeFor(
    StatisticsPeriod period,
    int year,
    int month,
  ) {
    switch (period) {
      case StatisticsPeriod.weekly:
        final now = DateTime.now();
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case StatisticsPeriod.monthly:
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0);
        return (start, end);
      case StatisticsPeriod.yearly:
        final start = DateTime(year, 1, 1);
        final end = DateTime(year, 12, 31);
        return (start, end);
    }
  }

  Future<List<double>> _last6MonthsTotals(int year, int month) async {
    final list = <double>[];
    for (int i = 5; i >= 0; i--) {
      int m = month - i;
      int y = year;
      while (m < 1) {
        m += 12;
        y -= 1;
      }
      final start = DateTime(y, m, 1);
      final end = DateTime(y, m + 1, 0);
      final expenses = await getExpensesUseCase(
        startDate: start,
        endDate: end,
      );
      final total =
          expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      list.add(total);
    }
    return list;
  }
}
