import 'package:flutter_tcc/features/home/domain/entities/earnings_summary.dart';

abstract class HomeRepository {
  Future<EarningsSummary> getCompletedJobsToday();
}
