import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';

class ProjectState extends Equatable {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final bool isLoading;
  final String? error;
  final Project? selectedProject;
  final String? searchQuery;
  final ProjectStatus? selectedStatus;

  const ProjectState({
    this.projects = const [],
    this.filteredProjects = const [],
    this.isLoading = false,
    this.error,
    this.selectedProject,
    this.searchQuery,
    this.selectedStatus,
  });

  @override
  List<Object?> get props => [
    projects,
    filteredProjects,
    isLoading,
    error,
    selectedProject,
    searchQuery,
    selectedStatus,
  ];

  ProjectState copyWith({
    List<Project>? projects,
    List<Project>? filteredProjects,
    bool? isLoading,
    String? error,
    Project? selectedProject,
    String? searchQuery,
    ProjectStatus? selectedStatus,
    bool clearError = false,
    bool clearSelectedProject = false,
    bool clearSearchQuery = false,
    bool clearSelectedStatus = false,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedProject:
          clearSelectedProject
              ? null
              : (selectedProject ?? this.selectedProject),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }

  /// Whether any filters are currently active
  bool get hasActiveFilters => searchQuery != null || selectedStatus != null;
}
