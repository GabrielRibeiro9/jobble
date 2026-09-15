class SignupRequest {
  final String? name;
  final String email;
  final String password;
  final String? cpf;
  final String? phone;

  /// ISO 8601.
  final String? birthDate;

  SignupRequest({
    this.name,
    required this.email,
    required this.password,
    this.cpf,
    this.phone,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'cpf': ?cpf,
      'phone': ?phone,
      'birthDate': ?birthDate,
    };
  }
}
