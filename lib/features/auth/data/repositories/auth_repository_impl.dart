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
}
