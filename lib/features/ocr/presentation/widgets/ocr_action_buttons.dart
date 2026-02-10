import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class OcrActionButtons extends StatelessWidget {
  const OcrActionButtons({
    super.key,
    required this.settings,
    required this.isRTL,
    required this.hasImage,
    required this.isScanning,
    required this.canScan,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onScan,
    required this.onClearImage,
  });

  final SettingsState settings;
  final bool isRTL;
  final bool hasImage;
  final bool isScanning;
  final bool canScan;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onScan;
  final VoidCallback onClearImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image Selection Buttons
        if (!hasImage) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? null : onPickCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(isRTL ? 'التقط صورة' : 'Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.primaryColor,
                    foregroundColor:
                        settings.isDarkMode ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? null : onPickGallery,
                  icon: const Icon(Icons.photo_library),
                  label: Text(isRTL ? 'اختر من المعرض' : 'Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.surfaceColor,
                    foregroundColor: settings.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: settings.primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Scan Button
          ElevatedButton.icon(
            onPressed: canScan && !isScanning ? onScan : null,
            icon: const Icon(Icons.scanner),
            label: Text(
              isRTL ? 'مسح الفاتورة' : 'Scan Receipt',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canScan ? settings.primaryColor : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Retake/Change Image Button
          OutlinedButton.icon(
            onPressed: isScanning ? null : onClearImage,
            icon: const Icon(Icons.refresh),
            label: Text(isRTL ? 'اختر صورة أخرى' : 'Choose Another Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: settings.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: settings.primaryColor),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
