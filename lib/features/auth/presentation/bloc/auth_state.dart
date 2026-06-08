import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String accessToken;
  final User? user;

  const AuthSuccess({required this.accessToken, this.user});

  @override
  List<Object?> get props => [accessToken, user];
}

class AuthFailure extends AuthState {
  final String message;
  final bool isConnectionError;

  const AuthFailure({required this.message, this.isConnectionError = false});

  @override
  List<Object> get props => [message, isConnectionError];
}

class AuthSignupStep1Success extends AuthState {}

class AuthVerificationSuccess extends AuthState {}

class AuthOnboardingSuccess extends AuthState {}
