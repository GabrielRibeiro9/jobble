import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase({required this.repository});

  Future<void> execute(
    String? name,
    String email,
    String password, {
    String? cpf,
  }) async {
    await repository.signup(name, email, password, cpf: cpf);
  }
}
