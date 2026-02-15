import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';
import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case: parse receipt input (image ref or text) into structured result.
class ParseReceiptUseCase {
  final OcrRepository repository;

  const ParseReceiptUseCase(this.repository);

  Future<OcrResultEntity> call(String input) => repository.parseReceipt(input);
}
