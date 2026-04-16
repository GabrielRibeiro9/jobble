import 'package:flutter_tcc/features/auth/domain/entities/user.dart';
import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';

class GetMeUseCase {
  final AuthRepository repository;

  GetMeUseCase({required this.repository});

  Future<User> execute() async {
    return await repository.getMe();
  }
}
