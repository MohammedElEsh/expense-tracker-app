import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Local data source for OCR: image picking (camera/gallery).
/// Uses injectable ImagePicker; no static usage.
class OcrLocalDataSource {
  final ImagePicker _picker;

  OcrLocalDataSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<String?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) return await _saveToAppDirectory(image);
      return null;
    } catch (e) {
      debugPrint('OcrLocalDataSource.pickFromCamera: $e');
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) return await _saveToAppDirectory(image);
      return null;
    } catch (e) {
      debugPrint('OcrLocalDataSource.pickFromGallery: $e');
      return null;
    }
  }

  Future<String?> _saveToAppDirectory(XFile image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'expense_images');
      final Directory imageDirectory = Directory(imagesDir);
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String newPath = path.join(imagesDir, fileName);
      await File(image.path).copy(newPath);
      return newPath;
    } catch (e) {
      debugPrint('OcrLocalDataSource._saveToAppDirectory: $e');
      return null;
    }
  }
}
