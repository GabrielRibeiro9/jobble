class ServiceRequestDetailModel {
  final String id;
  final String description;
  final String status;
  final bool isEmergency;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final ClientInfo client;
  final AddressInfo? address;
  final List<MatchInfo> professionalMatches;

  ServiceRequestDetailModel({
    required this.id,
    required this.description,
    required this.status,
    required this.isEmergency,
    this.scheduledAt,
    required this.createdAt,
    required this.client,
    this.address,
    required this.professionalMatches,
  });

  factory ServiceRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestDetailModel(
      id: json['id'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      isEmergency: json['isEmergency'] as bool,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      client: ClientInfo.fromJson(json['client'] as Map<String, dynamic>),
      address: json['address'] != null
          ? AddressInfo.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      professionalMatches: (json['professionalMatches'] as List)
          .map((e) => MatchInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClientInfo {
  final String id;
  final String? name;
  final String email;

  ClientInfo({
    required this.id,
    this.name,
    required this.email,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
    );
  }
}

class AddressInfo {
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;

  AddressInfo({
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      street: json['street'] as String,
      number: json['number'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class MatchInfo {
  final String id;
  final String status;
  final double? bidValue;
  final String? serviceType;
  final DateTime? proposedDate;
  final double? similarityScore;
  final double? distanceKm;

  MatchInfo({
    required this.id,
    required this.status,
    this.bidValue,
    this.serviceType,
    this.proposedDate,
    this.similarityScore,
    this.distanceKm,
  });

  factory MatchInfo.fromJson(Map<String, dynamic> json) {
    return MatchInfo(
      id: json['id'] as String,
      status: json['status'] as String,
      bidValue: (json['bidValue'] as num?)?.toDouble(),
      serviceType: json['serviceType'] as String?,
      proposedDate: json['proposedDate'] != null
          ? DateTime.parse(json['proposedDate'] as String)
          : null,
      similarityScore: (json['similarityScore'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
}
