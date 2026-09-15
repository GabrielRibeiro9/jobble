import 'package:get_it/get_it.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_tcc/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_tcc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_tcc/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/resend_verification_code_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/update_organization_profile_usecase.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter_tcc/core/database/database_helper.dart';

import 'package:flutter_tcc/core/services/token_service.dart';

import 'package:flutter_tcc/features/settings/presentation/bloc/config_bloc.dart';
import 'package:flutter_tcc/core/theme/theme_cubit.dart';

import 'package:flutter_tcc/features/home/data/datasources/home_remote_data_source.dart';
import 'package:flutter_tcc/features/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_tcc/features/home/domain/repositories/home_repository.dart';
import 'package:flutter_tcc/features/home/presentation/bloc/home_jobs_bloc.dart';

import 'package:flutter_tcc/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_tcc/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_tcc/features/bids/data/datasources/bid_remote_data_source.dart';
import 'package:flutter_tcc/features/contracts/data/datasources/contract_remote_data_source.dart';
import 'package:flutter_tcc/features/contracts/domain/contract_repository.dart';
import 'package:flutter_tcc/features/legal/data/datasources/legal_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
      verifyEmailUseCase: sl(),
      completeOnboardingUseCase: sl(),
      resendVerificationCodeUseCase: sl(),
      getMeUseCase: sl(),
      updateOrganizationProfileUseCase: sl(),
      tokenService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignupUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(repository: sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(repository: sl()));
  sl.registerLazySingleton(() => ResendVerificationCodeUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMeUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateOrganizationProfileUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Features - Home
  // Bloc
  sl.registerFactory(() => HomeJobsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dioClient: sl()),
  );

  // Core
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => DioClient(tokenService: sl()));
  sl.registerLazySingleton(() => TokenService());
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => ConfigBloc());

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioClient: sl()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(dioClient: sl()),
  );

  // Bids
  sl.registerLazySingleton<BidRemoteDataSource>(
    () => BidRemoteDataSource(dioClient: sl()),
  );

  // Cadastro legal e identidade
  sl.registerLazySingleton<LegalRemoteDataSource>(
    () => LegalRemoteDataSource(dioClient: sl()),
  );

  // Contratos. Registrado pela abstração para os cubits poderem ser testados
  // com um repositório falso.
  sl.registerLazySingleton<ContractRepository>(
    () => ContractRemoteDataSource(dioClient: sl()),
  );
}
