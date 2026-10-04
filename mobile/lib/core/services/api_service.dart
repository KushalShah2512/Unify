import 'package:dio/dio.dart';
import 'package:unify/core/services/storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.21.71.18:5000';

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

  Future<Response> getSkills() async {
    final token = await StorageService.getToken();

    return await dio.get(
      '/api/students/skills',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> addSkill({
    required String name,
    required String level,
  }) async {
    final token = await StorageService.getToken();

    return await dio.post(
      '/api/students/skills',
      data: {
        'name': name,
        'level': level,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> updateSkill({
    required int id,
    required String name,
    required String level,
  }) async {
    final token = await StorageService.getToken();

    return await dio.put(
      '/api/students/skills/$id',
      data: {
        'name': name,
        'level': level,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> deleteSkill(int id) async {
    final token = await StorageService.getToken();

    return await dio.delete(
      '/api/students/skills/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
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

  Future<Response> getProjects() async {
    final token = await StorageService.getToken();

    return await dio.get(
      '/api/students/projects',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> addProject({
    required String title,
    String? description,
    String? technologies,
    String? projectUrl,
  }) async {
    final token = await StorageService.getToken();

    return await dio.post(
      '/api/students/projects',
      data: {
        'title': title,
        'description': description,
        'technologies': technologies,
        'projectUrl': projectUrl,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> updateProject({
    required int id,
    required String title,
    String? description,
    String? technologies,
    String? projectUrl,
  }) async {
    final token = await StorageService.getToken();

    return await dio.put(
      '/api/students/projects/$id',
      data: {
        'title': title,
        'description': description,
        'technologies': technologies,
        'projectUrl': projectUrl,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> deleteProject(int id) async {
    final token = await StorageService.getToken();

    return await dio.delete(
      '/api/students/projects/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

// =====================================================
// Certifications
// =====================================================

Future<Response> getCertifications() async {
  return await dio.get('/api/students/certifications');
}

Future<Response> addCertification({
  required String name,
  String? issuingOrg,
  String? issueDate,
  String? credentialUrl,
}) async {
  return await dio.post(
    '/api/students/certifications',
    data: {
      'name': name,
      'issuingOrg': issuingOrg,
      'issueDate': issueDate,
      'credentialUrl': credentialUrl,
    },
  );
}

Future<Response> updateCertification({
  required int id,
  required String name,
  String? issuingOrg,
  String? issueDate,
  String? credentialUrl,
}) async {
  return await dio.put(
    '/api/students/certifications/$id',
    data: {
      'name': name,
      'issuingOrg': issuingOrg,
      'issueDate': issueDate,
      'credentialUrl': credentialUrl,
    },
  );
}

Future<Response> deleteCertification(int id) async {
  return await dio.delete(
    '/api/students/certifications/$id',
  );
}

// =====================================================
// Education
// =====================================================

  Future<Response> getEducation() async {
    return await dio.get('/api/students/education');
  }

  Future<Response> addEducation({
    required String institution,
    required String degree,
    String? fieldOfStudy,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  }) async {
    return await dio.post(
      '/api/students/education',
      data: {
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'description': description,
      },
    );
  }

  Future<Response> updateEducation({
    required int id,
    required String institution,
    required String degree,
    String? fieldOfStudy,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  }) async {
    return await dio.put(
      '/api/students/education/$id',
      data: {
        'institution': institution,
        'degree': degree,
        'fieldOfStudy': fieldOfStudy,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'description': description,
      },
    );
  }

  Future<Response> deleteEducation(int id) async {
    return await dio.delete('/api/students/education/$id');
  }

// =====================================================
// Career Passport
// =====================================================

  Future<Response> getCareerPassport() async {
    return await dio.get('/api/students/career-passport');
  }

  // =====================================================
// AI Opportunity Readiness
// =====================================================

  Future<Response> analyzeOpportunityReadiness({
    required String title,
    String? company,
    required List<String> requiredSkills,
  }) async {
    return await dio.post(
      '/api/ai/opportunity-readiness',
      data: {
        'opportunity': {
          'title': title,
          'company': company,
          'requiredSkills': requiredSkills,
        },
      },
    );
  }

  // =====================================================
  // Opportunities
  // =====================================================

  Future<Response> getOpportunities() async {
    return await dio.get('/api/opportunities');
  }
}