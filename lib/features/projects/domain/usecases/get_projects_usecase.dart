import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<List<ProjectEntity>> call({bool forceRefresh = false}) =>
      repository.getProjects(forceRefresh: forceRefresh);
}
