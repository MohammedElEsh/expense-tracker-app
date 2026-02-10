// ✅ Clean Architecture - Project Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/theme_helper.dart';

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
      elevation: AppSpacing.elevationMd,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: project.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          project.status.icon,
                          size: 14,
                          color: project.status.color,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          project.status.getDisplayName(isRTL),
                          style: AppTypography.labelMedium.copyWith(
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
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          project.priority,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 12,
                            color: _getPriorityColor(project.priority),
                          ),
                          const SizedBox(width: AppSpacing.xxxs),
                          Text(
                            '${project.priority}',
                            style: AppTypography.overline.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(project.priority),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(width: AppSpacing.xs),

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
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isRTL ? 'حذف' : 'Delete',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: Icon(
                      Icons.more_vert,
                      color: context.iconColor,
                      size: AppSpacing.iconSm,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Project Name
              Text(
                project.name,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Description
              if (project.description?.isNotEmpty == true)
                Text(
                  project.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.secondaryTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: AppSpacing.sm),

              // Client and Dates
              Row(
                children: [
                  if (project.clientName?.isNotEmpty == true) ...[
                    Icon(
                      Icons.business,
                      size: AppSpacing.iconXs,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        project.clientName!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Date Info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    _formatDateRange(),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.tertiaryTextColor,
                    ),
                  ),
                  const Spacer(),

                  // Remaining Days
                  if (project.remainingDays != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: _getRemainingDaysColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        project.remainingDays! > 0
                            ? '${project.remainingDays} ${isRTL ? 'يوم متبقي' : 'days left'}'
                            : isRTL
                            ? 'منتهي الصلاحية'
                            : 'Overdue',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getRemainingDaysColor(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.md),

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
            ? AppColors.error
            : project.isNearBudgetLimit
            ? AppColors.warning
            : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRTL ? 'الميزانية' : 'Budget',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            Text(
              '${project.spentAmount.toStringAsFixed(0)} / ${project.budget.toStringAsFixed(0)} ${isRTL ? 'ر.س' : 'SAR'}',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

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

        const SizedBox(height: AppSpacing.xxs),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}% ${isRTL ? 'مستخدم' : 'used'}',
              style: AppTypography.labelSmall.copyWith(
                color: context.tertiaryTextColor,
              ),
            ),
            if (project.remainingBudget > 0)
              Text(
                '${project.remainingBudget.toStringAsFixed(0)} ${isRTL ? 'ر.س متبقي' : 'SAR remaining'}',
                style: AppTypography.labelSmall.copyWith(
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
        return AppColors.error;
      case 4:
        return AppColors.warning;
      case 3:
        return Colors.yellow[700]!;
      case 2:
        return AppColors.primary;
      case 1:
        return AppColors.iconLight;
      default:
        return AppColors.iconLight;
    }
  }

  Color _getRemainingDaysColor() {
    final days = project.remainingDays;
    if (days == null) return AppColors.iconLight;

    if (days <= 0) return AppColors.error;
    if (days <= 7) return AppColors.warning;
    if (days <= 30) return Colors.yellow[700]!;
    return AppColors.success;
  }
}
