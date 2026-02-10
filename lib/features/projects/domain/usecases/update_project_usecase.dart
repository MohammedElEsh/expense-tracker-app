import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

/// Use case for updating an existing project.
///
/// Updates project fields such as name, budget, status, timeline, etc.
class UpdateProjectUseCase {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes the [projectId] and the updated [Project] object.
  /// Returns the updated [Project] from the server.
  Future<Project> call(String projectId, Project project) {
    return repository.updateProject(projectId, project);
  }
}
