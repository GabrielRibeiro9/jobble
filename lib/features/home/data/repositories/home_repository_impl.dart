import 'package:flutter_tcc/features/home/data/datasources/home_remote_data_source.dart';
import 'package:flutter_tcc/features/home/domain/entities/earnings_summary.dart';
import 'package:flutter_tcc/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<EarningsSummary> getCompletedJobsToday() async {
    return await remoteDataSource.getCompletedJobsToday();
  }
}
