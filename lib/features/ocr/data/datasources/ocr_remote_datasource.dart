import 'package:expense_tracker/features/ocr/data/models/ocr_result_model.dart';

/// Remote data source for OCR (simulated API).
/// TODO: Replace with real API or ML kit integration.
class OcrRemoteDataSource {
  const OcrRemoteDataSource();

  /// Scan receipt: when [imagePath] is provided, use it as ref for parsing; else simulate.
  Future<String> scanReceipt([String? imagePath]) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (imagePath != null && imagePath.isNotEmpty) return imagePath;
    return 'simulated_scan_ref_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Simulate parsing: return mock result from [input].
  /// TODO: Integrate OCR engine (e.g. Google ML Kit, Tesseract).
  Future<OcrResultModel> parseReceipt(String input) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return OcrResultModel.fromJson({
      'merchantName': 'Sample Merchant',
      'totalAmount': 42.99,
      'date': DateTime.now().toIso8601String(),
      'items': [
        {'description': 'Item 1', 'amount': 12.99, 'quantity': 1},
        {'description': 'Item 2', 'amount': 30.00, 'quantity': 1},
      ],
    });
  }
}
