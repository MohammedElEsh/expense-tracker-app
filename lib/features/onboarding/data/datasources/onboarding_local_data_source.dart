import 'package:shared_preferences/shared_preferences.dart';

/// Local data source contract for onboarding persistence.
abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
}

/// Implementation using SharedPreferences (injected; no static usage).
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _onboardingKey = 'onboarding_completed';
  final SharedPreferences _prefs;

  OnboardingLocalDataSourceImpl(this._prefs);

  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }
}
