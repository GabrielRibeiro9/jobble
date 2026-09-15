import 'package:flutter_tcc/features/auth/domain/entities/user.dart';
import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tcc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_tcc/features/auth/data/models/login_request.dart';
import 'package:flutter_tcc/features/auth/data/models/signup_request.dart';
import 'package:flutter_tcc/features/auth/data/models/login_response.dart';

import 'package:flutter_tcc/features/auth/data/datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<LoginResponse> login(String email, String password) async {
    return await remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
  }

  @override
  Future<void> signup(
    String? name,
    String email,
    String password, {
    String? cpf,
    String? phone,
    String? birthDate,
  }) async {
    await remoteDataSource.signup(
      SignupRequest(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        birthDate: birthDate,
      ),
    );
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    await remoteDataSource.verifyEmail(email, code);
  }

  @override
  Future<void> resendVerificationCode(String email) async {
    return await remoteDataSource.resendVerificationCode(email);
  }

  @override
  Future<void> completeOnboarding(
    String organizationName, {
    String? description,
    String? legalType,
    String? document,
    String? legalName,
  }) async {
    await remoteDataSource.completeOnboarding(
      organizationName,
      description: description,
      legalType: legalType,
      document: document,
      legalName: legalName,
    );
  }
  @override
  Future<User> getMe() async {
    try {
      final userModel = await remoteDataSource.getMe();
      // Salva ou atualiza os dados no cache local
      await localDataSource.cacheUser(userModel);
      return userModel;
    } catch (e) {
      // Em caso de falha de conexão ou erro, tenta buscar do cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateOrganizationProfile(String tags, String bio) async {
    await remoteDataSource.updateOrganizationProfile(tags, bio);
  }
}
