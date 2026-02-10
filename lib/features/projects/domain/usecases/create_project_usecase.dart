import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

/// Use case for creating a new project.
///
/// Only available in business mode. Creates a project with budget,
/// timeline, and assignment details.
class CreateProjectUseCase {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes a [Project] object with the desired fields and returns
  /// the newly created [Project] with server-assigned ID and timestamps.
  Future<Project> call(Project project) {
    return repository.createProject(project);
  }
}
