/// Um chamado na visão do profissional, como `GET /service-requests/:id`
/// devolve.
///
/// O que ele sabe do cliente depende do funil: antes de ser escolhido, só o
/// serviço, a região (bairro e cidade) e a distância — [clientRevealed] fica
/// falso, e nome, e-mail, rua e número nem chegam do servidor.
class ServiceRequestDetailModel {
  final String id;
  final String description;
  final String? categoryLabel;
  final String status;
  final bool isEmergency;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final bool clientRevealed;
  final ClientInfo client;
  final AddressInfo? address;

  /// "Pinheiros, São Paulo - SP".
  final String? location;
  final List<MatchInfo> professionalMatches;

  ServiceRequestDetailModel({
    required this.id,
    required this.description,
    this.categoryLabel,
    required this.status,
    required this.isEmergency,
    this.scheduledAt,
    required this.createdAt,
    required this.clientRevealed,
    required this.client,
    this.address,
    this.location,
    required this.professionalMatches,
  });

  factory ServiceRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestDetailModel(
      id: json['id'] as String,
      description: json['description'] as String,
      categoryLabel: json['categoryLabel'] as String?,
      status: json['status'] as String,
      isEmergency: json['isEmergency'] as bool,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Backend anterior à regra de privacidade não manda o campo, mas
      // manda o nome: nesse caso, o que veio é o que há.
      clientRevealed:
          json['clientRevealed'] as bool? ??
          (json['client'] as Map<String, dynamic>?)?['name'] != null,
      client: ClientInfo.fromJson(json['client'] as Map<String, dynamic>),
      address: json['address'] != null
          ? AddressInfo.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      location: json['location'] as String?,
      professionalMatches: (json['professionalMatches'] as List)
          .map((e) => MatchInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClientInfo {
  final String? id;
  final String? name;
  final String? email;

  /// O cliente teve a identidade verificada (documento + selfie). Aparece
  /// antes e depois da escolha: dizer que é verificado não diz quem é.
  final bool identityVerified;

  ClientInfo({
    this.id,
    this.name,
    this.email,
    this.identityVerified = false,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      identityVerified: json['identityVerified'] as bool? ?? false,
    );
  }
}

/// Resumo do contrato gerado quando o cliente escolhe o profissional.
class MatchContractInfo {
  final String id;
  final String code;
  final String status;

  const MatchContractInfo({
    required this.id,
    required this.code,
    required this.status,
  });

  static MatchContractInfo? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return MatchContractInfo(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'DRAFT',
    );
  }
}

/// Endereço do serviço. Antes da escolha só vêm bairro, cidade e estado
/// ([revealed] falso); rua, número, CEP e coordenadas, depois.
class AddressInfo {
  final bool revealed;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String city;
  final String state;
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  AddressInfo({
    required this.revealed,
    this.street,
    this.number,
    this.neighborhood,
    required this.city,
    required this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      revealed: json['revealed'] as bool? ?? json['street'] != null,
      street: json['street'] as String?,
      number: json['number'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// "Pinheiros, São Paulo - SP", ou "São Paulo - SP" sem bairro.
  String get regionLabel {
    final cityState = '$city - $state';
    final hood = neighborhood?.trim();
    return hood == null || hood.isEmpty ? cityState : '$hood, $cityState';
  }
}

/// Onde o chamado está no funil, do disparo à contratação.
///
/// Os três primeiros estados são decisão do profissional; os três últimos, do
/// cliente. `accepted` aqui é "eu aceitei o chamado", não "o cliente me
/// escolheu" — isso é [MatchStatus.hired].
enum MatchStatus {
  pending,
  declined,
  accepted,
  hired,
  rejected,
  ignored;

  static MatchStatus fromJson(String? value) {
    return switch (value) {
      'DECLINED' => MatchStatus.declined,
      'ACCEPTED' => MatchStatus.accepted,
      'HIRED' => MatchStatus.hired,
      'REJECTED' => MatchStatus.rejected,
      'IGNORED' => MatchStatus.ignored,
      _ => MatchStatus.pending,
    };
  }

  /// O profissional ainda precisa dizer se pega o serviço.
  bool get awaitsDecision => this == MatchStatus.pending;

  /// Aceitou e segue na disputa: é quando a devolutiva faz sentido.
  bool get canBid => this == MatchStatus.accepted;

  /// Saiu do funil — por decisão própria ou porque o cliente escolheu outro.
  bool get isClosed =>
      this == MatchStatus.declined ||
      this == MatchStatus.rejected ||
      this == MatchStatus.ignored;
}

class MatchInfo {
  final String id;
  final MatchStatus status;
  final double? bidValue;
  final String? serviceType;
  final DateTime? proposedDate;
  final DateTime? respondedAt;

  /// Réplica: as dúvidas que o profissional mandou junto da devolutiva.
  final String? proQuestion;

  /// Detalhamento escrito pelo cliente ao escolher este profissional.
  final String? clientDetails;

  final double? similarityScore;
  final double? distanceKm;

  /// Existe a partir da contratação (`HIRED`).
  final MatchContractInfo? contract;

  MatchInfo({
    required this.id,
    required this.status,
    this.bidValue,
    this.serviceType,
    this.proposedDate,
    this.respondedAt,
    this.proQuestion,
    this.clientDetails,
    this.similarityScore,
    this.distanceKm,
    this.contract,
  });

  /// Já mandou alguma devolutiva — valor, dúvidas ou os dois.
  bool get hasBid => bidValue != null || proQuestion != null;

  factory MatchInfo.fromJson(Map<String, dynamic> json) {
    return MatchInfo(
      id: json['id'] as String,
      status: MatchStatus.fromJson(json['status'] as String?),
      bidValue: (json['bidValue'] as num?)?.toDouble(),
      serviceType: json['serviceType'] as String?,
      proposedDate: json['proposedDate'] != null
          ? DateTime.parse(json['proposedDate'] as String)
          : null,
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      proQuestion: json['proQuestion'] as String?,
      clientDetails: json['clientDetails'] as String?,
      similarityScore: (json['similarityScore'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      contract: MatchContractInfo.fromJson(
        json['contract'] as Map<String, dynamic>?,
      ),
    );
  }
}
