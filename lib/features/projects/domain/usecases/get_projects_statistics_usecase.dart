import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class GetProjectsStatisticsUseCase {
  final ProjectRepository repository;

  GetProjectsStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call() => repository.getProjectsStatistics();
}
