import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case: scan receipt (camera/gallery) and return reference for parsing.
class ScanReceiptUseCase {
  final OcrRepository repository;

  const ScanReceiptUseCase(this.repository);

  Future<String> call([String? imagePath]) => repository.scanReceipt(imagePath);
}
