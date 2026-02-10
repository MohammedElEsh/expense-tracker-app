// Project Dialog - Optional Fields Widget
import 'package:flutter/material.dart';

class ProjectOptionalFields extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController clientNameController;
  final TextEditingController managerNameController;
  final bool isRTL;

  const ProjectOptionalFields({
    super.key,
    required this.descriptionController,
    required this.clientNameController,
    required this.managerNameController,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Description
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: isRTL ? 'الوصف' : 'Description',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description),
            hintText: isRTL ? 'اختياري' : 'Optional',
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 16),

        // Client Name
        TextFormField(
          controller: clientNameController,
          decoration: InputDecoration(
            labelText: isRTL ? 'اسم العميل' : 'Client Name',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person_outline),
            hintText: isRTL ? 'اختياري' : 'Optional',
          ),
        ),

        const SizedBox(height: 16),

        // Manager Name
        TextFormField(
          controller: managerNameController,
          decoration: InputDecoration(
            labelText: isRTL ? 'مدير المشروع' : 'Project Manager',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.manage_accounts),
            hintText: isRTL ? 'اختياري' : 'Optional',
          ),
        ),
      ],
    );
  }
}
