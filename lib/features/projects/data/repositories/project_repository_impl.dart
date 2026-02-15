import 'package:expense_tracker/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart' as model;
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_report_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _dataSource;

  ProjectRepositoryImpl({required ProjectRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  void clearCache() => _dataSource.clearCache();

  @override
  Future<List<ProjectEntity>> getProjects({bool forceRefresh = false}) async {
    final response = await _dataSource.getAllProjects(forceRefresh: forceRefresh);
    return response.projects.map(_modelToEntity).toList();
  }

  @override
  Future<ProjectEntity?> getProjectById(String id) async {
    final p = await _dataSource.getProjectById(id);
    return p == null ? null : _modelToEntity(p);
  }

  @override
  Future<ProjectEntity> createProject(ProjectEntity project) async {
    final m = _entityToModel(project);
    final created = await _dataSource.createProject(m);
    return _modelToEntity(created);
  }

  @override
  Future<ProjectEntity> updateProject(ProjectEntity project) async {
    final m = _entityToModel(project);
    final updated = await _dataSource.updateProject(project.id, m);
    return _modelToEntity(updated);
  }

  @override
  Future<void> deleteProject(String id) => _dataSource.deleteProject(id);

  @override
  Future<ProjectReportEntity> getProjectReport(String projectId) async {
    final report = await _dataSource.getProjectReport(projectId);
    return ProjectReportEntity(
      project: _modelToEntity(report.project),
      expenses: report.expenses,
      totalExpenses: report.project.spentAmount,
      expenseCount: report.expensesCount,
      remaining: report.remaining,
      progress: report.progress,
      isOverBudget: report.isOverBudget,
    );
  }

  @override
  Future<Map<String, dynamic>> getProjectsStatistics() =>
      _dataSource.getProjectsStatistics();

  ProjectEntity _modelToEntity(model.Project p) {
    return ProjectEntity(
      id: p.id,
      name: p.name,
      description: p.description,
      status: _domainStatus(p.status),
      startDate: p.startDate,
      endDate: p.endDate,
      budget: p.budget,
      spentAmount: p.spentAmount,
      managerName: p.managerName,
      clientName: p.clientName,
      priority: p.priority,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }

  model.Project _entityToModel(ProjectEntity e) {
    return model.Project(
      id: e.id,
      name: e.name,
      description: e.description,
      status: _modelStatus(e.status),
      startDate: e.startDate,
      endDate: e.endDate,
      budget: e.budget,
      spentAmount: e.spentAmount,
      managerName: e.managerName,
      clientName: e.clientName,
      priority: e.priority,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  ProjectStatus _domainStatus(model.ProjectStatus s) {
    return ProjectStatus.values.firstWhere(
      (e) => e.name == s.name,
      orElse: () => ProjectStatus.planning,
    );
  }

  model.ProjectStatus _modelStatus(ProjectStatus s) {
    return model.ProjectStatus.values.firstWhere(
      (e) => e.name == s.name,
      orElse: () => model.ProjectStatus.planning,
    );
  }
}
