import 'package:equatable/equatable.dart';

import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

/// Ciclo de vida do contrato, espelhando `ContractStatus` do backend.
enum ContractStatus {
  draft('DRAFT'),
  changesRequested('CHANGES_REQUESTED'),
  pendingSignatures('PENDING_SIGNATURES'),
  signed('SIGNED'),
  awaitingConfirmation('AWAITING_CONFIRMATION'),
  completed('COMPLETED'),
  canceled('CANCELED'),
  terminated('TERMINATED');

  const ContractStatus(this.apiValue);

  final String apiValue;

  static ContractStatus fromJson(String? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return ContractStatus.draft;
  }

  String get label => switch (this) {
    ContractStatus.draft => 'Rascunho',
    ContractStatus.changesRequested => 'Ajuste pedido',
    ContractStatus.pendingSignatures => 'Aguardando assinaturas',
    ContractStatus.signed => 'Assinado',
    ContractStatus.awaitingConfirmation => 'Aguardando confirmação',
    ContractStatus.completed => 'Concluído',
    ContractStatus.canceled => 'Cancelado',
    ContractStatus.terminated => 'Rescindido',
  };

  bool get isFinal =>
      this == ContractStatus.completed ||
      this == ContractStatus.canceled ||
      this == ContractStatus.terminated;
}

enum ContractParty {
  client('CLIENT', 'Contratante'),
  provider('PROVIDER', 'Contratado');

  const ContractParty(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ContractParty? fromJson(String? value) => switch (value) {
    'CLIENT' => ContractParty.client,
    'PROVIDER' => ContractParty.provider,
    _ => null,
  };
}

/// O que quem está olhando pode fazer agora. Vem calculado pelo backend
/// (`allowedActions`) — os botões da tela saem daqui, sem repetir a regra.
enum ContractAction {
  editTerms('EDIT_TERMS'),
  submit('SUBMIT'),
  requestChanges('REQUEST_CHANGES'),
  sign('SIGN'),
  cancel('CANCEL'),
  markCompleted('MARK_COMPLETED'),
  confirmCompletion('CONFIRM_COMPLETION'),
  disputeCompletion('DISPUTE_COMPLETION'),
  terminate('TERMINATE'),
  download('DOWNLOAD');

  const ContractAction(this.apiValue);

  final String apiValue;

  static ContractAction? fromJson(String? value) {
    for (final action in values) {
      if (action.apiValue == value) return action;
    }
    return null;
  }
}

enum PaymentMethod {
  pix('PIX', 'Pix'),
  cash('CASH', 'Dinheiro'),
  bankTransfer('BANK_TRANSFER', 'Transferência'),
  creditCard('CREDIT_CARD', 'Cartão de crédito'),
  debitCard('DEBIT_CARD', 'Cartão de débito'),
  boleto('BOLETO', 'Boleto'),
  other('OTHER', 'Outra');

  const PaymentMethod(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PaymentMethod? fromJson(String? value) {
    for (final method in values) {
      if (method.apiValue == value) return method;
    }
    return null;
  }
}

enum MaterialsResponsibility {
  provider('PROVIDER', 'Por conta do profissional', 'Incluídos no preço'),
  client('CLIENT', 'Por conta do cliente', 'O cliente compra'),
  shared('SHARED', 'Divididos', 'Descreva a divisão');

  const MaterialsResponsibility(this.apiValue, this.label, this.hint);

  final String apiValue;
  final String label;
  final String hint;

  static MaterialsResponsibility? fromJson(String? value) {
    for (final item in values) {
      if (item.apiValue == value) return item;
    }
    return null;
  }
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

/// Os termos combinados. Preço em centavos, como no backend.
class ContractTerms extends Equatable {
  const ContractTerms({
    required this.scope,
    this.priceCents,
    this.paymentMethod,
    this.paymentTerms,
    this.startDate,
    this.estimatedEndDate,
    this.warrantyDays = 90,
    this.materialsResponsibility,
    this.materialsNotes,
    this.additionalTerms,
  });

  final String scope;
  final int? priceCents;
  final PaymentMethod? paymentMethod;
  final String? paymentTerms;
  final DateTime? startDate;
  final DateTime? estimatedEndDate;
  final int warrantyDays;
  final MaterialsResponsibility? materialsResponsibility;
  final String? materialsNotes;
  final String? additionalTerms;

  factory ContractTerms.fromJson(Map<String, dynamic> json) {
    return ContractTerms(
      scope: json['scope'] as String? ?? '',
      priceCents: (json['priceCents'] as num?)?.toInt(),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
      paymentTerms: json['paymentTerms'] as String?,
      startDate: _date(json['startDate']),
      estimatedEndDate: _date(json['estimatedEndDate']),
      warrantyDays: (json['warrantyDays'] as num?)?.toInt() ?? 90,
      materialsResponsibility: MaterialsResponsibility.fromJson(
        json['materialsResponsibility'] as String?,
      ),
      materialsNotes: json['materialsNotes'] as String?,
      additionalTerms: json['additionalTerms'] as String?,
    );
  }

  /// Corpo de `PUT /contracts/:id/terms`. Vazio vira `null` para o campo ser
  /// limpo de fato, e as datas vão ao meio-dia UTC: um contrato fala em dias,
  /// e meia-noite local viraria o dia anterior em outro fuso.
  Map<String, dynamic> toJson() {
    String? blankToNull(String? value) =>
        (value == null || value.trim().isEmpty) ? null : value.trim();
    String? day(DateTime? date) => date == null
        ? null
        : DateTime.utc(date.year, date.month, date.day, 12).toIso8601String();

    return {
      'scope': scope.trim(),
      'priceCents': priceCents,
      'paymentMethod': paymentMethod?.apiValue,
      'paymentTerms': blankToNull(paymentTerms),
      'startDate': day(startDate),
      'estimatedEndDate': day(estimatedEndDate),
      'warrantyDays': warrantyDays,
      'materialsResponsibility': materialsResponsibility?.apiValue,
      'materialsNotes': blankToNull(materialsNotes),
      'additionalTerms': blankToNull(additionalTerms),
    };
  }

  @override
  List<Object?> get props => [
    scope,
    priceCents,
    paymentMethod,
    paymentTerms,
    startDate,
    estimatedEndDate,
    warrantyDays,
    materialsResponsibility,
    materialsNotes,
    additionalTerms,
  ];
}

class ContractClause extends Equatable {
  const ContractClause({
    required this.number,
    required this.title,
    required this.paragraphs,
  });

  final int number;
  final String title;
  final List<String> paragraphs;

  factory ContractClause.fromJson(Map<String, dynamic> json) => ContractClause(
    number: (json['number'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    paragraphs: (json['paragraphs'] as List? ?? const []).cast<String>(),
  );

  @override
  List<Object?> get props => [number, title, paragraphs];
}

/// O texto do contrato, montado pelo backend a partir do snapshot.
class ContractDocument extends Equatable {
  const ContractDocument({
    required this.title,
    required this.preamble,
    required this.clauses,
    required this.closing,
  });

  final String title;
  final List<String> preamble;
  final List<ContractClause> clauses;
  final List<String> closing;

  static const empty = ContractDocument(
    title: '',
    preamble: [],
    clauses: [],
    closing: [],
  );

  factory ContractDocument.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return ContractDocument(
      title: json['title'] as String? ?? '',
      preamble: (json['preamble'] as List? ?? const []).cast<String>(),
      clauses: (json['clauses'] as List? ?? const [])
          .map((e) => ContractClause.fromJson(e as Map<String, dynamic>))
          .toList(),
      closing: (json['closing'] as List? ?? const []).cast<String>(),
    );
  }

  @override
  List<Object?> get props => [title, preamble, clauses, closing];
}

class ContractSignatureInfo extends Equatable {
  const ContractSignatureInfo({
    required this.party,
    required this.signerName,
    required this.signedAt,
  });

  final ContractParty party;
  final String signerName;
  final DateTime signedAt;

  factory ContractSignatureInfo.fromJson(Map<String, dynamic> json) =>
      ContractSignatureInfo(
        party: ContractParty.fromJson(json['party'] as String?) ??
            ContractParty.client,
        signerName: json['signerName'] as String? ?? '',
        signedAt: _date(json['signedAt']) ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [party, signerName, signedAt];
}

/// O último pedido de ajuste do cliente — é a negociação.
class ContractChangeRequest extends Equatable {
  const ContractChangeRequest({
    required this.message,
    this.counterProposalCents,
    this.requestedAt,
  });

  final String message;
  final int? counterProposalCents;
  final DateTime? requestedAt;

  static ContractChangeRequest? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ContractChangeRequest(
      message: json['message'] as String? ?? '',
      counterProposalCents: (json['counterProposalCents'] as num?)?.toInt(),
      requestedAt: _date(json['requestedAt']),
    );
  }

  @override
  List<Object?> get props => [message, counterProposalCents, requestedAt];
}

/// Um passo da trilha de auditoria.
class ContractEventInfo extends Equatable {
  const ContractEventInfo({
    required this.type,
    required this.createdAt,
    this.party,
    this.message,
  });

  final String type;
  final ContractParty? party;
  final String? message;
  final DateTime createdAt;

  factory ContractEventInfo.fromJson(Map<String, dynamic> json) =>
      ContractEventInfo(
        type: json['type'] as String? ?? '',
        party: ContractParty.fromJson(json['party'] as String?),
        message: json['message'] as String?,
        createdAt: _date(json['createdAt']) ?? DateTime.now(),
      );

  String get label {
    final who = party?.label.toLowerCase();
    return switch (type) {
      'CREATED' => 'Contratação registrada',
      'TERMS_UPDATED' => 'Termos atualizados',
      'SUBMITTED' => 'Enviado para assinatura',
      'CHANGES_REQUESTED' => 'Ajuste pedido pelo contratante',
      'SIGNED' => 'Assinado pelo $who',
      'FULLY_SIGNED' => 'Contrato assinado pelas duas partes',
      'COMPLETION_REQUESTED' => 'Serviço marcado como concluído',
      'COMPLETION_DISPUTED' => 'Conclusão contestada',
      'COMPLETED' => 'Conclusão confirmada',
      'CANCELED' => 'Cancelado pelo $who',
      'TERMINATED' => 'Rescindido pelo $who',
      _ => type,
    };
  }

  @override
  List<Object?> get props => [type, party, message, createdAt];
}

/// O contrato completo, como `GET /contracts/:id` devolve.
class ContractModel extends Equatable {
  const ContractModel({
    required this.id,
    required this.code,
    required this.status,
    required this.version,
    required this.viewerParty,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.clientName,
    required this.organizationName,
    required this.terms,
    required this.document,
    required this.clientReadiness,
    required this.providerReadiness,
    this.serviceRequestId,
    this.organizationAvatarUrl,
    this.missingTerms = const [],
    this.changeRequest,
    this.isPreview = true,
    this.contentHash,
    this.signatures = const [],
    this.allowedActions = const {},
    this.canSign = false,
    this.submittedAt,
    this.signedAt,
    this.providerCompletedAt,
    this.completedAt,
    this.canceledAt,
    this.canceledBy,
    this.cancelReason,
    this.timeline = const [],
  });

  final String id;
  final String code;
  final ContractStatus status;
  final int version;
  final ContractParty viewerParty;
  final String? serviceRequestId;
  final String serviceTitle;
  final String serviceDescription;
  final String clientName;
  final String organizationName;
  final String? organizationAvatarUrl;
  final ContractTerms terms;
  final List<String> missingTerms;
  final ContractChangeRequest? changeRequest;

  /// Texto gerado com os dados atuais (rascunho), não o documento congelado.
  final bool isPreview;

  /// Hash do documento congelado. É o que vai na assinatura.
  final String? contentHash;
  final ContractDocument document;
  final List<ContractSignatureInfo> signatures;
  final PartyReadiness clientReadiness;
  final PartyReadiness providerReadiness;
  final Set<ContractAction> allowedActions;

  /// Do lado profissional, só o dono assina.
  final bool canSign;
  final DateTime? submittedAt;
  final DateTime? signedAt;
  final DateTime? providerCompletedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;
  final ContractParty? canceledBy;
  final String? cancelReason;
  final List<ContractEventInfo> timeline;

  bool can(ContractAction action) => allowedActions.contains(action);

  bool hasSigned(ContractParty party) =>
      signatures.any((signature) => signature.party == party);

  PartyReadiness get myReadiness => viewerParty == ContractParty.client
      ? clientReadiness
      : providerReadiness;

  PartyReadiness get otherReadiness => viewerParty == ContractParty.client
      ? providerReadiness
      : clientReadiness;

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final request = json['serviceRequest'] as Map<String, dynamic>? ?? const {};
    final organization =
        json['organization'] as Map<String, dynamic>? ?? const {};
    final client = json['client'] as Map<String, dynamic>? ?? const {};
    final readiness = json['readiness'] as Map<String, dynamic>? ?? const {};

    return ContractModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: ContractStatus.fromJson(json['status'] as String?),
      version: (json['version'] as num?)?.toInt() ?? 0,
      viewerParty: ContractParty.fromJson(json['viewerParty'] as String?) ??
          ContractParty.provider,
      serviceRequestId: request['id'] as String?,
      serviceTitle:
          (request['title'] as String?) ?? (request['description'] as String? ?? ''),
      serviceDescription: request['description'] as String? ?? '',
      clientName: client['name'] as String? ?? 'Cliente',
      organizationName: organization['name'] as String? ?? 'Profissional',
      organizationAvatarUrl: organization['avatarUrl'] as String?,
      terms: ContractTerms.fromJson(
        json['terms'] as Map<String, dynamic>? ?? const {},
      ),
      missingTerms: (json['missingTerms'] as List? ?? const []).cast<String>(),
      changeRequest: ContractChangeRequest.fromJson(
        json['changeRequest'] as Map<String, dynamic>?,
      ),
      isPreview: json['isPreview'] as bool? ?? true,
      contentHash: json['contentHash'] as String?,
      document: ContractDocument.fromJson(
        json['document'] as Map<String, dynamic>?,
      ),
      signatures: (json['signatures'] as List? ?? const [])
          .map((e) => ContractSignatureInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      clientReadiness: PartyReadiness.fromJson(
        readiness['client'] as Map<String, dynamic>?,
      ),
      providerReadiness: PartyReadiness.fromJson(
        readiness['provider'] as Map<String, dynamic>?,
      ),
      allowedActions: (json['allowedActions'] as List? ?? const [])
          .map((e) => ContractAction.fromJson(e as String?))
          .whereType<ContractAction>()
          .toSet(),
      canSign: json['canSign'] as bool? ?? false,
      submittedAt: _date(json['submittedAt']),
      signedAt: _date(json['signedAt']),
      providerCompletedAt: _date(json['providerCompletedAt']),
      completedAt: _date(json['completedAt']),
      canceledAt: _date(json['canceledAt']),
      canceledBy: ContractParty.fromJson(json['canceledBy'] as String?),
      cancelReason: json['cancelReason'] as String?,
      timeline: (json['timeline'] as List? ?? const [])
          .map((e) => ContractEventInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    status,
    version,
    viewerParty,
    serviceRequestId,
    terms,
    missingTerms,
    changeRequest,
    isPreview,
    contentHash,
    document,
    signatures,
    clientReadiness,
    providerReadiness,
    allowedActions,
    canSign,
    timeline,
  ];
}

/// Linha da lista de contratos.
class ContractSummary extends Equatable {
  const ContractSummary({
    required this.id,
    required this.code,
    required this.status,
    required this.title,
    required this.organizationName,
    required this.clientName,
    required this.needsAttention,
    this.priceCents,
    this.startDate,
    this.updatedAt,
  });

  final String id;
  final String code;
  final ContractStatus status;
  final String title;
  final String organizationName;
  final String clientName;
  final int? priceCents;
  final DateTime? startDate;
  final DateTime? updatedAt;

  /// Há algo esperando quem está olhando (assinar, enviar, confirmar).
  final bool needsAttention;

  factory ContractSummary.fromJson(Map<String, dynamic> json) {
    final organization =
        json['organization'] as Map<String, dynamic>? ?? const {};
    final client = json['client'] as Map<String, dynamic>? ?? const {};

    return ContractSummary(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      status: ContractStatus.fromJson(json['status'] as String?),
      title: json['title'] as String? ?? '',
      organizationName: organization['name'] as String? ?? '',
      clientName: client['name'] as String? ?? 'Cliente',
      priceCents: (json['priceCents'] as num?)?.toInt(),
      startDate: _date(json['startDate']),
      updatedAt: _date(json['updatedAt']),
      needsAttention: json['needsAttention'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, code, status, title, needsAttention];
}
