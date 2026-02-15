import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<void> call(String id) => repository.deleteProject(id);
}
