import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';

extension ProjectEntityDisplay on ProjectEntity {
  int? get remainingDays {
    if (endDate == null || status == ProjectStatus.completed) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  bool get isNearBudgetLimit => spentPercentage >= 80 && !isOverBudget;
}

extension ProjectStatusDisplay on ProjectStatus {
  String displayName(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case ProjectStatus.planning:
          return 'قيد التخطيط';
        case ProjectStatus.active:
          return 'نشط';
        case ProjectStatus.onHold:
          return 'معلق';
        case ProjectStatus.completed:
          return 'مكتمل';
        case ProjectStatus.cancelled:
          return 'ملغي';
      }
    }
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectStatus.planning:
        return Icons.schedule;
      case ProjectStatus.active:
        return Icons.play_circle;
      case ProjectStatus.onHold:
        return Icons.pause_circle;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.grey;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }
}
