import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  bool isOnboardingCompleted(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final data = decodedToken['data'] as Map<String, dynamic>?;
      if (data != null) {
        return data['onboarding_completed'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }
}
