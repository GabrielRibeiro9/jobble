import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class CompleteOnboardingUseCase {
  final AuthRepository repository;

  CompleteOnboardingUseCase({required this.repository});

  Future<void> execute(String organizationName, {String? description}) async {
    await repository.completeOnboarding(organizationName, description: description);
  }
}
