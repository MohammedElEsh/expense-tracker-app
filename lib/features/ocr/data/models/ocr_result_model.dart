import 'package:expense_tracker/features/ocr/domain/entities/ocr_item_entity.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';

/// Data model for API/JSON mapping; extends domain entity.
class OcrResultModel extends OcrResultEntity {
  const OcrResultModel({
    required super.merchantName,
    required super.totalAmount,
    required super.date,
    super.items,
  });

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((e) => OcrItemEntity(
              description: e['description'] as String? ?? '',
              amount: (e['amount'] as num?)?.toDouble() ?? 0.0,
              quantity: (e['quantity'] as int?) ?? 1,
            ))
        .toList();
    return OcrResultModel(
      merchantName: json['merchantName'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'items': items
          .map((e) => {
                'description': e.description,
                'amount': e.amount,
                'quantity': e.quantity,
              })
          .toList(),
    };
  }
}
