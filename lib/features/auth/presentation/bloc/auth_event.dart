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
