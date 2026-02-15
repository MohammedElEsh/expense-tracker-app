import 'package:equatable/equatable.dart';

/// Domain entity for a subscription plan.
class SubscriptionPlan extends Equatable {
  final String id;
  final String title;
  final double price;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    this.features = const [],
  });

  @override
  List<Object?> get props => [id, title, price, features];
}
