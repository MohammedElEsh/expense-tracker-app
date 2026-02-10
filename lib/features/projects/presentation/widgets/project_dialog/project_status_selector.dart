// Project Dialog - Status Selector Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';

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

  String _getStatusLabel(ProjectStatus status, bool isRTL) {
    if (!isRTL) {
      return status.name.substring(0, 1).toUpperCase() +
          status.name.substring(1);
    }
    switch (status) {
      case ProjectStatus.planning:
        return 'تخطيط';
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.onHold:
        return 'معلق';
      case ProjectStatus.cancelled:
        return 'ملغي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProjectStatus>(
      initialValue: selectedStatus,
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
                  Text(_getStatusLabel(status, isRTL)),
                ],
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
