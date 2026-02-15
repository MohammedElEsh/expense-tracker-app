import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';

sealed class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

final class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

final class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

final class ProjectLoaded extends ProjectState {
  final List<ProjectEntity> projects;
  final List<ProjectEntity> filteredProjects;
  final Map<String, dynamic>? statistics;
  final String? searchQuery;
  final ProjectStatus? selectedStatus;
  final ProjectEntity? selectedProject;

  const ProjectLoaded({
    required this.projects,
    required this.filteredProjects,
    this.statistics,
    this.searchQuery,
    this.selectedStatus,
    this.selectedProject,
  });

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) || selectedStatus != null;

  @override
  List<Object?> get props => [
        projects,
        filteredProjects,
        statistics,
        searchQuery,
        selectedStatus,
        selectedProject,
      ];
}

final class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Convenience extension for UI (avoids casting in every builder).
extension ProjectStateX on ProjectState {
  bool get isLoading => this is ProjectLoading;
  List<ProjectEntity> get projects =>
      this is ProjectLoaded ? (this as ProjectLoaded).projects : [];
  List<ProjectEntity> get filteredProjects =>
      this is ProjectLoaded ? (this as ProjectLoaded).filteredProjects : [];
  String? get searchQuery =>
      this is ProjectLoaded ? (this as ProjectLoaded).searchQuery : null;
  ProjectStatus? get selectedStatus =>
      this is ProjectLoaded ? (this as ProjectLoaded).selectedStatus : null;
  Map<String, dynamic>? get statistics =>
      this is ProjectLoaded ? (this as ProjectLoaded).statistics : null;
}
