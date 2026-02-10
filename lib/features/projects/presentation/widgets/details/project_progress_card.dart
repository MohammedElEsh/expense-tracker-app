import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class ProjectProgressCard extends StatelessWidget {
  final Project project;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;
  final double progressPercentage;

  const ProjectProgressCard({
    super.key,
    required this.project,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRTL ? 'تقدم المشروع' : 'Project Progress',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: settings.primaryTextColor,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progressPercentage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: settings.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progressPercentage),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRTL ? 'تاريخ البداية' : 'Start Date',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: settings.secondaryTextColor,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(project.startDate),
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: settings.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRTL ? 'تاريخ الانتهاء' : 'End Date',
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: settings.secondaryTextColor,
                ),
              ),
              Text(
                project.endDate != null
                    ? DateFormat('MMM dd, yyyy').format(project.endDate!)
                    : (isRTL ? 'غير محدد' : 'Not specified'),
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: settings.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.blue;
    } else if (percentage >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
