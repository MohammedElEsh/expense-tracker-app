import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_report_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_report_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_statistics_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final GetProjectByIdUseCase getProjectByIdUseCase;
  final CreateProjectUseCase createProjectUseCase;
  final UpdateProjectUseCase updateProjectUseCase;
  final DeleteProjectUseCase deleteProjectUseCase;
  final GetProjectReportUseCase getProjectReportUseCase;
  final GetProjectsStatisticsUseCase getProjectsStatisticsUseCase;

  ProjectCubit({
    required this.getProjectsUseCase,
    required this.getProjectByIdUseCase,
    required this.createProjectUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
    required this.getProjectReportUseCase,
    required this.getProjectsStatisticsUseCase,
  }) : super(const ProjectInitial());

  static String _messageFromError(Object error) {
    final s = error.toString();
    if (s.contains('NetworkException') || s.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    if (s.contains('ServerException')) return 'Server error. Please try again later.';
    if (s.contains('UnauthorizedException') || s.contains('401')) {
      return 'Authentication failed. Please log in again.';
    }
    if (s.contains('ValidationException')) return s.replaceAll('Exception: ', '');
    return s.replaceAll('Exception: ', '');
  }

  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (state is ProjectLoading) return;
    emit(const ProjectLoading());
    try {
      final projects = await getProjectsUseCase(forceRefresh: forceRefresh);
      Map<String, dynamic>? stats;
      try {
        stats = await getProjectsStatisticsUseCase();
      } catch (_) {}
      final filtered = _applyFilters(projects);
      emit(ProjectLoaded(
        projects: projects,
        filteredProjects: filtered,
        statistics: stats,
      ));
    } catch (e) {
      debugPrint('ProjectCubit loadProjects error: $e');
      emit(ProjectError(_messageFromError(e)));
    }
  }

  Future<void> createProject(ProjectEntity project) async {
    if (state is ProjectLoading) return;
    final prev = state is ProjectLoaded ? state as ProjectLoaded : null;
    emit(const ProjectLoading());
    try {
      final created = await createProjectUseCase(project);
      final list = prev?.projects ?? <ProjectEntity>[];
      final updated = List<ProjectEntity>.from(list)..add(created);
      final filtered = _applyFilters(updated, existingState: prev);
      emit(ProjectLoaded(
        projects: updated,
        filteredProjects: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedStatus: prev?.selectedStatus,
      ));
    } catch (e) {
      debugPrint('ProjectCubit createProject error: $e');
      emit(ProjectError(_messageFromError(e)));
    }
  }

  Future<void> updateProject(String projectId, ProjectEntity project) async {
    if (state is ProjectLoading) return;
    final prev = state is ProjectLoaded ? state as ProjectLoaded : null;
    emit(const ProjectLoading());
    try {
      final updatedProject = await updateProjectUseCase(project);
      final list = prev?.projects ?? <ProjectEntity>[];
      final updated = list.map((p) => p.id == projectId ? updatedProject : p).toList();
      final filtered = _applyFilters(updated, existingState: prev);
      final selected = prev?.selectedProject?.id == projectId ? updatedProject : prev?.selectedProject;
      emit(ProjectLoaded(
        projects: updated,
        filteredProjects: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedStatus: prev?.selectedStatus,
        selectedProject: selected,
      ));
    } catch (e) {
      debugPrint('ProjectCubit updateProject error: $e');
      emit(ProjectError(_messageFromError(e)));
    }
  }

  Future<void> deleteProject(String projectId) async {
    if (state is ProjectLoading) return;
    final prev = state is ProjectLoaded ? state as ProjectLoaded : null;
    emit(const ProjectLoading());
    try {
      await deleteProjectUseCase(projectId);
      final list = prev?.projects ?? <ProjectEntity>[];
      final updated = list.where((p) => p.id != projectId).toList();
      final filtered = _applyFilters(updated, existingState: prev);
      final clearSelected = prev?.selectedProject?.id == projectId;
      emit(ProjectLoaded(
        projects: updated,
        filteredProjects: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedStatus: prev?.selectedStatus,
        selectedProject: clearSelected ? null : prev?.selectedProject,
      ));
    } catch (e) {
      debugPrint('ProjectCubit deleteProject error: $e');
      emit(ProjectError(_messageFromError(e)));
    }
  }

  void selectProject(ProjectEntity? project) {
    final s = state;
    if (s is! ProjectLoaded) return;
    emit(ProjectLoaded(
      projects: s.projects,
      filteredProjects: s.filteredProjects,
      statistics: s.statistics,
      searchQuery: s.searchQuery,
      selectedStatus: s.selectedStatus,
      selectedProject: project,
    ));
  }

  void searchProjects(String query) {
    final s = state;
    if (s is! ProjectLoaded) return;
    final filtered = _applyFilters(s.projects, searchOverride: query, existingState: s);
    emit(ProjectLoaded(
      projects: s.projects,
      filteredProjects: filtered,
      statistics: s.statistics,
      searchQuery: query.isEmpty ? null : query,
      selectedStatus: s.selectedStatus,
      selectedProject: s.selectedProject,
    ));
  }

  void filterByStatus(ProjectStatus? status) {
    final s = state;
    if (s is! ProjectLoaded) return;
    final filtered = _applyFilters(s.projects, statusOverride: status, existingState: s);
    emit(ProjectLoaded(
      projects: s.projects,
      filteredProjects: filtered,
      statistics: s.statistics,
      searchQuery: s.searchQuery,
      selectedStatus: status,
      selectedProject: s.selectedProject,
    ));
  }

  void clearFilters() {
    final s = state;
    if (s is! ProjectLoaded) return;
    emit(ProjectLoaded(
      projects: s.projects,
      filteredProjects: s.projects,
      statistics: s.statistics,
      selectedProject: s.selectedProject,
    ));
  }

  Future<ProjectEntity?> getProjectById(String projectId) async {
    return getProjectByIdUseCase(projectId);
  }

  Future<ProjectReportEntity> getProjectReport(String projectId) async {
    return getProjectReportUseCase(projectId);
  }

  List<ProjectEntity> _applyFilters(
    List<ProjectEntity> projects, {
    String? searchOverride,
    ProjectStatus? statusOverride,
    ProjectLoaded? existingState,
  }) {
    var filtered = List<ProjectEntity>.from(projects);
    final loaded = existingState;

    final query = searchOverride ?? loaded?.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            (p.description?.toLowerCase().contains(lower) ?? false) ||
            (p.clientName?.toLowerCase().contains(lower) ?? false) ||
            (p.managerName?.toLowerCase().contains(lower) ?? false);
      }).toList();
    }

    final status = statusOverride ?? loaded?.selectedStatus;
    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    return filtered;
  }
}
