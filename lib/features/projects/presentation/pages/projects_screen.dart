// ✅ Clean Architecture - Projects Screen (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/projects/data/datasources/project_api_service.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_card.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog_refactored.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';
import 'package:expense_tracker/features/projects/presentation/pages/project_details_screen.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/list/projects_search_filter.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // API Service
  ProjectApiService get _projectService => serviceLocator.projectService;

  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String _searchQuery = '';
  ProjectStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);

    try {
      final response = await _projectService.getAllProjects(forceRefresh: true);
      final statistics = await _projectService.getProjectsStatistics();

      setState(() {
        _allProjects = response.projects;
        _filteredProjects = response.projects;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المشاريع: $e')));
      }
    }
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects =
          _allProjects.where((project) {
            final matchesSearch =
                _searchQuery.isEmpty ||
                project.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (project.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (project.clientName?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);

            final matchesStatus =
                _selectedStatus == null || project.status == _selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterProjects();
  }

  void _onStatusFilterChanged(ProjectStatus? status) {
    setState(() => _selectedStatus = status);
    _filterProjects();
  }

  Future<void> _showProjectDialog({Project? project}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProjectDialogRefactored(project: project),
    );

    if (result == true) {
      await _loadProjects();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              project == null
                  ? 'تم إضافة المشروع بنجاح'
                  : 'تم تحديث المشروع بنجاح',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف مشروع "${project.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        // Delete from API (also handles Firebase cleanup internally)
        await _projectService.deleteProject(project.id);
        await _loadProjects();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حذف المشروع بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ في حذف المشروع: $e')));
        }
      }
    }
  }

  void _navigateToProjectDetails(Project project) {
    Navigator.push(
      context,
      AnimatedPageRoute(child: ProjectDetailsScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isRTL ? 'إدارة المشاريع' : 'Project Management',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadProjects,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: true,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.list),
                    text: isRTL ? 'الكل' : 'All',
                  ),
                  Tab(
                    icon: const Icon(Icons.play_circle),
                    text: isRTL ? 'نشط' : 'Active',
                  ),
                  Tab(
                    icon: const Icon(Icons.schedule),
                    text: isRTL ? 'تخطيط' : 'Planning',
                  ),
                  Tab(
                    icon: const Icon(Icons.check_circle),
                    text: isRTL ? 'مكتمل' : 'Completed',
                  ),
                  Tab(
                    icon: const Icon(Icons.pause_circle),
                    text: isRTL ? 'معلق' : 'On Hold',
                  ),
                  Tab(
                    icon: const Icon(Icons.analytics),
                    text: isRTL ? 'إحصائيات' : 'Statistics',
                  ),
                ],
              ),
            ),
            body:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllProjectsTab(isRTL),
                        _buildProjectsByStatus(ProjectStatus.active, isRTL),
                        _buildProjectsByStatus(ProjectStatus.planning, isRTL),
                        _buildProjectsByStatus(ProjectStatus.completed, isRTL),
                        _buildProjectsByStatus(ProjectStatus.onHold, isRTL),
                        _buildStatisticsTab(isRTL),
                      ],
                    ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'project_add_fab',
              onPressed: () => _showProjectDialog(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllProjectsTab(bool isRTL) {
    return Column(
      children: [
        ProjectsSearchFilter(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedStatus: _selectedStatus,
          onSearchChanged: _onSearchChanged,
          onStatusChanged: _onStatusFilterChanged,
          isRTL: isRTL,
        ),
        Expanded(child: _buildProjectsList(_filteredProjects, isRTL)),
      ],
    );
  }

  Widget _buildProjectsByStatus(ProjectStatus status, bool isRTL) {
    final projects = _allProjects.where((p) => p.status == status).toList();
    return _buildProjectsList(projects, isRTL);
  }

  Widget _buildProjectsList(List<Project> projects, bool isRTL) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا توجد مشاريع' : 'No projects',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          isRTL: isRTL,
          onTap: () => _navigateToProjectDetails(project),
          onDelete: () => _deleteProject(project),
        );
      },
    );
  }

  Widget _buildStatisticsTab(bool isRTL) {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            isRTL ? 'إحصائيات المشاريع' : 'Project Statistics',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            '${_statistics!['totalProjects'] ?? 0} ${isRTL ? "مشروع" : "projects"}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
