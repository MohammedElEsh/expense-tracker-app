import 'package:expense_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case: complete onboarding (user finished all steps).
class CompleteStepUseCase {
  final OnboardingRepository repository;

  const CompleteStepUseCase(this.repository);

  Future<void> call() => repository.setOnboardingCompleted(true);
}
