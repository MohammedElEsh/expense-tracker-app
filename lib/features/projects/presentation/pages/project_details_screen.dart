// ✅ Project Details Screen - Uses ProjectCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_report_entity.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';

import 'package:expense_tracker/features/projects/presentation/widgets/details/project_header_card.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/details/project_progress_card.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/details/project_statistics_section.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/details/project_info_card.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/details/project_expenses_section.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectEntity project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late ProjectEntity _currentProject;
  ProjectReportEntity? _projectReport;
  bool _isLoadingReport = false;

  @override
  void initState() {
    super.initState();
    _currentProject = widget.project;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Load project report
    _loadProjectReport();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectReport() async {
    try {
      setState(() => _isLoadingReport = true);
      final report = await context.read<ProjectCubit>().getProjectReport(_currentProject.id);
      if (mounted) {
        setState(() {
          _projectReport = report;
          _isLoadingReport = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReport = false);
        debugPrint('Error loading project report: $e');
      }
    }
  }

  Future<void> _refreshProject() async {
    try {
      final project = await context.read<ProjectCubit>().getProjectById(_currentProject.id);
      if (project != null && mounted) {
        setState(() => _currentProject = project);
        await _loadProjectReport();
      }
    } catch (e) {
      debugPrint('Error refreshing project: $e');
    }
  }

  Future<void> _editProject() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProjectDialog(project: _currentProject),
    );

    if (result == true) {
      await _refreshProject();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final isDesktop = context.isDesktop;

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: settings.surfaceColor,
            appBar: AppBar(
              backgroundColor: settings.primaryColor,
              foregroundColor:
                  settings.isDarkMode ? Colors.black : Colors.white,
              elevation: 0,
              title: Text(
                isRTL ? 'تفاصيل المشروع' : 'Project Details',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshProject,
                  tooltip: isRTL ? 'تحديث' : 'Refresh',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editProject,
                  tooltip: isRTL ? 'تعديل المشروع' : 'Edit Project',
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<ExpenseCubit, ExpenseState>(
                  builder: (context, expenseState) {
                    final projectExpenses =
                        _projectReport != null && _projectReport!.expenses.isNotEmpty
                            ? _expensesFromReport(_projectReport!)
                            : _getProjectExpenses(expenseState);

                    final totalExpenses =
                        _projectReport?.totalExpenses ??
                        _getTotalExpenses(projectExpenses);
                    final monthlyExpenses = _getMonthlyExpenses(
                      projectExpenses,
                    );
                    final expenseCount =
                        _projectReport?.expenseCount ?? projectExpenses.length;
                    final progressPercentage =
                        _projectReport?.progress ?? _getProgressPercentage();

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Project Header Card
                          ProjectHeaderCard(
                            project: _currentProject,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: 24),

                          // 2. Progress Card
                          ProjectProgressCard(
                            project: _currentProject,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            progressPercentage: progressPercentage,
                          ),
                          const SizedBox(height: 24),

                          // 3. Statistics Section
                          if (_isLoadingReport)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            ProjectStatisticsSection(
                              settings: settings,
                              isRTL: isRTL,
                              isDesktop: isDesktop,
                              totalExpenses: totalExpenses,
                              monthlyExpenses: monthlyExpenses,
                              expenseCount: expenseCount,
                              progressPercentage: progressPercentage,
                            ),
                          const SizedBox(height: 24),

                          // 4. Project Info Card
                          ProjectInfoCard(
                            project: _currentProject,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: 24),

                          // 5. Expenses Section
                          ProjectExpensesSection(
                            expenses: projectExpenses,
                            settings: settings,
                            isRTL: isRTL,
                            isDesktop: isDesktop,
                            onViewAll:
                                () => _showAllExpenses(
                                  projectExpenses,
                                  settings,
                                  isRTL,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Expense> _expensesFromReport(ProjectReportEntity report) {
    try {
      final list = report.expenses
          .map((e) => Expense.fromApiJson(e))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      debugPrint('Error converting report expenses: $e');
      return [];
    }
  }

  List<Expense> _getProjectExpenses(ExpenseState expenseState) {
    if (expenseState.expenses.isNotEmpty) {
      return expenseState.expenses
          .where((expense) => expense.projectId == _currentProject.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    return [];
  }

  double _getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _getMonthlyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final currentMonthExpenses =
        expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();
    return currentMonthExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }

  double _getProgressPercentage() {
    if (_currentProject.endDate == null) return 0.0;

    final now = DateTime.now();
    final totalDays =
        _currentProject.endDate!.difference(_currentProject.startDate).inDays;
    final passedDays = now.difference(_currentProject.startDate).inDays;

    if (totalDays <= 0) return 100.0;
    if (passedDays <= 0) return 0.0;
    if (passedDays >= totalDays) return 100.0;

    return (passedDays / totalDays) * 100;
  }

  void _showAllExpenses(
    List<Expense> expenses,
    SettingsState settings,
    bool isRTL,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: settings.surfaceColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: settings.borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRTL
                                  ? 'جميع مصروفات المشروع'
                                  : 'All Project Expenses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: settings.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ProjectExpensesSection(
                          expenses: expenses,
                          settings: settings,
                          isRTL: isRTL,
                          isDesktop: false,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
