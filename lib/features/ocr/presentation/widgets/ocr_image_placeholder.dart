import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class OcrImagePlaceholder extends StatelessWidget {
  const OcrImagePlaceholder({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  final SettingsState settings;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settings.primaryColor.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: settings.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لم يتم اختيار صورة' : 'No image selected',
            style: TextStyle(
              fontSize: 16,
              color: settings.primaryTextColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
