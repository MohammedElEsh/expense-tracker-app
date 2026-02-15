import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_report_entity.dart';

/// Repository interface for project operations.
abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects({bool forceRefresh = false});

  Future<ProjectEntity?> getProjectById(String id);

  Future<ProjectEntity> createProject(ProjectEntity project);

  Future<ProjectEntity> updateProject(ProjectEntity project);

  Future<void> deleteProject(String id);

  Future<ProjectReportEntity> getProjectReport(String projectId);

  Future<Map<String, dynamic>> getProjectsStatistics();

  void clearCache();
}
