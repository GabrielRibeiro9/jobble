import 'package:dio/dio.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/home/data/models/earnings_summary_model.dart';

abstract class HomeRemoteDataSource {
  Future<EarningsSummaryModel> getCompletedJobsToday();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<EarningsSummaryModel> getCompletedJobsToday() async {
    try {
      final response = await dioClient.dio.get('/professional/jobs/completed-today');
      return EarningsSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
        throw Exception('O servidor demorou muito para responder. Verifique sua conexão ou tente novamente.');
      }
      
      if (e.response?.statusCode == 502) {
        throw Exception('O servidor está temporariamente indisponível. Estamos trabalhando para restaurar o serviço.');
      }

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
