import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class CompleteOnboardingUseCase {
  final AuthRepository repository;

  CompleteOnboardingUseCase({required this.repository});

  Future<void> execute(String name, String cpf) async {
    await repository.completeOnboarding(name, cpf);
  }
}
