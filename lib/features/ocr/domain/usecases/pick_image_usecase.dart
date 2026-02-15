import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case: pick image from camera or gallery; returns file path or null.
class PickImageUseCase {
  final OcrRepository repository;

  const PickImageUseCase(this.repository);

  Future<String?> call(OcrImageSource source) {
    switch (source) {
      case OcrImageSource.camera:
        return repository.pickImageFromCamera();
      case OcrImageSource.gallery:
        return repository.pickImageFromGallery();
    }
  }
}
