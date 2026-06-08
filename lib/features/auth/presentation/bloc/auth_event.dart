import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignupSubmitted extends AuthEvent {
  final String? name;
  final String email;
  final String password;
  final String? cpf;

  const SignupSubmitted({
    this.name,
    required this.email,
    required this.password,
    this.cpf,
  });

  @override
  List<Object?> get props => [name, email, password, cpf];
}

class EmailVerificationSubmitted extends AuthEvent {
  final String email;
  final String code;

  const EmailVerificationSubmitted({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class CompleteOnboardingSubmitted extends AuthEvent {
  final String name;
  final String cpf;

  const CompleteOnboardingSubmitted({required this.name, required this.cpf});

  @override
  List<Object?> get props => [name, cpf];
}

class UpdateProfessionalProfileSubmitted extends AuthEvent {
  final String tags;
  final String bio;

  const UpdateProfessionalProfileSubmitted({required this.tags, required this.bio});

  @override
  List<Object> get props => [tags, bio];
}

class ResendVerificationEmailRequested extends AuthEvent {
  final String email;

  const ResendVerificationEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class UserRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class ConnectionErrorLogoutRequested extends AuthEvent {}
