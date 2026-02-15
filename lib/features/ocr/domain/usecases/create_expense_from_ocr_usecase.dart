import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';
import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case: create expense from OCR result.
class CreateExpenseFromOcrUseCase {
  final OcrRepository repository;

  const CreateExpenseFromOcrUseCase(this.repository);

  Future<void> call(OcrResultEntity result) =>
      repository.createExpenseFromOcr(result);
}
