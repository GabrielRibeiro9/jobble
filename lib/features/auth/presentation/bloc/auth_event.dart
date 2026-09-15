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
  final String? phone;

  /// ISO 8601.
  final String? birthDate;

  const SignupSubmitted({
    this.name,
    required this.email,
    required this.password,
    this.cpf,
    this.phone,
    this.birthDate,
  });

  @override
  List<Object?> get props => [name, email, password, cpf, phone, birthDate];
}

class EmailVerificationSubmitted extends AuthEvent {
  final String email;
  final String code;

  const EmailVerificationSubmitted({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class CompleteOnboardingSubmitted extends AuthEvent {
  final String organizationName;
  final String? description;

  /// `INDIVIDUAL` ou `COMPANY`.
  final String? legalType;

  /// CNPJ, só dígitos, quando empresa.
  final String? document;
  final String? legalName;

  const CompleteOnboardingSubmitted({
    required this.organizationName,
    this.description,
    this.legalType,
    this.document,
    this.legalName,
  });

  @override
  List<Object?> get props => [
    organizationName,
    description,
    legalType,
    document,
    legalName,
  ];
}

class UpdateOrganizationProfileSubmitted extends AuthEvent {
  final String tags;
  final String bio;

  const UpdateOrganizationProfileSubmitted({required this.tags, required this.bio});

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

class OrganizationAvatarUpdated extends AuthEvent {
  final String avatarUrl;

  const OrganizationAvatarUpdated(this.avatarUrl);

  @override
  List<Object> get props => [avatarUrl];
}
