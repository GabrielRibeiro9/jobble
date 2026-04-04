class SignupRequest {
  final String? name;
  final String email;
  final String password;
  final String? cpf;

  SignupRequest({
    this.name,
    required this.email,
    required this.password,
    this.cpf,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
    };
  }
}
