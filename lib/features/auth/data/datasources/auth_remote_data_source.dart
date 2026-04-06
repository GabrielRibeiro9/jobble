import 'package:dio/dio.dart';
import 'package:flutter_tcc/features/auth/data/models/login_request.dart';
import 'package:flutter_tcc/features/auth/data/models/signup_request.dart';
import 'package:flutter_tcc/features/auth/data/models/login_response.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> signup(SignupRequest request);
  Future<void> verifyEmail(String email, String code);
  Future<void> completeOnboarding(String name, String cpf);
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
  Future<void> completeOnboarding(String name, String cpf) async {
    try {
      await dioClient.dio.post(
        '/auth/complete-onboarding',
        data: {'name': name, 'cpf': cpf},
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
