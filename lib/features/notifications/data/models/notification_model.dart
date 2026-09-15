class NotificationModel {
  final String id;
  final String organizationId;
  final String type; // 'MATCH' | 'PROPOSAL_APPROVED'
  final String title;
  final String personName;
  final String? serviceRequestId;

  /// Preenchido nos avisos de contrato (`CONTRACT_*` e na contratação).
  final String? contractId;
  final bool isUnread;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.organizationId,
    required this.type,
    required this.title,
    required this.personName,
    this.serviceRequestId,
    this.contractId,
    required this.isUnread,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      personName: json['personName'] as String,
      serviceRequestId: json['serviceRequestId'] as String?,
      contractId: json['contractId'] as String?,
      isUnread: json['isUnread'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
