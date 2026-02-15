import 'package:equatable/equatable.dart';

/// Single line item parsed from a receipt (domain entity, no Flutter/data).
class OcrItemEntity extends Equatable {
  final String description;
  final double amount;
  final int quantity;

  const OcrItemEntity({
    required this.description,
    required this.amount,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [description, amount, quantity];
}
