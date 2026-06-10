import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/resend_verification_code_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/update_organization_profile_usecase.dart';

import 'package:flutter_tcc/core/services/token_service.dart';

import 'package:flutter_tcc/features/auth/data/models/user_model.dart';
import 'package:flutter_tcc/features/auth/domain/entities/user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;
  final ResendVerificationCodeUseCase resendVerificationCodeUseCase;
  final GetMeUseCase getMeUseCase;
  final UpdateOrganizationProfileUseCase updateOrganizationProfileUseCase;
  final TokenService tokenService;

  AuthBloc({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.verifyEmailUseCase,
    required this.completeOnboardingUseCase,
    required this.resendVerificationCodeUseCase,
    required this.getMeUseCase,
    required this.updateOrganizationProfileUseCase,
    required this.tokenService,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<EmailVerificationSubmitted>(_onEmailVerificationSubmitted);
    on<CompleteOnboardingSubmitted>(_onCompleteOnboardingSubmitted);
    on<UpdateOrganizationProfileSubmitted>(_onUpdateOrganizationProfileSubmitted);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<UserRequested>(_onUserRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ConnectionErrorLogoutRequested>(_onConnectionErrorLogoutRequested);
    on<OrganizationAvatarUpdated>(_onOrganizationAvatarUpdated);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenService.deleteToken();
    emit(AuthInitial());
  }

  Future<void> _onConnectionErrorLogoutRequested(
    ConnectionErrorLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenService.deleteToken();
    emit(const AuthFailure(message: 'Conexão perdida. Faça login novamente.'));
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await resendVerificationCodeUseCase.execute(event.email);
    } catch (e) {
      // Fail silently for automatic triggers
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase.execute(event.email, event.password);
      await tokenService.saveToken(result.accessToken);
      
      final user = await getMeUseCase.execute();
      emit(AuthSuccess(accessToken: result.accessToken, user: user));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signupUseCase.execute(
        event.name,
        event.email,
        event.password,
        cpf: event.cpf,
      );
      emit(AuthSignupStep1Success());
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  Future<void> _onEmailVerificationSubmitted(
    EmailVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await verifyEmailUseCase.execute(event.email, event.code);
      emit(AuthVerificationSuccess());
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  Future<void> _onCompleteOnboardingSubmitted(
    CompleteOnboardingSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await completeOnboardingUseCase.execute(
        event.organizationName,
        description: event.description,
      );
      final token = await tokenService.getToken();
      if (token != null) {
        final user = await getMeUseCase.execute();
        emit(AuthSuccess(accessToken: token, user: user));
      }
      emit(AuthOnboardingSuccess());
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  Future<void> _onUpdateOrganizationProfileSubmitted(
    UpdateOrganizationProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await updateOrganizationProfileUseCase.execute(event.tags, event.bio);
      final user = await getMeUseCase.execute();
      final currentState = state;
      if (currentState is AuthSuccess) {
        emit(AuthSuccess(accessToken: currentState.accessToken, user: user));
      }
      emit(AuthOnboardingSuccess());
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }

  Future<void> _onUserRequested(
    UserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    String? token;
    
    if (currentState is AuthSuccess) {
      token = currentState.accessToken;
    } else {
      token = await tokenService.getToken();
    }

    if (token != null) {
      try {
        final user = await getMeUseCase.execute();
        emit(AuthSuccess(accessToken: token, user: user));
      } catch (e) {
        await tokenService.deleteToken();
        emit(AuthInitial());
      }
    } else {
      await tokenService.deleteToken();
      emit(AuthInitial());
    }
  }

  void _onOrganizationAvatarUpdated(
    OrganizationAvatarUpdated event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthSuccess && currentState.user != null) {
      final user = currentState.user!;
      final org = user.organization;
      final updatedOrg = org != null
          ? OrganizationData(
              id: org.id,
              name: org.name,
              avatarUrl: event.avatarUrl,
              tags: org.tags,
              bio: org.bio,
              rating: org.rating,
              projectsCount: org.projectsCount,
              matchesCount: org.matchesCount,
            )
          : null;
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        organizationId: user.organizationId,
        organization: updatedOrg,
      );
      emit(AuthSuccess(accessToken: currentState.accessToken, user: updatedUser));
    }
  }
}
