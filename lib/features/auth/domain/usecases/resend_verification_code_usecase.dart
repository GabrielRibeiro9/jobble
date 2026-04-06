import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class ResendVerificationCodeUseCase {
  final AuthRepository repository;

  ResendVerificationCodeUseCase({required this.repository});

  Future<void> execute(String email) async {
    await repository.resendVerificationCode(email);
  }
}
