import 'package:equatable/equatable.dart';

import 'package:flutter_tcc/features/bids/data/models/service_request_detail_model.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';

/// Etapa de um trabalho, na linguagem do profissional — do chamado que chegou
/// ao serviço concluído. Junta o estado do match com o do contrato, que é o
/// que manda depois que o cliente escolhe.
enum JobStage {
  awaitingResponse,
  awaitingClient,
  contractToFill,
  awaitingSignatures,
  inProgress,
  completed,
  closed;

  String get label => switch (this) {
    JobStage.awaitingResponse => 'Responder',
    JobStage.awaitingClient => 'Aguardando o cliente',
    JobStage.contractToFill => 'Contrato a preencher',
    JobStage.awaitingSignatures => 'Aguardando assinaturas',
    JobStage.inProgress => 'Em andamento',
    JobStage.completed => 'Concluído',
    JobStage.closed => 'Encerrado',
  };

  /// Fechado com o cliente e ainda não terminado.
  bool get isOpenWork =>
      this == JobStage.contractToFill ||
      this == JobStage.awaitingSignatures ||
      this == JobStage.inProgress;
}

/// O contrato do trabalho, quando o cliente já escolheu o profissional.
class OrgMatchContract extends Equatable {
  const OrgMatchContract({
    required this.id,
    required this.code,
    required this.status,
    this.priceCents,
    this.startDate,
  });

  final String id;
  final String code;
  final ContractStatus status;
  final int? priceCents;
  final DateTime? startDate;

  static OrgMatchContract? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return OrgMatchContract(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: ContractStatus.fromJson(json['status'] as String?),
      priceCents: (json['priceCents'] as num?)?.toInt(),
      startDate: _date(json['startDate']),
    );
  }

  @override
  List<Object?> get props => [id, code, status, priceCents, startDate];
}

/// Um chamado recebido pela organização, como `GET /matches` devolve.
///
/// Os dados do cliente seguem o funil: antes de ele escolher este
/// profissional, só há bairro, cidade e distância — [clientName] e
/// [addressLine] ficam nulos.
class OrgMatch extends Equatable {
  const OrgMatch({
    required this.id,
    required this.status,
    required this.distanceKm,
    required this.createdAt,
    required this.requestId,
    required this.description,
    required this.isEmergency,
    required this.clientRevealed,
    this.bidValue,
    this.proposedDate,
    this.respondedAt,
    this.title,
    this.categoryLabel,
    this.scheduledAt,
    this.clientName,
    this.location,
    this.addressLine,
    this.contract,
  });

  final String id;
  final MatchStatus status;
  final double distanceKm;
  final double? bidValue;
  final DateTime? proposedDate;
  final DateTime? respondedAt;
  final DateTime createdAt;

  final String requestId;
  final String? title;
  final String description;
  final String? categoryLabel;
  final bool isEmergency;
  final DateTime? scheduledAt;

  final bool clientRevealed;
  final String? clientName;

  /// "Pinheiros, São Paulo - SP" — sempre disponível.
  final String? location;

  /// "Rua dos Pinheiros, 1200" — só depois da escolha.
  final String? addressLine;

  final OrgMatchContract? contract;

  factory OrgMatch.fromJson(Map<String, dynamic> json) {
    final request = json['request'] as Map<String, dynamic>? ?? const {};
    final client = json['client'] as Map<String, dynamic>? ?? const {};
    final address = json['address'] as Map<String, dynamic>?;
    final revealed = json['clientRevealed'] as bool? ?? false;
    final street = address?['street'] as String?;

    return OrgMatch(
      id: json['id'] as String? ?? '',
      status: MatchStatus.fromJson(json['status'] as String?),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      bidValue: (json['bidValue'] as num?)?.toDouble(),
      proposedDate: _date(json['proposedDate']),
      respondedAt: _date(json['respondedAt']),
      createdAt: _date(json['createdAt']) ?? DateTime.now(),
      requestId: request['id'] as String? ?? '',
      title: request['title'] as String?,
      description: request['description'] as String? ?? '',
      categoryLabel: request['categoryLabel'] as String?,
      isEmergency: request['isEmergency'] as bool? ?? false,
      scheduledAt: _date(request['scheduledAt']),
      clientRevealed: revealed,
      clientName: revealed ? client['name'] as String? : null,
      location: json['location'] as String?,
      addressLine: revealed && street != null
          ? '$street, ${address?['number'] ?? 's/n'}'
          : null,
      contract: OrgMatchContract.fromJson(
        json['contract'] as Map<String, dynamic>?,
      ),
    );
  }

  String get displayTitle {
    final value = title?.trim();
    if (value != null && value.isNotEmpty) return value;
    if (categoryLabel != null) return categoryLabel!;
    return description.length > 60
        ? '${description.substring(0, 60)}…'
        : description;
  }

  /// Há uma data combinada ou pedida para o trabalho.
  bool get hasAgreedDate =>
      contract?.startDate != null || proposedDate != null || scheduledAt != null;

  /// Quando o trabalho acontece — ou, sem data, quando o chamado chegou.
  DateTime get when =>
      contract?.startDate ?? proposedDate ?? scheduledAt ?? createdAt;

  /// Valor combinado: o do contrato, ou o da devolutiva.
  double? get value {
    final cents = contract?.priceCents;
    return cents != null ? cents / 100 : bidValue;
  }

  JobStage get stage {
    switch (status) {
      case MatchStatus.pending:
        return JobStage.awaitingResponse;
      case MatchStatus.accepted:
        return JobStage.awaitingClient;
      case MatchStatus.declined:
      case MatchStatus.rejected:
      case MatchStatus.ignored:
        return JobStage.closed;
      case MatchStatus.hired:
        return switch (contract?.status) {
          null ||
          ContractStatus.draft ||
          ContractStatus.changesRequested => JobStage.contractToFill,
          ContractStatus.pendingSignatures => JobStage.awaitingSignatures,
          ContractStatus.signed ||
          ContractStatus.awaitingConfirmation => JobStage.inProgress,
          ContractStatus.completed => JobStage.completed,
          ContractStatus.canceled ||
          ContractStatus.terminated => JobStage.closed,
        };
    }
  }

  @override
  List<Object?> get props => [
    id,
    status,
    distanceKm,
    bidValue,
    proposedDate,
    respondedAt,
    createdAt,
    requestId,
    title,
    description,
    categoryLabel,
    isEmergency,
    scheduledAt,
    clientRevealed,
    clientName,
    location,
    addressLine,
    contract,
  ];
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
