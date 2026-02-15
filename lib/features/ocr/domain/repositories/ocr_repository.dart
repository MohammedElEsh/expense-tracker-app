import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';

/// Source for picking an image (camera or gallery).
enum OcrImageSource { camera, gallery }

/// Repository contract for OCR operations (domain only).
abstract class OcrRepository {
  /// Pick image from camera; returns file path or null if cancelled.
  Future<String?> pickImageFromCamera();

  /// Pick image from gallery; returns file path or null if cancelled.
  Future<String?> pickImageFromGallery();

  /// Scan receipt (optionally from [imagePath]) and return raw reference for parsing.
  /// When [imagePath] is provided, uses that file; otherwise simulated/placeholder.
  Future<String> scanReceipt([String? imagePath]);

  /// Parse receipt (image path or raw text) and return structured result.
  Future<OcrResultEntity> parseReceipt(String input);

  /// Create an expense from OCR result (e.g. call expense repository).
  Future<void> createExpenseFromOcr(OcrResultEntity result);
}
