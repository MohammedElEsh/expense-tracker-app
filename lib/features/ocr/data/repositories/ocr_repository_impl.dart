import 'package:expense_tracker/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:expense_tracker/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';
import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';

/// Implementation of [OcrRepository]; maps model ↔ entity, delegates to datasources.
class OcrRepositoryImpl implements OcrRepository {
  final OcrRemoteDataSource remote;
  final OcrLocalDataSource local;

  const OcrRepositoryImpl({required this.remote, required this.local});

  @override
  Future<String?> pickImageFromCamera() => local.pickFromCamera();

  @override
  Future<String?> pickImageFromGallery() => local.pickFromGallery();

  @override
  Future<String> scanReceipt([String? imagePath]) => remote.scanReceipt(imagePath);

  @override
  Future<OcrResultEntity> parseReceipt(String input) async {
    final model = await remote.parseReceipt(input);
    return model; // OcrResultModel extends OcrResultEntity
  }

  @override
  Future<void> createExpenseFromOcr(OcrResultEntity result) async {
    // TODO: Integrate with AddExpenseUseCase or ExpenseRepository
    // (e.g. create one expense with result.merchantName, result.totalAmount, result.date)
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
