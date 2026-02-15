import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';

/// Domain DTO for project report (project + aggregated expense data).
class ProjectReportEntity {
  final ProjectEntity project;
  final List<Map<String, dynamic>> expenses;
  final double totalExpenses;
  final int expenseCount;
  final double remaining;
  final double progress;
  final bool isOverBudget;

  const ProjectReportEntity({
    required this.project,
    required this.expenses,
    required this.totalExpenses,
    required this.expenseCount,
    required this.remaining,
    required this.progress,
    required this.isOverBudget,
  });
}
