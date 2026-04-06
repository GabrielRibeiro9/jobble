import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> signup(
    String? name,
    String email,
    String password, {
    String? cpf,
  });
  Future<void> verifyEmail(String email, String code);
  Future<void> completeOnboarding(String name, String cpf);
}
