import 'package:flutter_tcc/features/home/domain/entities/earnings_summary.dart';

class EarningsSummaryModel extends EarningsSummary {
  EarningsSummaryModel({
    required super.totalEarnings,
    required super.jobs,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsSummaryModel(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      jobs: json['jobs'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarnings': totalEarnings,
      'jobs': jobs,
    };
  }
}
