import 'package:expense_tracker/features/projects/data/datasources/project_api_service.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';

/// Use case for retrieving projects.
///
/// Fetches a paginated and optionally filtered list of projects.
class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Returns a [ProjectsResponse] containing the list of projects
  /// and pagination metadata.
  /// Optionally filter by [status], paginate with [page] and [limit],
  /// and bypass cache with [forceRefresh].
  Future<ProjectsResponse> call({
    String? status,
    int? page,
    int? limit,
    bool forceRefresh = false,
  }) {
    return repository.getAllProjects(
      status: status,
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
