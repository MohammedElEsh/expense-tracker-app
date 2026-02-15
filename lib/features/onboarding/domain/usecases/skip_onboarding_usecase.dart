import 'package:expense_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case: skip onboarding (mark as completed without going through steps).
class SkipOnboardingUseCase {
  final OnboardingRepository repository;

  const SkipOnboardingUseCase(this.repository);

  Future<void> call() => repository.setOnboardingCompleted(true);
}
