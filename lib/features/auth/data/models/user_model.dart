import 'package:flutter_tcc/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    required super.email,
    super.avatarUrl,
    super.professionalProfileId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      professionalProfileId: json['professionalProfile'] != null 
          ? json['professionalProfile']['id'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'professionalProfile': professionalProfileId != null 
          ? {'id': professionalProfileId}
          : null,
    };
  }
}
