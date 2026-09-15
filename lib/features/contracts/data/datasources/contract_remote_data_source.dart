import 'package:flutter_tcc/core/network/api_exception.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';

/// Rotas `/contracts` do backend — as da organização. O cliente usa
/// `/client/contracts`, com as ações do lado dele.
class ContractRemoteDataSource implements ContractRepository {
  ContractRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  Future<ContractModel> _contract(Future<dynamic> Function() request) {
    return apiCall(() async {
      final response = await request();
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<ContractSummary>> list() {
    return apiCall(() async {
      final response = await dioClient.dio.get('/contracts');
      return (response.data as List? ?? const [])
          .map((e) => ContractSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<ContractModel> get(String id) =>
      _contract(() => dioClient.dio.get('/contracts/$id'));

  @override
  Future<ContractModel> updateTerms(String id, ContractTerms terms) => _contract(
    () => dioClient.dio.put('/contracts/$id/terms', data: terms.toJson()),
  );

  @override
  Future<ContractModel> submit(String id) =>
      _contract(() => dioClient.dio.post('/contracts/$id/submit'));

  @override
  Future<ContractModel> sign(String id, {required String contentHash}) =>
      _contract(
        () => dioClient.dio.post(
          '/contracts/$id/sign',
          data: {'contentHash': contentHash, 'acceptTerms': true},
        ),
      );

  @override
  Future<ContractModel> markCompleted(String id) =>
      _contract(() => dioClient.dio.post('/contracts/$id/complete'));

  @override
  Future<ContractModel> cancel(String id, {required String reason}) => _contract(
    () => dioClient.dio.post('/contracts/$id/cancel', data: {'reason': reason}),
  );

  @override
  Future<ContractModel> terminate(String id, {required String reason}) =>
      _contract(
        () => dioClient.dio.post(
          '/contracts/$id/terminate',
          data: {'reason': reason},
        ),
      );

  @override
  Future<String> sendCopy(String id) {
    return apiCall(() async {
      final response = await dioClient.dio.post('/contracts/$id/send-copy');
      return (response.data as Map<String, dynamic>)['message'] as String? ??
          'Cópia enviada para o seu e-mail';
    });
  }
}
