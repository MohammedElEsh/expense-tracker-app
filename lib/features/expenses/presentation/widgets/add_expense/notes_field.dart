// Add Expense - Notes Field Widget
import 'package:flutter/material.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool isRTL;
  final Function(String) onChanged;

  const NotesField({
    super.key,
    required this.controller,
    required this.isRTL,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRTL ? 'ملاحظات' : 'Notes',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.note),
        hintText: isRTL ? 'أضف وصف للمصروف...' : 'Add expense description...',
      ),
      maxLines: 3,
      onChanged: onChanged,
    );
  }
}
