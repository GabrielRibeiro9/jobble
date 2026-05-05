import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_event.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_state.dart';

class HomeJobsBloc extends Bloc<HomeJobsEvent, HomeJobsState> {
  final HomeRepository repository;

  HomeJobsBloc({required this.repository}) : super(HomeJobsInitial()) {
    on<GetCompletedJobsTodayRequested>(_onGetCompletedJobsTodayRequested);
  }

  Future<void> _onGetCompletedJobsTodayRequested(
    GetCompletedJobsTodayRequested event,
    Emitter<HomeJobsState> emit,
  ) async {
    emit(HomeJobsLoading());
    try {
      final summary = await repository.getCompletedJobsToday();
      emit(HomeJobsLoaded(summary: summary));
    } catch (e) {
      emit(HomeJobsError(message: e.toString()));
    }
  }
}
