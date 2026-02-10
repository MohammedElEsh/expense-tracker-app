// Project Dialog - Name Field Widget
import 'package:flutter/material.dart';

class ProjectNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;

  const ProjectNameField({
    super.key,
    required this.controller,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRTL ? 'اسم المشروع *' : 'Project Name *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.work),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'يرجى إدخال اسم المشروع' : 'Please enter project name';
        }
        return null;
      },
    );
  }
}
