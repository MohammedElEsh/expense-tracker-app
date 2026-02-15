import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_step_usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/get_current_step_usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/skip_onboarding_usecase.dart';
import 'package:expense_tracker/features/onboarding/presentation/cubit/onboarding_state.dart';

/// Onboarding Cubit: depends only on use cases (no direct storage/service).
class OnboardingCubit extends Cubit<OnboardingState> {
  final GetCurrentStepUseCase getCurrentStepUseCase;
  final CompleteStepUseCase completeStepUseCase;
  final SkipOnboardingUseCase skipOnboardingUseCase;
  final int totalSteps;

  OnboardingCubit({
    required this.getCurrentStepUseCase,
    required this.completeStepUseCase,
    required this.skipOnboardingUseCase,
    this.totalSteps = 4,
  }) : super(const OnboardingState()) {
    loadOnboardingStatus();
  }

  int get currentStep => state.stepIndex;

  /// Load persisted onboarding status (used by app gate and initial state).
  Future<void> loadOnboardingStatus() async {
    try {
      final status = await getCurrentStepUseCase();
      if (!isClosed) {
        emit(state.copyWith(isCompleted: status.isCompleted));
      }
    } catch (_) {
      // Keep default state on error
    }
  }

  void nextStep() {
    if (state.isFinished || state.isCompleted) return;
    if (state.stepIndex >= totalSteps - 1) {
      finish();
    } else {
      emit(state.copyWith(stepIndex: state.stepIndex + 1));
    }
  }

  /// Skip onboarding: persist and emit completed.
  Future<void> skip() async {
    if (state.isFinished || state.isCompleted) return;
    try {
      await skipOnboardingUseCase();
      if (!isClosed) emit(state.copyWith(isFinished: true, isCompleted: true));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isFinished: true, isCompleted: true));
    }
  }

  /// Finish onboarding (last step): persist and emit completed.
  Future<void> finish() async {
    if (state.isFinished || state.isCompleted) return;
    try {
      await completeStepUseCase();
      if (!isClosed) emit(state.copyWith(isFinished: true, isCompleted: true));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isFinished: true, isCompleted: true));
    }
  }

  void goToStep(int index) {
    if (state.isFinished || state.isCompleted) return;
    final clamped = index.clamp(0, totalSteps - 1);
    emit(state.copyWith(stepIndex: clamped));
  }
}
