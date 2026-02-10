// Expense Filter - Amount Range Filter Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountRangeFilter extends StatelessWidget {
  final double? minAmount;
  final double? maxAmount;
  final bool isRTL;
  final String currencySymbol;
  final Function(double?) onMinAmountChanged;
  final Function(double?) onMaxAmountChanged;

  const AmountRangeFilter({
    super.key,
    required this.minAmount,
    required this.maxAmount,
    required this.isRTL,
    required this.currencySymbol,
    required this.onMinAmountChanged,
    required this.onMaxAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'نطاق المبلغ' : 'Amount Range',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: isRTL ? 'من' : 'Min',
                    prefixText: currencySymbol,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (value) {
                    final amount = double.tryParse(value);
                    onMinAmountChanged(amount);
                  },
                  controller: TextEditingController(
                    text: minAmount?.toStringAsFixed(2) ?? '',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  isRTL ? 'إلى' : 'to',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: isRTL ? 'إلى' : 'Max',
                    prefixText: currencySymbol,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (value) {
                    final amount = double.tryParse(value);
                    onMaxAmountChanged(amount);
                  },
                  controller: TextEditingController(
                    text: maxAmount?.toStringAsFixed(2) ?? '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
