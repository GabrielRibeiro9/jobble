import 'package:flutter_tcc/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    required super.email,
    super.avatarUrl,
    super.organizationId,
    super.organization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    OrganizationData? orgData;
    if (json['organization'] != null) {
      final org = json['organization'] as Map<String, dynamic>;
      orgData = OrganizationData(
        id: org['id'] as String?,
        name: org['name'] as String?,
        avatarUrl: org['avatarUrl'] as String?,
        tags: org['tags'] as String?,
        bio: org['bio'] as String?,
        rating: (org['rating'] as num?)?.toDouble() ?? 5.0,
        projectsCount: org['projectsCount'] as int? ?? 0,
        matchesCount: org['matchesCount'] as int? ?? 0,
      );
    }

    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      organizationId: orgData?.id,
      organization: orgData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'organization': organizationId != null 
          ? {'id': organizationId}
          : null,
    };
  }
}
