import '../../domain/entities/user.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<void> signup(
    String? name,
    String email,
    String password, {
    String? cpf,
    String? phone,
    String? birthDate,
  });
  Future<void> verifyEmail(String email, String code);
  Future<void> resendVerificationCode(String email);
  Future<void> completeOnboarding(
    String organizationName, {
    String? description,
    String? legalType,
    String? document,
    String? legalName,
  });
  Future<User> getMe();
  Future<void> updateOrganizationProfile(String tags, String bio);
}
