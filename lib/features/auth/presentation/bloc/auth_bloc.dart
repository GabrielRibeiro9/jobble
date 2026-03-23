import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_tcc/features/auth/domain/usecases/signup_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;

  AuthBloc({required this.loginUseCase, required this.signupUseCase})
    : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase.execute(event.email, event.password);
      emit(AuthSuccess(accessToken: result.accessToken));
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
      final result = await signupUseCase.execute(
        event.name,
        event.email,
        event.password,
      );
      emit(AuthSuccess(accessToken: result.accessToken));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(message: message));
    }
  }
}
