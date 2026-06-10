class ProjectModel {
  final String id;
  final String? title;
  final String? description;
  final List<String> photoUrls;
  final String? city;
  final String? state;
  final String? completionDate;

  const ProjectModel({
    required this.id,
    this.title,
    this.description,
    this.photoUrls = const [],
    this.city,
    this.state,
    this.completionDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      city: json['city'] as String?,
      state: json['state'] as String?,
      completionDate: json['completionDate'] as String?,
    );
  }
}
