import 'package:equatable/equatable.dart';
import 'package:flutter_tcc/features/home/domain/entities/earnings_summary.dart';

abstract class HomeJobsState extends Equatable {
  const HomeJobsState();

  @override
  List<Object?> get props => [];
}

class HomeJobsInitial extends HomeJobsState {}

class HomeJobsLoading extends HomeJobsState {}

class HomeJobsLoaded extends HomeJobsState {
  final EarningsSummary summary;

  const HomeJobsLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class HomeJobsError extends HomeJobsState {
  final String message;

  const HomeJobsError({required this.message});

  @override
  List<Object?> get props => [message];
}
