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
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
