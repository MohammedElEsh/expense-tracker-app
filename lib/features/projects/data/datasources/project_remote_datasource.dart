import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';

/// Response model for project report (data layer).
class ProjectReportData {
  final Project project;
  final List<Map<String, dynamic>> expenses;
  final bool success;
  final int expensesCount;
  final double remaining;
  final double progress;
  final bool isOverBudget;

  ProjectReportData({
    required this.project,
    required this.expenses,
    this.success = true,
    int? expensesCount,
    double? remaining,
    double? progress,
    bool? isOverBudget,
  })  : expensesCount = expensesCount ?? 0,
        remaining = remaining ?? project.remainingBudget,
        progress = progress ?? project.spentPercentage,
        isOverBudget = isOverBudget ?? project.isOverBudget;

  factory ProjectReportData.fromJson(Map<String, dynamic> json) {
    final projectJson = json['project'] as Map<String, dynamic>? ?? {};
    final expensesList = json['expenses'] as List<dynamic>? ?? [];
    final expensesCount = projectJson['expensesCount'] as int?;
    final remaining = projectJson['remaining'] != null
        ? (projectJson['remaining'] as num).toDouble()
        : null;
    final progress = projectJson['progress'] != null
        ? (projectJson['progress'] as num).toDouble()
        : null;
    final isOverBudget = projectJson['isOverBudget'] as bool?;

    return ProjectReportData(
      project: Project.fromApiJson(projectJson),
      expenses: expensesList.map((e) => e as Map<String, dynamic>).toList(),
      success: json['success'] as bool? ?? true,
      expensesCount: expensesCount,
      remaining: remaining,
      progress: progress,
      isOverBudget: isOverBudget,
    );
  }

  List<Expense> get expenseObjects {
    try {
      return expenses
          .map((e) => Expense.fromApiJson(e))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('❌ Error converting expenses: $e');
      return [];
    }
  }
}

class ProjectsPaginationData {
  final int current;
  final int pages;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  ProjectsPaginationData({
    required this.current,
    required this.pages,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ProjectsPaginationData.fromJson(Map<String, dynamic> json) {
    return ProjectsPaginationData(
      current: json['current'] ?? 1,
      pages: json['pages'] ?? 1,
      total: json['total'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class ProjectsResponseData {
  final List<Project> projects;
  final ProjectsPaginationData pagination;

  ProjectsResponseData({required this.projects, required this.pagination});
}

/// Remote data source for projects. Uses ApiService and AppContext (no static SettingsService).
class ProjectRemoteDataSource {
  final ApiService _apiService;
  final AppContext _appContext;

  List<Project>? _cachedProjects;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  ProjectRemoteDataSource({
    required ApiService apiService,
    required AppContext appContext,
  })  : _apiService = apiService,
        _appContext = appContext;

  bool get _isCacheValid {
    if (_cachedProjects == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  void clearCache() {
    _cachedProjects = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Project cache cleared');
  }

  Future<Project> createProject(Project project) async {
    final currentAppMode = _appContext.appMode;
    if (currentAppMode != AppMode.business) {
      throw ValidationException('Projects are only available in business mode');
    }

    final requestBody = {
      'name': project.name,
      'description': project.description,
      'budget': project.budget,
      'startDate': _formatDate(project.startDate),
      'endDate': project.endDate != null ? _formatDate(project.endDate!) : null,
      'clientName': project.clientName,
      'managerName': project.managerName,
      'priority': project.priority,
      'status': project.status.name,
    };
    requestBody.removeWhere((key, value) => value == null);

    final response = await _apiService.post('/api/projects', data: requestBody);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final projectJson = _extractProjectJson(responseData);
      final newProject = Project.fromApiJson(projectJson);
      clearCache();
      return newProject;
    }
    throw ServerException('Failed to create project', statusCode: response.statusCode);
  }

  Future<ProjectsResponseData> getAllProjects({
    String? status,
    int? page,
    int? limit,
    bool forceRefresh = false,
  }) async {
    final currentAppMode = _appContext.appMode;
    if (currentAppMode != AppMode.business) {
      return ProjectsResponseData(
        projects: [],
        pagination: ProjectsPaginationData(
          current: 1,
          pages: 1,
          total: 0,
          hasNext: false,
          hasPrev: false,
        ),
      );
    }

    if (!forceRefresh && _isCacheValid && status == null && page == null) {
      return ProjectsResponseData(
        projects: _cachedProjects!,
        pagination: ProjectsPaginationData(
          current: 1,
          pages: 1,
          total: _cachedProjects!.length,
          hasNext: false,
          hasPrev: false,
        ),
      );
    }

    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiService.get(
      '/api/projects',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final projectsData = responseData['projects'] ?? responseData['data'] ?? [];
      final projects = (projectsData as List)
          .map((json) => Project.fromApiJson(json as Map<String, dynamic>))
          .toList();

      final paginationData = responseData['pagination'] as Map<String, dynamic>?;
      final pagination = paginationData != null
          ? ProjectsPaginationData.fromJson(paginationData)
          : ProjectsPaginationData(
              current: 1,
              pages: 1,
              total: projects.length,
              hasNext: false,
              hasPrev: false,
            );

      if (status == null && page == null) {
        _cachedProjects = projects;
        _lastFetchTime = DateTime.now();
      }

      return ProjectsResponseData(projects: projects, pagination: pagination);
    }
    throw ServerException('Failed to load projects', statusCode: response.statusCode);
  }

  Future<Project?> getProjectById(String projectId) async {
    if (_appContext.appMode != AppMode.business) return null;

    final response = await _apiService.get('/api/projects/$projectId');

    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final projectJson = _extractProjectJson(responseData);
      return Project.fromApiJson(projectJson);
    }
    if (response.statusCode == 404) return null;
    throw ServerException('Failed to get project', statusCode: response.statusCode);
  }

  Future<ProjectReportData> getProjectReport(String projectId) async {
    if (_appContext.appMode != AppMode.business) {
      throw ValidationException('Projects are only available in business mode');
    }

    final response = await _apiService.get('/api/projects/$projectId/report');

    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      return ProjectReportData.fromJson(responseData);
    }
    throw ServerException('Failed to get project report', statusCode: response.statusCode);
  }

  Future<Project> updateProject(String projectId, Project project) async {
    if (_appContext.appMode != AppMode.business) {
      throw ValidationException('Projects are only available in business mode');
    }

    final requestBody = {
      'name': project.name,
      'description': project.description,
      'budget': project.budget,
      'startDate': _formatDate(project.startDate),
      'endDate': project.endDate != null ? _formatDate(project.endDate!) : null,
      'clientName': project.clientName,
      'managerName': project.managerName,
      'priority': project.priority,
      'status': project.status.name,
    };
    requestBody.removeWhere((key, value) => value == null);

    final response = await _apiService.put('/api/projects/$projectId', data: requestBody);

    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final projectJson = _extractProjectJson(responseData);
      final updated = Project.fromApiJson(projectJson);
      clearCache();
      return updated;
    }
    throw ServerException('Failed to update project', statusCode: response.statusCode);
  }

  Future<void> deleteProject(String projectId) async {
    if (_appContext.appMode != AppMode.business) {
      throw ValidationException('Projects are only available in business mode');
    }

    final response = await _apiService.delete('/api/projects/$projectId');

    if (response.statusCode == 200 || response.statusCode == 204) {
      clearCache();
      return;
    }
    throw ServerException('Failed to delete project', statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> getProjectsStatistics() async {
    try {
      final response = await getAllProjects(forceRefresh: true);
      final projects = response.projects;

      int totalProjects = projects.length;
      int activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;
      int completedProjects = projects.where((p) => p.status == ProjectStatus.completed).length;
      int planningProjects = projects.where((p) => p.status == ProjectStatus.planning).length;
      int onHoldProjects = projects.where((p) => p.status == ProjectStatus.onHold).length;

      double totalBudget = projects.fold(0.0, (t, p) => t + p.budget);
      double totalSpent = projects.fold(0.0, (t, p) => t + p.spentAmount);

      return {
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'completedProjects': completedProjects,
        'planningProjects': planningProjects,
        'onHoldProjects': onHoldProjects,
        'totalBudget': totalBudget,
        'totalSpent': totalSpent,
        'totalRemaining': totalBudget - totalSpent,
      };
    } catch (e) {
      debugPrint('❌ Error getting project statistics: $e');
      return {};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _extractProjectJson(Map<String, dynamic> responseData) {
    if (responseData.containsKey('project') && responseData['project'] is Map) {
      return responseData['project'] as Map<String, dynamic>;
    }
    if (responseData.containsKey('data') && responseData['data'] is Map) {
      return responseData['data'] as Map<String, dynamic>;
    }
    if (responseData.containsKey('_id')) {
      return responseData;
    }
    throw ServerException('Invalid API response: missing project data');
  }
}
