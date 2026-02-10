// ✅ Clean Architecture - Project Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/utils/theme_helper.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isRTL;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isRTL,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: project.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          project.status.icon,
                          size: 14,
                          color: project.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project.status.getDisplayName(isRTL),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: project.status.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Priority Indicator
                  if (project.priority > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          project.priority,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 12,
                            color: _getPriorityColor(project.priority),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${project.priority}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(project.priority),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: 8),

                  // Menu Button
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isRTL ? 'حذف' : 'Delete',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: Icon(
                      Icons.more_vert,
                      color: context.iconColor,
                      size: 20,
                    ),
                  ),
                  
                ],
              ),

              const SizedBox(height: 12),

              // Project Name
              Text(
                project.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              if (project.description?.isNotEmpty == true)
                Text(
                  project.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.secondaryTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Client and Dates
              Row(
                children: [
                  if (project.clientName?.isNotEmpty == true) ...[
                    Icon(Icons.business, size: 16, color: context.iconColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        project.clientName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // Date Info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateRange(),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.tertiaryTextColor,
                    ),
                  ),
                  const Spacer(),

                  // Remaining Days
                  if (project.remainingDays != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRemainingDaysColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.remainingDays! > 0
                            ? '${project.remainingDays} ${isRTL ? 'يوم متبقي' : 'days left'}'
                            : isRTL
                            ? 'منتهي الصلاحية'
                            : 'Overdue',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getRemainingDaysColor(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Budget Progress
              _buildBudgetProgress(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context) {
    final percentage = project.spentPercentage;
    final color =
        project.isOverBudget
            ? Colors.red
            : project.isNearBudgetLimit
            ? Colors.orange
            : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRTL ? 'الميزانية' : 'Budget',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            Text(
              '${project.spentAmount.toStringAsFixed(0)} / ${project.budget.toStringAsFixed(0)} ${isRTL ? 'ر.س' : 'SAR'}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress Bar
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: context.borderColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percentage / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}% ${isRTL ? 'مستخدم' : 'used'}',
              style: TextStyle(fontSize: 11, color: context.tertiaryTextColor),
            ),
            if (project.remainingBudget > 0)
              Text(
                '${project.remainingBudget.toStringAsFixed(0)} ${isRTL ? 'ر.س متبقي' : 'SAR remaining'}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.tertiaryTextColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatDateRange() {
    final formatter = DateFormat('MMM dd, yyyy');
    final startDate = formatter.format(project.startDate);

    if (project.endDate != null) {
      final endDate = formatter.format(project.endDate!);
      return '$startDate - $endDate';
    } else {
      return '${isRTL ? 'بدأ في' : 'Started'} $startDate';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getRemainingDaysColor() {
    final days = project.remainingDays;
    if (days == null) return Colors.grey;

    if (days <= 0) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 30) return Colors.yellow[700]!;
    return Colors.green;
  }
}
