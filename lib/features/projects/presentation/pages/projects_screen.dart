// ✅ Projects Screen - Uses ProjectCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_card.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    context.read<ProjectCubit>().loadProjects(forceRefresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showProjectDialog({ProjectEntity? project}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProjectDialog(project: project),
    );
    if (result == true && mounted) {
      context.read<ProjectCubit>().loadProjects(forceRefresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project == null
                ? 'تم إضافة المشروع بنجاح'
                : 'تم تحديث المشروع بنجاح',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteProject(ProjectEntity project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف مشروع "${project.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await context.read<ProjectCubit>().deleteProject(project.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المشروع بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حذف المشروع: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final isRTL = settings.language == 'ar';
          return Directionality(
            textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  isRTL ? 'إدارة المشاريع' : 'Project Management',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        context.read<ProjectCubit>().loadProjects(forceRefresh: true),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  isScrollable: true,
                  tabs: [
                    Tab(icon: const Icon(Icons.list), text: isRTL ? 'الكل' : 'All'),
                    Tab(icon: const Icon(Icons.play_circle), text: isRTL ? 'نشط' : 'Active'),
                    Tab(icon: const Icon(Icons.schedule), text: isRTL ? 'تخطيط' : 'Planning'),
                    Tab(icon: const Icon(Icons.check_circle), text: isRTL ? 'مكتمل' : 'Completed'),
                    Tab(icon: const Icon(Icons.pause_circle), text: isRTL ? 'معلق' : 'On Hold'),
                    Tab(icon: const Icon(Icons.analytics), text: isRTL ? 'إحصائيات' : 'Statistics'),
                  ],
                ),
              ),
              body: BlocBuilder<ProjectCubit, ProjectState>(
                builder: (context, projectState) {
                  if (projectState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (projectState is ProjectError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              projectState.message,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton.icon(
                              onPressed: () => context.read<ProjectCubit>().loadProjects(forceRefresh: true),
                              icon: const Icon(Icons.refresh),
                              label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllProjectsTab(context, projectState, isRTL),
                      _buildProjectsByStatus(context, projectState, ProjectStatus.active, isRTL),
                      _buildProjectsByStatus(context, projectState, ProjectStatus.planning, isRTL),
                      _buildProjectsByStatus(context, projectState, ProjectStatus.completed, isRTL),
                      _buildProjectsByStatus(context, projectState, ProjectStatus.onHold, isRTL),
                      _buildStatisticsTab(projectState, isRTL),
                    ],
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                heroTag: 'project_add_fab',
                onPressed: () => _showProjectDialog(),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          );
        },
    );
  }

  Widget _buildAllProjectsTab(
      BuildContext context, ProjectState state, bool isRTL) {
    return Column(
      children: [
        ProjectsSearchFilter(
          searchController: _searchController,
          searchQuery: state.searchQuery ?? '',
          selectedStatus: state.selectedStatus,
          onSearchChanged: (q) => context.read<ProjectCubit>().searchProjects(q),
          onStatusChanged: (s) => context.read<ProjectCubit>().filterByStatus(s),
          isRTL: isRTL,
        ),
        Expanded(
            child: _buildProjectsList(
                context, state.filteredProjects, isRTL)),
      ],
    );
  }

  Widget _buildProjectsByStatus(
      BuildContext context, ProjectState state, ProjectStatus status, bool isRTL) {
    final projects = state.projects.where((p) => p.status == status).toList();
    return _buildProjectsList(context, projects, isRTL);
  }

  Widget _buildProjectsList(
      BuildContext context, List<ProjectEntity> projects, bool isRTL) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 64, color: AppColors.textDisabledLight),
            const SizedBox(height: AppSpacing.md),
            Text(
              isRTL ? 'لا توجد مشاريع' : 'No projects',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          isRTL: isRTL,
          onTap: () => context.push(AppRoutes.projectDetails, extra: project),
          onDelete: () => _deleteProject(project),
        );
      },
    );
  }

  Widget _buildStatisticsTab(ProjectState state, bool isRTL) {
    if (state.statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = state.statistics!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(
            isRTL ? 'إحصائيات المشاريع' : 'Project Statistics',
            style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${stats['totalProjects'] ?? 0} ${isRTL ? "مشروع" : "projects"}',
            style: AppTypography.headlineSmall,
          ),
        ],
      ),
    );
  }
}
