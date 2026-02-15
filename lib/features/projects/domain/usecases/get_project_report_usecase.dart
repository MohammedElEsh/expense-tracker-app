import 'package:expense_tracker/features/projects/domain/entities/project_report_entity.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class GetProjectReportUseCase {
  final ProjectRepository repository;

  GetProjectReportUseCase(this.repository);

  Future<ProjectReportEntity> call(String projectId) =>
      repository.getProjectReport(projectId);
}
