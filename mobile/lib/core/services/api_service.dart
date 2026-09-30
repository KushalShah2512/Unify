import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://172.16.62.181:5000/api';

  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> healthCheck() async {
    return await dio.get('/health');
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }
}