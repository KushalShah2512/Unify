import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static String? _sessionToken;

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

  static Future<void> saveToken(
    String token, {
    required bool persist,
  }) async {
    _sessionToken = token;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("remember_me", persist);
    if (persist) {
      await prefs.setString("auth_token", token);
    } else {
      await prefs.remove("auth_token");
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return _sessionToken ?? prefs.getString("auth_token");
  }

  /// Returns true only when a stored JWT has a future expiry time.
  ///
  /// This is a client-side routing check, not token verification; the API
  /// remains responsible for validating the token signature on every request.
  static Future<bool> hasValidSession() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      final normalizedPayload = base64Url.normalize(parts[1]);
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(normalizedPayload)),
      ) as Map<String, dynamic>;
      final expiresAt = payload['exp'];

      if (expiresAt is! num) {
        return false;
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        expiresAt.toInt() * 1000,
      );

      return expiry.isAfter(DateTime.now());
    } on FormatException {
      return false;
    } on TypeError {
      return false;
    }
  }

  static Future<void> clearToken() async {
    _sessionToken = null;
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("auth_token");
    await prefs.remove("remember_me");
  }
}
