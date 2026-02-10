import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class OcrImagePreview extends StatelessWidget {
  const OcrImagePreview({
    super.key,
    required this.imageFile,
    required this.settings,
    required this.onClearImage,
  });

  final File imageFile;
  final SettingsState settings;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: settings.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
            onPressed: onClearImage,
          ),
        ),
      ],
    );
  }
}
