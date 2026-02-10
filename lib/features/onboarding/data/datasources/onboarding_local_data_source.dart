import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
  Future<void> init();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _onboardingKey = 'onboarding_completed';
  static SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    await init();
    return _prefs!.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    await init();
    await _prefs!.setBool(_onboardingKey, value);
  }
}
