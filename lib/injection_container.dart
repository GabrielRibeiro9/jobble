import 'package:get_it/get_it.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_tcc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter_tcc/core/services/token_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignupUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  // Core
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => TokenService());
}
