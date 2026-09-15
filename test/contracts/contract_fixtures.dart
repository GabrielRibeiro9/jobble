/// JSON de contrato no formato que `GET /contracts/:id` devolve.
Map<String, dynamic> contractJson({
  String status = 'DRAFT',
  List<String> actions = const ['EDIT_TERMS', 'SUBMIT', 'CANCEL'],
  String? contentHash,
  List<Map<String, dynamic>> signatures = const [],
  Map<String, dynamic>? changeRequest,
  bool canSign = true,
}) {
  return {
    'id': 'contract-1',
    'code': 'JB-2026-ABCDEF12',
    'status': status,
    'version': contentHash == null ? 0 : 1,
    'viewerParty': 'PROVIDER',
    'serviceRequest': {
      'id': 'request-1',
      'title': 'Troca de fiação',
      'description': 'Trocar a fiação da casa toda.',
      'address': null,
    },
    'client': {'id': 'user-1', 'name': 'Maria da Silva'},
    'organization': {
      'id': 'org-1',
      'name': 'Souza Elétrica',
      'avatarUrl': null,
    },
    'terms': {
      'scope': 'Troca de toda a fiação do apartamento.',
      'priceCents': 150000,
      'paymentMethod': 'PIX',
      'paymentTerms': null,
      'startDate': '2026-09-20T12:00:00.000Z',
      'estimatedEndDate': '2026-09-25T12:00:00.000Z',
      'warrantyDays': 90,
      'materialsResponsibility': 'PROVIDER',
      'materialsNotes': null,
      'additionalTerms': null,
    },
    'missingTerms': <String>[],
    'changeRequest': changeRequest,
    'isPreview': contentHash == null,
    'contentHash': contentHash,
    'document': {
      'title': 'CONTRATO DE PRESTAÇÃO DE SERVIÇOS',
      'preamble': ['Pelo presente instrumento particular…'],
      'clauses': [
        {
          'number': 1,
          'title': 'Do objeto',
          'paragraphs': ['O presente contrato tem por objeto…', 'a) item'],
        },
      ],
      'closing': ['E, por estarem assim justas e contratadas…'],
    },
    'signatures': signatures,
    'readiness': {
      'client': {
        'ready': true,
        'profileComplete': true,
        'identityStatus': 'APPROVED',
        'rejectionReason': null,
        'missing': <String>[],
      },
      'provider': {
        'ready': false,
        'profileComplete': false,
        'identityStatus': 'PENDING',
        'rejectionReason': null,
        'missing': ['Telefone'],
      },
    },
    'allowedActions': actions,
    'canSign': canSign,
    'timeline': [
      {
        'type': 'CREATED',
        'party': 'CLIENT',
        'message': null,
        'createdAt': '2026-09-13T12:00:00.000Z',
      },
    ],
  };
}
