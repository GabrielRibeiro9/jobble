import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase({required this.repository});

  Future<void> execute(String email, String code) async {
    await repository.verifyEmail(email, code);
  }
}
