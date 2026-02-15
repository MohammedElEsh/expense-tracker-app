// Project Dialog - Status Selector Widget (domain ProjectStatus)
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/utils/project_display_helper.dart';

class ProjectStatusSelector extends StatelessWidget {
  final ProjectStatus selectedStatus;
  final bool isRTL;
  final Function(ProjectStatus?) onChanged;

  const ProjectStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.isRTL,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProjectStatus>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: isRTL ? 'الحالة *' : 'Status *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.flag),
      ),
      items:
          ProjectStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status.displayName(isRTL)),
                ],
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
