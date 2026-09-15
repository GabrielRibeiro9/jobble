import 'package:dio/dio.dart';

import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/legal/data/models/account_verification.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

/// Dados cadastrais e verificação de identidade.
///
/// É o que um contrato precisa saber das partes. O cadastro inicial pede o
/// mínimo; o resto é completado aqui, a qualquer momento — e é obrigatório
/// antes de enviar ou assinar um contrato.
class LegalRemoteDataSource {
  LegalRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  Future<UserLegalProfile> getUserProfile() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/users/me/legal-profile');
      return UserLegalProfile.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<UserLegalProfile> updateUserProfile(Map<String, dynamic> body) {
    return apiCall(() async {
      final response = await dioClient.dio.put(
        '/users/me/legal-profile',
        data: body,
      );
      return UserLegalProfile.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<OrganizationLegalProfile> getOrganizationProfile() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/organizations/legal-profile');
      return OrganizationLegalProfile.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  Future<OrganizationLegalProfile> updateOrganizationProfile(
    Map<String, dynamic> body,
  ) {
    return apiCall(() async {
      final response = await dioClient.dio.put(
        '/organizations/legal-profile',
        data: body,
      );
      return OrganizationLegalProfile.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Envia documento e selfie. O servidor confere o tipo da imagem pelos
  /// bytes, então o `contentType` aqui é só uma dica.
  Future<IdentityStatus> submitIdentity({
    required IdentityDocumentType documentType,
    required String documentNumber,
    String? documentIssuer,
    required String frontPath,
    String? backPath,
    required String selfiePath,
  }) {
    return apiCall(() async {
      Future<MultipartFile> file(String path, String name) =>
          MultipartFile.fromFile(
            path,
            filename: '$name.jpg',
            contentType: DioMediaType('image', 'jpeg'),
          );

      final form = FormData.fromMap({
        'documentType': documentType.apiValue,
        'documentNumber': documentNumber,
        if (documentIssuer != null && documentIssuer.trim().isNotEmpty)
          'documentIssuer': documentIssuer.trim(),
        'documentFront': await file(frontPath, 'front'),
        if (backPath != null) 'documentBack': await file(backPath, 'back'),
        'selfie': await file(selfiePath, 'selfie'),
      });

      final response = await dioClient.dio.post(
        '/identity-verification',
        data: form,
        // Três fotos numa conexão móvel passam fácil do timeout padrão.
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      return IdentityStatus.fromJson(
        (response.data as Map<String, dynamic>)['status'] as String?,
      );
    });
  }

  /// Situação da conta — o que libera o app (`GET /users/profile`).
  Future<AccountVerification> getAccountVerification() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/users/profile');
      final data = response.data as Map<String, dynamic>;
      return AccountVerification.fromJson(
        data['verification'] as Map<String, dynamic>?,
      );
    });
  }

  Future<BackgroundCheckInfo> getBackgroundCheck() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/background-check');
      return BackgroundCheckInfo.fromJson(response.data as Map<String, dynamic>);
    });
  }

  /// Envia a foto da certidão com a data de emissão impressa nela. A data vai
  /// ao meio-dia UTC para o fuso não empurrá-la para o dia anterior.
  Future<BackgroundCheckInfo> submitBackgroundCheck({
    required String filePath,
    required DateTime issuedAt,
  }) {
    return apiCall(() async {
      final form = FormData.fromMap({
        'issuedAt': DateTime.utc(
          issuedAt.year,
          issuedAt.month,
          issuedAt.day,
          12,
        ).toIso8601String(),
        'document': await MultipartFile.fromFile(
          filePath,
          filename: 'certidao.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });

      final response = await dioClient.dio.post(
        '/background-check',
        data: form,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );
      return BackgroundCheckInfo.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
