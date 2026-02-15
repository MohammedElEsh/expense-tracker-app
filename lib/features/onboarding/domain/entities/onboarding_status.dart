import 'package:equatable/equatable.dart';

/// Domain entity: whether onboarding has been completed (and optional current step).
class OnboardingStatus extends Equatable {
  final bool isCompleted;
  final int currentStep;

  const OnboardingStatus({
    this.isCompleted = false,
    this.currentStep = 0,
  });

  @override
  List<Object?> get props => [isCompleted, currentStep];
}
