import 'package:dio/dio.dart';
import 'package:unify/core/services/storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.21.71.244:5000';

  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  Future<Response> healthCheck() async {
    return dio.get('/api/health');
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return dio.post(
      '/api/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
      },
    );
  }

  Future<Response> getStudentProfile() async {
    return dio.get('/api/students/profile');
  }

  Future<Response> createStudentProfile({
    required String fullName,
    String? phone,
    String? location,
    String? bio,
    String? education,
    String? careerGoal,
    String? availability,
  }) async {
    return dio.post(
      '/api/students/profile',
      data: {
        'fullName': fullName,
        'phone': phone,
        'location': location,
        'bio': bio,
        'education': education,
        'careerGoal': careerGoal,
        'availability': availability,
      },
    );
  }

  Future<Response> updateStudentProfile({
    required String fullName,
    String? phone,
    String? location,
    String? bio,
    String? education,
    String? careerGoal,
    String? availability,
  }) async {
    return dio.put(
      '/api/students/profile',
      data: {
        'fullName': fullName,
        'phone': phone,
        'location': location,
        'bio': bio,
        'education': education,
        'careerGoal': careerGoal,
        'availability': availability,
      },
    );
  }
}