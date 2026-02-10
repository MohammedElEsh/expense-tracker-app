import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // إظهار حوار اختيار مصدر الصورة
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إضافة صورة'),
          content: const Text('اختر مصدر الصورة'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('الكاميرا'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('gallery'),
              icon: const Icon(Icons.photo_library),
              label: const Text('الاستوديو'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  // التقاط صورة من الكاميرا
  static Future<String?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // ضغط الصورة لتوفير المساحة
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return await _saveImageToAppDirectory(image);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  // اختيار صورة من الاستوديو
  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // ضغط الصورة لتوفير المساحة
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return await _saveImageToAppDirectory(image);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في اختيار الصورة: $e');
      return null;
    }
  }

  // حفظ الصورة في مجلد التطبيق
  static Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'expense_images');

      // إنشاء مجلد الصور إذا لم يكن موجوداً
      final Directory imageDirectory = Directory(imagesDir);
      if (!await imageDirectory.exists()) {
        await imageDirectory.create(recursive: true);
      }

      // إنشاء اسم فريد للصورة
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String newPath = path.join(imagesDir, fileName);

      // نسخ الصورة إلى المجلد الجديد
      final File newFile = await File(image.path).copy(newPath);

      return newFile.path;
    } catch (e) {
      debugPrint('خطأ في حفظ الصورة: $e');
      return null;
    }
  }

  // حذف صورة من المجلد
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في حذف الصورة: $e');
      return false;
    }
  }

  // تحويل البايتات إلى نص مقروء
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
