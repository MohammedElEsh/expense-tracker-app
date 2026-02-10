import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class ProjectInfoCard extends StatelessWidget {
  final Project project;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const ProjectInfoCard({
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
          Text(
            isRTL ? 'معلومات المشروع' : 'Project Information',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person,
            isRTL ? 'مدير المشروع' : 'Project Manager',
            project.managerName ?? (isRTL ? 'غير محدد' : 'Not specified'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.attach_money,
            isRTL ? 'الميزانية المخصصة' : 'Allocated Budget',
            '${project.budget.toStringAsFixed(2)} ${settings.currencySymbol}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.person_outline,
            isRTL ? 'اسم العميل' : 'Client Name',
            project.clientName ?? (isRTL ? 'غير محدد' : 'Not specified'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: isDesktop ? 20 : 18,
          color: settings.secondaryTextColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: settings.secondaryTextColor,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isDesktop ? 14 : 12,
            color: settings.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
