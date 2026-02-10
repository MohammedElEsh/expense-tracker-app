// Signup - Name Field Widget
import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;
  final String? label;
  final IconData? icon;

  const NameField({
    super.key,
    required this.controller,
    required this.isRTL,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? (isRTL ? 'الاسم' : 'Name'),
        prefixIcon: Icon(icon ?? Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'أدخل الاسم' : 'Enter name';
        }
        if (value.trim().length < 3) {
          return isRTL
              ? 'الاسم يجب أن يكون 3 أحرف على الأقل'
              : 'Name must be at least 3 characters';
        }
        return null;
      },
    );
  }
}
