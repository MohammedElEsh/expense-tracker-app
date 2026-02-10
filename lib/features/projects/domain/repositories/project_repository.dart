import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/projects/data/datasources/project_api_service.dart';

/// Abstract repository interface for project operations.
///
/// Defines the contract for project data access. Implementations
/// handle the actual data fetching (API, local cache, etc.).
abstract class ProjectRepository {
  /// Get all projects with optional filters and pagination.
  ///
  /// Filter by [status] (e.g. 'active', 'completed').
  /// Paginate with [page] and [limit].
  /// Set [forceRefresh] to `true` to bypass cached data.
  Future<ProjectsResponse> getAllProjects({
    String? status,
    int? page,
    int? limit,
    bool forceRefresh = false,
  });

  /// Get a single project by its [projectId].
  ///
  /// Returns `null` if not found.
  Future<Project?> getProjectById(String projectId);

  /// Get a detailed project report including expenses.
  ///
  /// Returns a [ProjectReport] with project details, expenses list,
  /// remaining budget, progress, and over-budget status.
  Future<ProjectReport> getProjectReport(String projectId);

  /// Create a new project.
  ///
  /// Only available in business mode. Returns the created [Project].
  Future<Project> createProject(Project project);

  /// Update an existing project.
  ///
  /// Takes the [projectId] and the updated [Project] object.
  /// Returns the updated [Project].
  Future<Project> updateProject(String projectId, Project project);

  /// Delete a project by its [projectId].
  Future<void> deleteProject(String projectId);

  /// Clear any cached project data.
  void clearCache();
}
