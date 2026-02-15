import 'package:equatable/equatable.dart';

/// Status of the current user subscription (for CheckStatus use case).
class SubscriptionStatus extends Equatable {
  final String? planId;
  final bool isActive;
  final DateTime? expiresAt;

  const SubscriptionStatus({
    this.planId,
    this.isActive = false,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [planId, isActive, expiresAt];
}
