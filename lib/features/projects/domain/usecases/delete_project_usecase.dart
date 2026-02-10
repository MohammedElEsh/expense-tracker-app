import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

/// Use case for deleting a project.
///
/// Permanently removes a project by its ID. Only available in business mode.
class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes the [projectId] of the project to delete.
  Future<void> call(String projectId) {
    return repository.deleteProject(projectId);
  }
}
