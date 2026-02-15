import 'package:expense_tracker/features/statistics/domain/entities/statistics_period.dart';
import 'package:expense_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Use case: calculate trend data (e.g. last 6 months) for charts.
/// Delegates to [StatisticsRepository.getStatistics] and returns trend series.
class CalculateTrendsUseCase {
  final StatisticsRepository repository;

  CalculateTrendsUseCase(this.repository);

  Future<List<double>> call({
    required StatisticsPeriod period,
    required int year,
    required int month,
  }) async {
    final entity = await repository.getStatistics(
      period: period,
      year: year,
      month: month,
    );
    return entity.last6MonthsTotals;
  }
}
