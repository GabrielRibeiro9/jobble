import 'package:equatable/equatable.dart';

class OrganizationData extends Equatable {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final String? tags;
  final String? bio;
  final double rating;
  final int projectsCount;
  final int matchesCount;

  const OrganizationData({
    this.id,
    this.name,
    this.avatarUrl,
    this.tags,
    this.bio,
    this.rating = 5.0,
    this.projectsCount = 0,
    this.matchesCount = 0,
  });

  bool get isComplete => tags != null && tags!.isNotEmpty && bio != null && bio!.isNotEmpty;

  @override
  List<Object?> get props => [id, name, avatarUrl, tags, bio, rating, projectsCount, matchesCount];
}

class User extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? avatarUrl;
  final String? organizationId;
  final OrganizationData? organization;

  const User({
    required this.id,
    this.name,
    required this.email,
    this.avatarUrl,
    this.organizationId,
    this.organization,
  });

  bool get isOnboardingComplete => organization?.isComplete ?? false;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, organizationId, organization];
}
