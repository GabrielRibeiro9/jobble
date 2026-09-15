import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/bids/data/models/org_match_model.dart';
import 'package:flutter_tcc/features/bids/data/models/service_request_detail_model.dart';

/// Chamados recebidos pela organização.
///
/// O fluxo tem dois passos: primeiro o profissional aceita ou recusa o chamado
/// ([acceptMatch]/[declineMatch]), e só quem aceitou pode mandar a devolutiva
/// ([sendBid]) — com valor, com dúvidas, ou com os dois.
///
/// Toda chamada passa por [apiCall]: a tela recebe uma [ApiException] com uma
/// frase legível, e não o `DioException` cru.
class BidRemoteDataSource {
  final DioClient dioClient;

  BidRemoteDataSource({required this.dioClient});

  /// Todos os chamados da organização, do mais recente para o mais antigo —
  /// é o que monta as pendências da home e a lista de serviços.
  Future<List<OrgMatch>> listMatches() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/matches');
      return (response.data as List)
          .map((item) => OrgMatch.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ServiceRequestDetailModel> getServiceRequest(String id) {
    return apiCall(() async {
      final response = await dioClient.dio.get('/service-requests/$id');
      return ServiceRequestDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  /// Entra na lista de escolha do cliente. Não compromete com preço.
  Future<void> acceptMatch(String serviceMatchId) {
    return apiCall(
      () => dioClient.dio.patch<void>('/matches/$serviceMatchId/accept'),
    );
  }

  Future<void> declineMatch(String serviceMatchId) {
    return apiCall(
      () => dioClient.dio.patch<void>('/matches/$serviceMatchId/decline'),
    );
  }

  /// Devolutiva de quem já aceitou. Todos os campos são opcionais, mas o
  /// backend recusa uma devolutiva sem valor **e** sem pergunta.
  Future<void> sendBid({
    required String serviceMatchId,
    double? bidValue,
    String? serviceType,
    String? proposedDate,
    String? question,
  }) {
    return apiCall(
      () => dioClient.dio.post<void>(
        '/matches/$serviceMatchId/bid',
        data: {
          'bidValue': ?bidValue,
          'serviceType': ?serviceType,
          'proposedDate': ?proposedDate,
          'question': ?question,
        },
      ),
    );
  }
}
