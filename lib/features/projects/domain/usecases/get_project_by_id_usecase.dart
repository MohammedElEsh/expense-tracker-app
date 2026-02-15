import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class GetProjectByIdUseCase {
  final ProjectRepository repository;

  GetProjectByIdUseCase(this.repository);

  Future<ProjectEntity?> call(String id) => repository.getProjectById(id);
}
