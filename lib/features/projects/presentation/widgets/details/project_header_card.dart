import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/presentation/utils/project_display_helper.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class ProjectHeaderCard extends StatelessWidget {
  final ProjectEntity project;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const ProjectHeaderCard({
    super.key,
    required this.project,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPriorityColor(project.priority),
            _getPriorityColor(project.priority).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getPriorityColor(project.priority).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getProjectIcon(project.priority),
                  size: isDesktop ? 32 : 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPriorityLabel(project.priority, isRTL),
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project.status.displayName(isRTL),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (project.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              project.description!,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getProjectIcon(int priority) {
    switch (priority) {
      case 5:
        return Icons.priority_high;
      case 4:
        return Icons.work;
      case 3:
        return Icons.task_alt;
      case 2:
        return Icons.low_priority;
      case 1:
        return Icons.check_circle;
      default:
        return Icons.work;
    }
  }

  String _getPriorityLabel(int priority, bool isRTL) {
    switch (priority) {
      case 5:
        return isRTL ? 'أولوية عالية جداً' : 'Very High Priority';
      case 4:
        return isRTL ? 'أولوية عالية' : 'High Priority';
      case 3:
        return isRTL ? 'أولوية متوسطة' : 'Medium Priority';
      case 2:
        return isRTL ? 'أولوية منخفضة' : 'Low Priority';
      case 1:
        return isRTL ? 'أولوية منخفضة جداً' : 'Very Low Priority';
      default:
        return isRTL ? 'أولوية غير محددة' : 'Unknown Priority';
    }
  }

}
