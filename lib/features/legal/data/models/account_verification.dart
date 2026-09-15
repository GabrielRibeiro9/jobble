import 'package:equatable/equatable.dart';

import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

/// Se a conta pode usar o app, e o que falta se não pode.
///
/// Vem pronto de `GET /users/profile` (`assessAccount` no backend). O
/// profissional só recebe chamados com cadastro completo, identidade e
/// certidão de antecedentes aprovadas — e o servidor aplica a mesma regra em
/// todas as rotas de chamado e contrato; aqui o app só decide o que mostrar.
class AccountVerification extends Equatable {
  const AccountVerification({
    required this.clientReady,
    required this.providerReady,
    required this.profileComplete,
    required this.identityStatus,
    this.identityRejectionReason,
    this.backgroundCheckStatus,
    this.backgroundCheckRejectionReason,
    this.missing = const [],
  });

  /// Resposta de um backend anterior à verificação obrigatória, que não manda
  /// o campo. A exigência mora no servidor; sem o campo, o app não tem como
  /// saber o que falta e não bloqueia a entrada.
  static const legacy = AccountVerification(
    clientReady: true,
    providerReady: true,
    profileComplete: true,
    identityStatus: IdentityStatus.approved,
    backgroundCheckStatus: IdentityStatus.approved,
  );

  final bool clientReady;
  final bool? providerReady;
  final bool profileComplete;
  final IdentityStatus identityStatus;
  final String? identityRejectionReason;

  /// `null` para quem não tem organização — a certidão é só do profissional.
  final IdentityStatus? backgroundCheckStatus;
  final String? backgroundCheckRejectionReason;
  final List<String> missing;

  factory AccountVerification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return legacy;

    final background = json['backgroundCheckStatus'] as String?;

    return AccountVerification(
      clientReady: json['clientReady'] as bool? ?? false,
      providerReady: json['providerReady'] as bool?,
      profileComplete: json['profileComplete'] as bool? ?? false,
      identityStatus: IdentityStatus.fromJson(json['identityStatus'] as String?),
      identityRejectionReason: json['identityRejectionReason'] as String?,
      backgroundCheckStatus: background == null
          ? null
          : IdentityStatus.fromJson(background),
      backgroundCheckRejectionReason:
          json['backgroundCheckRejectionReason'] as String?,
      missing: (json['missing'] as List? ?? const []).cast<String>(),
    );
  }

  /// Profissional liberado para receber e negociar chamados.
  bool get canWork => providerReady == true;

  /// No formato do [ReadinessCard]: o que falta, com a certidão junto.
  PartyReadiness get readiness => PartyReadiness(
    ready: canWork,
    profileComplete: profileComplete,
    identityStatus: identityStatus,
    rejectionReason: identityRejectionReason,
    missing: [
      ...missing,
      if (backgroundCheckStatus != IdentityStatus.approved)
        'Certidão de antecedentes: '
            '${(backgroundCheckStatus ?? IdentityStatus.notSubmitted).certificateLabel.toLowerCase()}',
    ],
  );

  @override
  List<Object?> get props => [
    clientReady,
    providerReady,
    profileComplete,
    identityStatus,
    identityRejectionReason,
    backgroundCheckStatus,
    backgroundCheckRejectionReason,
    missing,
  ];
}

/// A certidão de antecedentes enviada, como `GET /background-check` devolve.
class BackgroundCheckInfo extends Equatable {
  const BackgroundCheckInfo({
    required this.status,
    this.issuedAt,
    this.rejectionReason,
  });

  final IdentityStatus status;
  final DateTime? issuedAt;
  final String? rejectionReason;

  factory BackgroundCheckInfo.fromJson(Map<String, dynamic> json) {
    final issued = json['issuedAt'] as String?;
    return BackgroundCheckInfo(
      status: IdentityStatus.fromJson(json['status'] as String?),
      issuedAt: issued == null ? null : DateTime.tryParse(issued)?.toLocal(),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  /// Pode (re)enviar: nunca enviou ou foi recusada.
  bool get canSubmit =>
      status == IdentityStatus.notSubmitted ||
      status == IdentityStatus.rejected;

  @override
  List<Object?> get props => [status, issuedAt, rejectionReason];
}

extension CertificateStatusLabel on IdentityStatus {
  /// A certidão é "aprovada", não "verificada" como a identidade.
  String get certificateLabel => switch (this) {
    IdentityStatus.notSubmitted => 'Não enviada',
    IdentityStatus.pending => 'Em análise',
    IdentityStatus.approved => 'Aprovada',
    IdentityStatus.rejected => 'Recusada',
  };
}
