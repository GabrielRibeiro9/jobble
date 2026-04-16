import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? avatarUrl;
  final String? professionalProfileId;

  const User({
    required this.id,
    this.name,
    required this.email,
    this.avatarUrl,
    this.professionalProfileId,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, professionalProfileId];
}
