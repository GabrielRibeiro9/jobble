import 'package:equatable/equatable.dart';

class ProfessionalProfileData extends Equatable {
  final String? id;
  final String? tags;
  final String? bio;
  final double rating;

  const ProfessionalProfileData({
    this.id,
    this.tags,
    this.bio,
    this.rating = 5.0,
  });

  bool get isComplete => tags != null && tags!.isNotEmpty && bio != null && bio!.isNotEmpty;

  @override
  List<Object?> get props => [id, tags, bio, rating];
}

class User extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? avatarUrl;
  final String? professionalProfileId;
  final ProfessionalProfileData? professionalProfile;

  const User({
    required this.id,
    this.name,
    required this.email,
    this.avatarUrl,
    this.professionalProfileId,
    this.professionalProfile,
  });

  bool get isOnboardingComplete => professionalProfile?.isComplete ?? false;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, professionalProfileId, professionalProfile];
}
