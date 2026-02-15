import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_status.dart';

/// Repository contract for onboarding (domain only).
abstract class OnboardingRepository {
  /// Returns current onboarding status (isCompleted from storage, step index).
  Future<OnboardingStatus> getStatus();

  /// Mark onboarding as completed (user finished or skipped).
  Future<void> setOnboardingCompleted(bool value);
}
