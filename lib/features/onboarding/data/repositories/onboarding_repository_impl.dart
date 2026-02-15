import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:expense_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of [OnboardingRepository]; delegates to local datasource.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource local;

  const OnboardingRepositoryImpl({required this.local});

  @override
  Future<OnboardingStatus> getStatus() async {
    final completed = await local.isOnboardingCompleted();
    return OnboardingStatus(isCompleted: completed, currentStep: 0);
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    await local.setOnboardingCompleted(value);
  }
}
