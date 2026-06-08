import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfessionalProfileUseCase {
  final AuthRepository repository;

  UpdateProfessionalProfileUseCase({required this.repository});

  Future<void> execute(String tags, String bio) async {
    await repository.updateProfessionalProfile(tags, bio);
  }
}