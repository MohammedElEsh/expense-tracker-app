import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:expense_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case: get current onboarding step and completion status.
class GetCurrentStepUseCase {
  final OnboardingRepository repository;

  const GetCurrentStepUseCase(this.repository);

  Future<OnboardingStatus> call() => repository.getStatus();
}
