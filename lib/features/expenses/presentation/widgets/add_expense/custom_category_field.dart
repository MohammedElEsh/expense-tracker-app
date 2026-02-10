// Add Expense - Custom Category Field Widget
import 'package:flutter/material.dart';

class CustomCategoryField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomCategoryField({
    super.key,
    required this.controller,
    required this.isRTL,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRTL ? 'اسم الفئة المخصصة' : 'Custom Category Name',
        hintText: isRTL ? 'أدخل اسم الفئة' : 'Enter category name',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.edit),
        helperText: isRTL
            ? 'مطلوب عند اختيار "أخرى"'
            : 'Required when "أخرى" is selected',
      ),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

