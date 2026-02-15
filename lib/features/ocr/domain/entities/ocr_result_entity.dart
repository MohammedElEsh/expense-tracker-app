import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_item_entity.dart';

/// Result of OCR parsing: merchant, total, date, line items (domain entity).
class OcrResultEntity extends Equatable {
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final List<OcrItemEntity> items;

  const OcrResultEntity({
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    this.items = const [],
  });

  @override
  List<Object?> get props => [merchantName, totalAmount, date, items];
}
