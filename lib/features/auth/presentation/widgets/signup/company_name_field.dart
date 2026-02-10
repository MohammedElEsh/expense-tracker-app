// Signup - Company Name Field Widget
import 'package:flutter/material.dart';

class CompanyNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;

  const CompanyNameField({
    super.key,
    required this.controller,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRTL ? 'اسم الشركة' : 'Company Name',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'أدخل اسم الشركة' : 'Enter company name';
        }
        if (value.trim().length < 3) {
          return isRTL
              ? 'اسم الشركة يجب أن يكون 3 أحرف على الأقل'
              : 'Company name must be at least 3 characters';
        }
        return null;
      },
    );
  }
}
