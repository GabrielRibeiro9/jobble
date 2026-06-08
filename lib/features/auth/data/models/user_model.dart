import 'package:flutter_tcc/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    required super.email,
    super.avatarUrl,
    super.professionalProfileId,
    super.professionalProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    ProfessionalProfileData? profileData;
    if (json['professionalProfile'] != null) {
      final pp = json['professionalProfile'] as Map<String, dynamic>;
      profileData = ProfessionalProfileData(
        id: pp['id'] as String?,
        tags: pp['tags'] as String?,
        bio: pp['bio'] as String?,
        rating: (pp['rating'] as num?)?.toDouble() ?? 5.0,
      );
    }

    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      professionalProfileId: json['professionalProfile'] != null 
          ? json['professionalProfile']['id'] as String?
          : null,
      professionalProfile: profileData,
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
