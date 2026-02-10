// Project Dialog - Budget Field Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectBudgetField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;
  final String currencySymbol;

  const ProjectBudgetField({
    super.key,
    required this.controller,
    required this.isRTL,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: isRTL ? 'الميزانية *' : 'Budget *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: '$currencySymbol ',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'يرجى إدخال الميزانية' : 'Please enter budget';
        }
        final budget = double.tryParse(value);
        if (budget == null || budget <= 0) {
          return isRTL
              ? 'الميزانية يجب أن تكون أكبر من صفر'
              : 'Budget must be greater than zero';
        }
        return null;
      },
    );
  }
}
