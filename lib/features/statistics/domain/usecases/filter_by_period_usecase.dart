import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_period.dart';
import 'package:expense_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Use case: get statistics filtered by period (week/month/year).
/// Delegates to [StatisticsRepository.getStatistics].
class FilterByPeriodUseCase {
  final StatisticsRepository repository;

  FilterByPeriodUseCase(this.repository);

  Future<StatisticsEntity> call({
    required StatisticsPeriod period,
    required int year,
    required int month,
  }) {
    return repository.getStatistics(
      period: period,
      year: year,
      month: month,
    );
  }
}
