import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class OcrLoadingIndicator extends StatelessWidget {
  const OcrLoadingIndicator({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  final SettingsState settings;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'جاري مسح الفاتورة...' : 'Scanning receipt...',
            style: TextStyle(fontSize: 16, color: settings.primaryTextColor),
          ),
        ],
      ),
    );
  }
}
