import 'package:dio/dio.dart';
import 'package:flutter_tcc/features/auth/data/models/login_request.dart';
import 'package:flutter_tcc/features/auth/data/models/signup_request.dart';
import 'package:flutter_tcc/features/auth/data/models/login_response.dart';
import 'package:flutter_tcc/features/auth/data/models/user_model.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> signup(SignupRequest request);
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerificationCode(String email);
  Future<void> completeOnboarding(
    String organizationName, {
    String? description,
    String? legalType,
    String? document,
    String? legalName,
  });
  Future<UserModel> getMe();
  Future<void> updateOrganizationProfile(String tags, String bio);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dioClient.dio.post(
        '/auth/signin',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signup(SignupRequest request) async {
    try {
      await dioClient.dio.post('/auth/signup', data: request.toJson());
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      await dioClient.dio.post(
        '/auth/verify',
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    try {
      await dioClient.dio.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> completeOnboarding(
    String organizationName, {
    String? description,
    String? legalType,
    String? document,
    String? legalName,
  }) async {
    try {
      await dioClient.dio.post(
        '/auth/complete-onboarding',
        data: {
          'organizationName': organizationName,
          'description': ?description,
          'legalType': ?legalType,
          'document': ?document,
          'legalName': ?legalName,
        },
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dioClient.dio.get('/users/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateOrganizationProfile(String tags, String bio) async {
    try {
      await dioClient.dio.patch(
        '/organizations/profile',
        data: {'tags': tags, 'bio': bio},
      );
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
