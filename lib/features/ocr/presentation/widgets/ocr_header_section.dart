import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class OcrHeaderSection extends StatelessWidget {
  const OcrHeaderSection({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  final SettingsState settings;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: settings.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long,
            size: 48,
            color: settings.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isRTL
              ? 'مسح الفواتير بالذكاء الاصطناعي'
              : 'AI-Powered Receipt Scanning',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRTL
              ? 'التقط صورة للفاتورة وسنقوم باستخراج المعلومات تلقائياً'
              : 'Take a photo of your receipt and we\'ll extract the information automatically',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: settings.primaryTextColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
