import 'package:equatable/equatable.dart';

abstract class HomeJobsEvent extends Equatable {
  const HomeJobsEvent();

  @override
  List<Object> get props => [];
}

class GetCompletedJobsTodayRequested extends HomeJobsEvent {}
