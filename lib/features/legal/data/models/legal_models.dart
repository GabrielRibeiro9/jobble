import 'package:equatable/equatable.dart';

/// Situação da verificação de identidade (documento + selfie).
enum IdentityStatus {
  notSubmitted,
  pending,
  approved,
  rejected;

  static IdentityStatus fromJson(String? value) {
    return switch (value) {
      'PENDING' => IdentityStatus.pending,
      'APPROVED' => IdentityStatus.approved,
      'REJECTED' => IdentityStatus.rejected,
      _ => IdentityStatus.notSubmitted,
    };
  }

  String get label => switch (this) {
    IdentityStatus.notSubmitted => 'Não enviada',
    IdentityStatus.pending => 'Em análise',
    IdentityStatus.approved => 'Verificada',
    IdentityStatus.rejected => 'Recusada',
  };
}

/// Se uma parte pode assinar contrato, e o que falta se não pode.
///
/// Vem pronto do backend (`legal-readiness.ts`): o app só desenha. Assim o
/// checklist que o usuário vê é exatamente a regra que vai barrá-lo ou não.
class PartyReadiness extends Equatable {
  const PartyReadiness({
    required this.ready,
    required this.profileComplete,
    required this.identityStatus,
    this.rejectionReason,
    this.missing = const [],
  });

  final bool ready;
  final bool profileComplete;
  final IdentityStatus identityStatus;
  final String? rejectionReason;

  /// Campos do cadastro que faltam, em rótulos prontos.
  final List<String> missing;

  static const empty = PartyReadiness(
    ready: false,
    profileComplete: false,
    identityStatus: IdentityStatus.notSubmitted,
  );

  factory PartyReadiness.fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return PartyReadiness(
      ready: json['ready'] as bool? ?? false,
      profileComplete: json['profileComplete'] as bool? ?? false,
      identityStatus: IdentityStatus.fromJson(json['identityStatus'] as String?),
      rejectionReason: json['rejectionReason'] as String?,
      missing: (json['missing'] as List? ?? const []).cast<String>(),
    );
  }

  /// Tudo o que falta, incluindo a identidade, numa lista só.
  List<String> get pendingItems => [
    ...missing,
    if (identityStatus != IdentityStatus.approved)
      switch (identityStatus) {
        IdentityStatus.pending => 'Verificação de identidade (em análise)',
        IdentityStatus.rejected => 'Verificação de identidade (reenviar)',
        _ => 'Verificação de identidade',
      },
  ];

  @override
  List<Object?> get props => [
    ready,
    profileComplete,
    identityStatus,
    rejectionReason,
    missing,
  ];
}

class LegalAddress extends Equatable {
  const LegalAddress({
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
  });

  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  static LegalAddress? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return LegalAddress(
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'complement': (complement?.trim().isEmpty ?? true) ? null : complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zipCode': zipCode,
  };

  String get shortLabel => '$street, $number — $city/$state';

  @override
  List<Object?> get props => [
    street,
    number,
    complement,
    neighborhood,
    city,
    state,
    zipCode,
  ];
}

enum MaritalStatus {
  single('SINGLE', 'Solteiro(a)'),
  married('MARRIED', 'Casado(a)'),
  stableUnion('STABLE_UNION', 'União estável'),
  divorced('DIVORCED', 'Divorciado(a)'),
  separated('SEPARATED', 'Separado(a)'),
  widowed('WIDOWED', 'Viúvo(a)');

  const MaritalStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static MaritalStatus? fromJson(String? value) {
    for (final status in values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }
}

enum IdentityDocumentType {
  rg('RG', 'RG'),
  cnh('CNH', 'CNH'),
  passport('PASSPORT', 'Passaporte');

  const IdentityDocumentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Só o RG exige o verso — é nele que ficam CPF e filiação.
  bool get needsBack => this == IdentityDocumentType.rg;
}

/// Dados cadastrais da própria pessoa (`GET /users/me/legal-profile`).
class UserLegalProfile extends Equatable {
  const UserLegalProfile({
    required this.id,
    required this.email,
    required this.readiness,
    this.name,
    this.cpf,
    this.birthDate,
    this.phone,
    this.nationality,
    this.maritalStatus,
    this.profession,
    this.address,
    this.identityStatus = IdentityStatus.notSubmitted,
    this.identityRejectionReason,
  });

  final String id;
  final String email;
  final String? name;
  final String? cpf;
  final DateTime? birthDate;
  final String? phone;
  final String? nationality;
  final MaritalStatus? maritalStatus;
  final String? profession;
  final LegalAddress? address;
  final IdentityStatus identityStatus;
  final String? identityRejectionReason;
  final PartyReadiness readiness;

  /// Nome, CPF e nascimento são o que a verificação conferiu: travados
  /// enquanto ela está em análise ou depois de aprovada.
  bool get verifiedDataLocked =>
      identityStatus == IdentityStatus.pending ||
      identityStatus == IdentityStatus.approved;

  factory UserLegalProfile.fromJson(Map<String, dynamic> json) {
    final identity = json['identity'] as Map<String, dynamic>?;
    final birth = json['birthDate'] as String?;

    return UserLegalProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      birthDate: birth == null ? null : DateTime.tryParse(birth)?.toUtc(),
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      maritalStatus: MaritalStatus.fromJson(json['maritalStatus'] as String?),
      profession: json['profession'] as String?,
      address: LegalAddress.fromJson(json['address'] as Map<String, dynamic>?),
      identityStatus: IdentityStatus.fromJson(identity?['status'] as String?),
      identityRejectionReason: identity?['rejectionReason'] as String?,
      readiness: PartyReadiness.fromJson(
        json['readiness'] as Map<String, dynamic>?,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    cpf,
    birthDate,
    phone,
    nationality,
    maritalStatus,
    profession,
    address,
    identityStatus,
    identityRejectionReason,
    readiness,
  ];
}

enum OrganizationLegalType {
  individual('INDIVIDUAL', 'Autônomo (pessoa física)'),
  company('COMPANY', 'Empresa (CNPJ, inclusive MEI)');

  const OrganizationLegalType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static OrganizationLegalType fromJson(String? value) =>
      value == 'COMPANY' ? company : individual;
}

/// Dados legais da organização (`GET /organizations/legal-profile`).
class OrganizationLegalProfile extends Equatable {
  const OrganizationLegalProfile({
    required this.id,
    required this.tradeName,
    required this.legalType,
    required this.canEdit,
    required this.readiness,
    this.document,
    this.legalName,
    this.phone,
    this.address,
  });

  final String id;
  final String tradeName;
  final OrganizationLegalType legalType;
  final String? document;
  final String? legalName;
  final String? phone;
  final LegalAddress? address;
  final bool canEdit;
  final PartyReadiness readiness;

  factory OrganizationLegalProfile.fromJson(Map<String, dynamic> json) {
    return OrganizationLegalProfile(
      id: json['id'] as String? ?? '',
      tradeName: json['tradeName'] as String? ?? '',
      legalType: OrganizationLegalType.fromJson(json['legalType'] as String?),
      document: json['document'] as String?,
      legalName: json['legalName'] as String?,
      phone: json['phone'] as String?,
      address: LegalAddress.fromJson(json['address'] as Map<String, dynamic>?),
      canEdit: json['canEdit'] as bool? ?? false,
      readiness: PartyReadiness.fromJson(
        json['readiness'] as Map<String, dynamic>?,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    tradeName,
    legalType,
    document,
    legalName,
    phone,
    address,
    canEdit,
    readiness,
  ];
}
