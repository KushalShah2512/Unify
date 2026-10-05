import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_service.dart';
import 'storage_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _googleSignIn.initialize(
      serverClientId:
          '729101956164-rm9npvconf2bulul56b0239v4jqgoq36.apps.googleusercontent.com',
    );
  }

  Future<Response> signIn() async {
    await initialize();

    final GoogleSignInAccount account =
        await _googleSignIn.authenticate();

    final GoogleSignInAuthentication authentication =
        account.authentication;

    final String? idToken = authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID token was not returned');
    }

    final response = await _apiService.googleLogin(
      idToken: idToken,
    );

    final data = response.data;

    if (data['token'] == null) {
      throw Exception(
        'Backend did not return an authentication token',
      );
    }

    await StorageService.saveToken(data['token']);

    return response;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}