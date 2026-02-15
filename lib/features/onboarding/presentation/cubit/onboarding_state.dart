import 'package:equatable/equatable.dart';

/// Onboarding state: step index, finished (this session), and persisted isCompleted.
class OnboardingState extends Equatable {
  final int stepIndex;
  final bool isFinished;
  /// Whether onboarding has been completed (from storage; used by app gate).
  final bool isCompleted;

  const OnboardingState({
    this.stepIndex = 0,
    this.isFinished = false,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [stepIndex, isFinished, isCompleted];

  OnboardingState copyWith({
    int? stepIndex,
    bool? isFinished,
    bool? isCompleted,
  }) {
    return OnboardingState(
      stepIndex: stepIndex ?? this.stepIndex,
      isFinished: isFinished ?? this.isFinished,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
