import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_period.dart';
import 'package:expense_tracker/features/statistics/domain/repositories/statistics_repository.dart';

/// Use case: get aggregated statistics for a period.
/// Delegates to [StatisticsRepository]; no business logic in UI/Cubit.
class GetStatisticsUseCase {
  final StatisticsRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<StatisticsEntity> call({
    required StatisticsPeriod period,
    required int year,
    required int month,
  }) {
    return repository.getStatistics(period: period, year: year, month: month);
  }
}
