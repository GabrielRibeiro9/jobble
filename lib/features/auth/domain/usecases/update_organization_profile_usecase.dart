import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class UpdateOrganizationProfileUseCase {
  final AuthRepository repository;

  UpdateOrganizationProfileUseCase({required this.repository});

  Future<void> execute(String tags, String bio) async {
    await repository.updateOrganizationProfile(tags, bio);
  }
}
