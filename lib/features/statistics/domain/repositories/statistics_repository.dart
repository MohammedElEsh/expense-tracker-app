import 'package:expense_tracker/features/statistics/domain/entities/statistics_entity.dart';
import 'package:expense_tracker/features/statistics/domain/entities/statistics_period.dart';

/// Abstract repository for statistics.
/// Aggregates data from expenses/budgets and maps to [StatisticsEntity].
abstract class StatisticsRepository {
  /// Get statistics for the given [period], [year], and [month].
  /// [month] is used for monthly/yearly; for weekly, current week is derived.
  Future<StatisticsEntity> getStatistics({
    required StatisticsPeriod period,
    required int year,
    required int month,
  });
}
