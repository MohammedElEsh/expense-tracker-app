import 'package:equatable/equatable.dart';

class Statistics extends Equatable {
  final double totalAmount;
  final Map<String, double> categoryTotals;

  const Statistics({required this.totalAmount, required this.categoryTotals});

  @override
  List<Object?> get props => [totalAmount, categoryTotals];
}
