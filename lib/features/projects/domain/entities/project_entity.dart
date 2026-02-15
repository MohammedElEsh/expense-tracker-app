import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';

/// Pure domain entity for a project (no data-layer or UI dependencies).
class ProjectEntity {
  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final double spentAmount;
  final String? managerName;
  final String? clientName;
  final int priority;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProjectEntity({
    required this.id,
    required this.name,
    this.description,
    this.status = ProjectStatus.planning,
    required this.startDate,
    this.endDate,
    this.budget = 0.0,
    this.spentAmount = 0.0,
    this.managerName,
    this.clientName,
    this.priority = 3,
    required this.createdAt,
    this.updatedAt,
  });

  double get remainingBudget => budget - spentAmount;
  double get spentPercentage => budget > 0 ? (spentAmount / budget) * 100 : 0.0;
  bool get isOverBudget => spentAmount > budget;
  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;

  ProjectEntity copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? spentAmount,
    String? managerName,
    String? clientName,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spentAmount: spentAmount ?? this.spentAmount,
      managerName: managerName ?? this.managerName,
      clientName: clientName ?? this.clientName,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
