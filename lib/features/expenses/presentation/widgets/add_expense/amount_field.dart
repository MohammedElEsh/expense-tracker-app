// Add Expense - Amount Field Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final bool isRTL;
  final Function(double?) onChanged;

  const AmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    required this.isRTL,
    required this.onChanged,
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
        labelText: isRTL ? 'المبلغ *' : 'Amount *',
        prefixText: '$currencySymbol ',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.attach_money),
        helperText: isRTL ? 'مطلوب' : 'Required',
      ),
      onChanged: (value) {
        final amount = double.tryParse(value);
        onChanged(amount);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isRTL ? 'المبلغ مطلوب' : 'Amount is required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return isRTL
              ? 'المبلغ يجب أن يكون أكبر من صفر'
              : 'Amount must be greater than zero';
        }
        return null;
      },
    );
  }
}
