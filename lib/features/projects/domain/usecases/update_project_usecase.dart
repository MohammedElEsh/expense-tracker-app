import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectUseCase {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  Future<ProjectEntity> call(ProjectEntity project) =>
      repository.updateProject(project);
}
