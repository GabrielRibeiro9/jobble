import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/bids/data/models/service_request_detail_model.dart';

class BidRemoteDataSource {
  final DioClient dioClient;

  BidRemoteDataSource({required this.dioClient});

  Future<ServiceRequestDetailModel> getServiceRequest(String id) async {
    final response = await dioClient.dio.get('/service-requests/$id');
    return ServiceRequestDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> respondToMatch({
    required String serviceMatchId,
    required double bidValue,
    required String serviceType,
    String? proposedDate,
  }) async {
    await dioClient.dio.post('/bids', data: {
      'serviceMatchId': serviceMatchId,
      'bidValue': bidValue,
      'serviceType': serviceType,
      if (proposedDate != null) 'proposedDate': proposedDate,
    });
  }
}
