import 'package:flutter_tcc/features/auth/domain/entities/user.dart';
import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tcc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_tcc/features/auth/data/models/login_request.dart';
import 'package:flutter_tcc/features/auth/data/models/signup_request.dart';
import 'package:flutter_tcc/features/auth/data/models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

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
  }) async {
    await remoteDataSource.signup(
      SignupRequest(name: name, email: email, password: password, cpf: cpf),
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
  Future<void> completeOnboarding(String name, String cpf) async {
    await remoteDataSource.completeOnboarding(name, cpf);
  }
  @override
  Future<User> getMe() async {
    return await remoteDataSource.getMe();
  }
}
