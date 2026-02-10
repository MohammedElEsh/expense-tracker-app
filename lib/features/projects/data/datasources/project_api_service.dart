import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';

// =============================================================================
// PROJECT API SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Response model for project report
/// API Response Format:
/// {
///   "success": true,
///   "project": {
///     "_id": "...",
///     "name": "...",
///     "remaining": 150000,
///     "progress": 0,
///     "isOverBudget": false,
///     "expensesCount": 0,
///     ...
///   },
///   "expenses": []
/// }
class ProjectReport {
  final Project project;
  final List<Map<String, dynamic>> expenses;
  final bool success;

  // Computed properties from project data
  double get totalExpenses => project.spentAmount;
  int get expenseCount => _expensesCount;
  double get remaining => _remaining;
  double get progress => _progress;
  bool get isOverBudget => _isOverBudget;

  // Convert raw expenses to Expense objects
  List<Expense> get expenseObjects {
    try {
      return expenses.map((expenseJson) {
          return Expense.fromApiJson(expenseJson);
        }).toList()
        ..sort(
          (a, b) => b.date.compareTo(a.date),
        ); // Sort by date, newest first
    } catch (e) {
      debugPrint('❌ Error converting expenses to Expense objects: $e');
      return [];
    }
  }

  // Private fields to store values from API
  final int _expensesCount;
  final double _remaining;
  final double _progress;
  final bool _isOverBudget;

  ProjectReport({
    required this.project,
    required this.expenses,
    this.success = true,
    int? expensesCount,
    double? remaining,
    double? progress,
    bool? isOverBudget,
  }) : _expensesCount = expensesCount ?? 0,
       _remaining = remaining ?? project.remainingBudget,
       _progress = progress ?? project.spentPercentage,
       _isOverBudget = isOverBudget ?? project.isOverBudget;

  factory ProjectReport.fromJson(Map<String, dynamic> json) {
    final projectJson = json['project'] as Map<String, dynamic>? ?? {};
    final expensesList = json['expenses'] as List<dynamic>? ?? [];

    // Extract additional fields from project object
    final expensesCount = projectJson['expensesCount'] as int?;
    final remaining =
        projectJson['remaining'] != null
            ? (projectJson['remaining'] as num).toDouble()
            : null;
    final progress =
        projectJson['progress'] != null
            ? (projectJson['progress'] as num).toDouble()
            : null;
    final isOverBudget = projectJson['isOverBudget'] as bool?;

    return ProjectReport(
      project: Project.fromApiJson(projectJson),
      expenses: expensesList.map((e) => e as Map<String, dynamic>).toList(),
      success: json['success'] as bool? ?? true,
      expensesCount: expensesCount,
      remaining: remaining,
      progress: progress,
      isOverBudget: isOverBudget,
    );
  }

  /// Convert to map for easy access
  Map<String, dynamic> toMap() {
    return {
      'project': project.toApiJson(),
      'expenses': expenses,
      'totalExpenses': totalExpenses,
      'expenseCount': expenseCount,
      'remaining': remaining,
      'progress': progress,
      'isOverBudget': isOverBudget,
    };
  }
}

/// Pagination model for projects list
class ProjectsPagination {
  final int current;
  final int pages;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  ProjectsPagination({
    required this.current,
    required this.pages,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ProjectsPagination.fromJson(Map<String, dynamic> json) {
    return ProjectsPagination(
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
      total: json['total'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

/// Response model for projects list
class ProjectsResponse {
  final List<Project> projects;
  final ProjectsPagination pagination;

  ProjectsResponse({required this.projects, required this.pagination});
}

/// Remote data source for projects using REST API
/// Uses core services: ApiService
class ProjectApiService {
  final ApiService _apiService;

  // Cache for projects
  List<Project>? _cachedProjects;
  DateTime? _lastFetchTime;

  // Cache duration: 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  ProjectApiService({required ApiService apiService})
    : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_cachedProjects == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  /// Clear cached projects
  void clearCache() {
    _cachedProjects = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Project cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Create a new project
  /// POST /api/projects
  ///
  /// Request Body:
  /// {
  ///   "name": "Project Name",
  ///   "description": "Project Description",
  ///   "budget": 150000,
  ///   "startDate": "2025-12-01",
  ///   "endDate": "2026-06-01",
  ///   "clientName": "Client Name",
  ///   "managerName": "Manager Name",
  ///   "priority": 5,
  ///   "status": "active"
  /// }
  Future<Project> createProject(Project project) async {
    try {
      final currentAppMode = SettingsService.appMode;

      // Only business mode can create projects
      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Projects are only available in business mode',
        );
      }

      debugPrint('➕ Creating project: ${project.name}');

      // Build request body
      final Map<String, dynamic> requestBody = {
        'name': project.name,
        'description': project.description,
        'budget': project.budget,
        'startDate': _formatDate(project.startDate),
        'endDate':
            project.endDate != null ? _formatDate(project.endDate!) : null,
        'clientName': project.clientName,
        'managerName': project.managerName,
        'priority': project.priority,
        'status': project.status.name,
      };

      // Remove null values
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('📤 POST /api/projects');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/projects',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract project from response
        final Map<String, dynamic> projectJson;
        if (responseData.containsKey('project') &&
            responseData['project'] is Map) {
          projectJson = responseData['project'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          projectJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          projectJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing project data');
        }

        final newProject = Project.fromApiJson(projectJson);

        // Clear cache to force fresh reload
        clearCache();

        debugPrint('✅ Project created successfully: ${newProject.id}');
        return newProject;
      }

      throw ServerException(
        'Failed to create project',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating project: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to create project: $e');
    }
  }

  /// Get all projects with optional filters
  /// GET /api/projects?status={status}&page={page}&limit={limit}
  Future<ProjectsResponse> getAllProjects({
    String? status,
    int? page,
    int? limit,
    bool forceRefresh = false,
  }) async {
    try {
      final currentAppMode = SettingsService.appMode;

      // Only business mode can access projects
      if (currentAppMode != AppMode.business) {
        return ProjectsResponse(
          projects: [],
          pagination: ProjectsPagination(
            current: 1,
            pages: 1,
            total: 0,
            hasNext: false,
            hasPrev: false,
          ),
        );
      }

      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid && status == null && page == null) {
        return ProjectsResponse(
          projects: _cachedProjects!,
          pagination: ProjectsPagination(
            current: 1,
            pages: 1,
            total: _cachedProjects!.length,
            hasNext: false,
            hasPrev: false,
          ),
        );
      }

      debugPrint('🔍 Loading projects - Status: $status, Page: $page');

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiService.get(
        '/api/projects',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Parse projects
        final List<dynamic> projectsData =
            responseData['projects'] ?? responseData['data'] ?? [];
        final projects =
            projectsData
                .map(
                  (json) => Project.fromApiJson(json as Map<String, dynamic>),
                )
                .toList();

        // Parse pagination
        final paginationData =
            responseData['pagination'] as Map<String, dynamic>?;
        final pagination =
            paginationData != null
                ? ProjectsPagination.fromJson(paginationData)
                : ProjectsPagination(
                  current: 1,
                  pages: 1,
                  total: projects.length,
                  hasNext: false,
                  hasPrev: false,
                );

        // Cache if fetching all projects without filters
        if (status == null && page == null) {
          _cachedProjects = projects;
          _lastFetchTime = DateTime.now();
        }

        debugPrint('✅ Loaded ${projects.length} projects');
        return ProjectsResponse(projects: projects, pagination: pagination);
      }

      throw ServerException(
        'Failed to load projects',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading projects: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading projects: $e');
    }
  }

  /// Get a project by ID
  /// GET /api/projects/{id}
  Future<Project?> getProjectById(String projectId) async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        return null;
      }

      debugPrint('🔍 Getting project: $projectId');

      final response = await _apiService.get('/api/projects/$projectId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract project from response
        final Map<String, dynamic> projectJson;
        if (responseData.containsKey('project') &&
            responseData['project'] is Map) {
          projectJson = responseData['project'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          projectJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          projectJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing project data');
        }

        final project = Project.fromApiJson(projectJson);
        debugPrint('✅ Loaded project: ${project.name}');
        return project;
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw ServerException(
        'Failed to get project',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is NotFoundException) return null;
      debugPrint('❌ Error getting project: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error getting project: $e');
    }
  }

  /// Get project report
  /// GET /api/projects/{id}/report
  ///
  /// Response Format:
  /// {
  ///   "success": true,
  ///   "project": {
  ///     "_id": "...",
  ///     "name": "...",
  ///     "remaining": 150000,
  ///     "progress": 0,
  ///     "isOverBudget": false,
  ///     "expensesCount": 0,
  ///     ...
  ///   },
  ///   "expenses": []
  /// }
  Future<ProjectReport> getProjectReport(String projectId) async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Projects are only available in business mode',
        );
      }

      debugPrint('📊 Getting project report: $projectId');

      final response = await _apiService.get('/api/projects/$projectId/report');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // The response is already in the correct format:
        // { "success": true, "project": {...}, "expenses": [] }
        debugPrint('✅ Loaded project report');
        return ProjectReport.fromJson(responseData);
      }

      throw ServerException(
        'Failed to get project report',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error getting project report: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error getting project report: $e');
    }
  }

  /// Update an existing project
  /// PUT /api/projects/{id}
  Future<Project> updateProject(String projectId, Project project) async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Projects are only available in business mode',
        );
      }

      debugPrint('✏️ Updating project: $projectId');

      // Build request body with only updatable fields
      final Map<String, dynamic> requestBody = {
        'name': project.name,
        'description': project.description,
        'budget': project.budget,
        'startDate': _formatDate(project.startDate),
        'endDate':
            project.endDate != null ? _formatDate(project.endDate!) : null,
        'clientName': project.clientName,
        'managerName': project.managerName,
        'priority': project.priority,
        'status': project.status.name,
      };

      // Remove null values
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('📤 PUT /api/projects/$projectId');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.put(
        '/api/projects/$projectId',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract project from response
        final Map<String, dynamic> projectJson;
        if (responseData.containsKey('project') &&
            responseData['project'] is Map) {
          projectJson = responseData['project'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          projectJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          projectJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing project data');
        }

        final updatedProject = Project.fromApiJson(projectJson);

        // Clear cache
        clearCache();

        debugPrint('✅ Project updated successfully');
        return updatedProject;
      }

      throw ServerException(
        'Failed to update project',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating project: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to update project: $e');
    }
  }

  /// Delete a project
  /// DELETE /api/projects/{id}
  Future<void> deleteProject(String projectId) async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Projects are only available in business mode',
        );
      }

      debugPrint('🗑️ Deleting project: $projectId');

      final response = await _apiService.delete('/api/projects/$projectId');

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear cache
        clearCache();

        debugPrint('✅ Project deleted successfully');
        return;
      }

      throw ServerException(
        'Failed to delete project',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting project: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to delete project: $e');
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Format date for API (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // CONVENIENCE METHODS
  // ===========================================================================

  /// Get active projects only
  Future<List<Project>> getActiveProjects() async {
    final response = await getAllProjects(status: 'active');
    return response.projects;
  }

  /// Get projects by status
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    final response = await getAllProjects(status: status.name);
    return response.projects;
  }

  /// Search projects by name or description
  Future<List<Project>> searchProjects(String query) async {
    final response = await getAllProjects(forceRefresh: true);
    final lowerQuery = query.toLowerCase();

    return response.projects.where((project) {
      return project.name.toLowerCase().contains(lowerQuery) ||
          (project.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (project.clientName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get project statistics
  Future<Map<String, dynamic>> getProjectsStatistics() async {
    try {
      final response = await getAllProjects(forceRefresh: true);
      final projects = response.projects;

      int totalProjects = projects.length;
      int activeProjects =
          projects.where((p) => p.status == ProjectStatus.active).length;
      int completedProjects =
          projects.where((p) => p.status == ProjectStatus.completed).length;
      int planningProjects =
          projects.where((p) => p.status == ProjectStatus.planning).length;
      int onHoldProjects =
          projects.where((p) => p.status == ProjectStatus.onHold).length;

      double totalBudget = projects.fold(0.0, (total, p) => total + p.budget);
      double totalSpent = projects.fold(
        0.0,
        (total, p) => total + p.spentAmount,
      );
      double totalRemaining = totalBudget - totalSpent;

      return {
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
        'planningProjects': planningProjects,
        'onHoldProjects': onHoldProjects,
        'totalBudget': totalBudget,
        'totalSpent': totalSpent,
        'totalRemaining': totalRemaining,
      };
    } catch (e) {
      debugPrint('❌ Error getting project statistics: $e');
      return {};
    }
  }
}
