import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/projects/data/datasources/project_api_service.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectApiService _projectApiService;

  ProjectCubit({ProjectApiService? projectApiService})
    : _projectApiService = projectApiService ?? serviceLocator.projectService,
      super(const ProjectState());

  /// Load all projects from API
  Future<void> loadProjects({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🔄 Loading projects...');
      final response = await _projectApiService.getAllProjects(
        forceRefresh: forceRefresh,
      );

      debugPrint('✅ Loaded ${response.projects.length} projects');

      final filteredProjects = _applyFilters(response.projects);

      emit(
        state.copyWith(
          projects: response.projects,
          filteredProjects: filteredProjects,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error loading projects: $error');
      String errorMessage = 'Failed to load projects';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (error.toString().contains('UnauthorizedException') ||
          error.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else {
        errorMessage =
            'Failed to load projects: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Create a new project
  Future<void> createProject(Project project) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('➕ Creating project: ${project.name}');
      final createdProject = await _projectApiService.createProject(project);

      debugPrint('✅ Project created: ${createdProject.id}');

      final updatedProjects = List<Project>.from(state.projects)
        ..add(createdProject);
      final filteredProjects = _applyFilters(updatedProjects);

      emit(
        state.copyWith(
          projects: updatedProjects,
          filteredProjects: filteredProjects,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error creating project: $error');
      String errorMessage = 'Failed to create project';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to create project: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Update an existing project
  Future<void> updateProject(String projectId, Project project) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('✏️ Updating project: $projectId');
      final updatedProject = await _projectApiService.updateProject(
        projectId,
        project,
      );

      debugPrint('✅ Project updated: ${updatedProject.id}');

      final updatedProjects = List<Project>.from(state.projects);
      final index = updatedProjects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        updatedProjects[index] = updatedProject;
      }
      final filteredProjects = _applyFilters(updatedProjects);

      // Update selectedProject if it was the one being edited
      final updatedSelectedProject =
          state.selectedProject?.id == projectId
              ? updatedProject
              : state.selectedProject;

      emit(
        state.copyWith(
          projects: updatedProjects,
          filteredProjects: filteredProjects,
          selectedProject: updatedSelectedProject,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error updating project: $error');
      String errorMessage = 'Failed to update project';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to update project: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Delete a project by ID
  Future<void> deleteProject(String projectId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🗑️ Deleting project: $projectId');
      await _projectApiService.deleteProject(projectId);

      debugPrint('✅ Project deleted: $projectId');

      final updatedProjects = List<Project>.from(state.projects)
        ..removeWhere((p) => p.id == projectId);
      final filteredProjects = _applyFilters(updatedProjects);

      // Clear selectedProject if it was the one being deleted
      final clearSelected = state.selectedProject?.id == projectId;

      emit(
        state.copyWith(
          projects: updatedProjects,
          filteredProjects: filteredProjects,
          isLoading: false,
          clearSelectedProject: clearSelected,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error deleting project: $error');
      String errorMessage = 'Failed to delete project';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to delete project: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Select or deselect a project
  void selectProject(Project? project) {
    if (project == null) {
      emit(state.copyWith(clearSelectedProject: true));
    } else {
      emit(state.copyWith(selectedProject: project));
    }
  }

  /// Search projects by query string
  void searchProjects(String query) {
    emit(
      state.copyWith(
        searchQuery: query.isEmpty ? null : query,
        clearSearchQuery: query.isEmpty,
        filteredProjects: _applyFilters(
          state.projects,
          searchOverride: query.isEmpty ? null : query,
        ),
      ),
    );
  }

  /// Filter projects by status
  void filterByStatus(ProjectStatus? status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        clearSelectedStatus: status == null,
        filteredProjects: _applyFilters(
          state.projects,
          statusOverride: status,
          clearStatus: status == null,
        ),
      ),
    );
  }

  /// Clear all active filters
  void clearFilters() {
    emit(
      state.copyWith(
        clearSearchQuery: true,
        clearSelectedStatus: true,
        filteredProjects: state.projects,
      ),
    );
  }

  /// Apply all active filters to the projects list
  List<Project> _applyFilters(
    List<Project> projects, {
    String? searchOverride,
    ProjectStatus? statusOverride,
    bool clearStatus = false,
  }) {
    var filtered = List<Project>.from(projects);

    // Search filter
    final query = searchOverride ?? state.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered =
          filtered.where((project) {
            return project.name.toLowerCase().contains(lowerQuery) ||
                (project.description?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (project.clientName?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (project.managerName?.toLowerCase().contains(lowerQuery) ??
                    false);
          }).toList();
    }

    // Status filter
    final status =
        clearStatus ? null : (statusOverride ?? state.selectedStatus);
    if (status != null) {
      filtered = filtered.where((project) => project.status == status).toList();
    }

    return filtered;
  }
}
