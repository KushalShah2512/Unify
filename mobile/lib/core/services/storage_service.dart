import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool("onboarding_completed") ?? false;
  }

  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "onboarding_completed",
      true,
    );
  }
}