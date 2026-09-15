import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tcc/features/bids/data/models/org_match_model.dart';

Map<String, dynamic> _match({
  String status = 'PENDING',
  Map<String, dynamic>? contract,
  bool revealed = false,
  double? bidValue,
  String? proposedDate,
}) {
  return {
    'id': 'm1',
    'status': status,
    'distanceKm': 3.4,
    'bidValue': bidValue,
    'proposedDate': proposedDate,
    'createdAt': '2026-09-15T12:00:00.000Z',
    'request': {
      'id': 'r1',
      'title': 'Troca de chuveiro',
      'description': 'O chuveiro parou de esquentar',
      'categoryLabel': 'Elétrica',
      'isEmergency': false,
      'scheduledAt': null,
    },
    'clientRevealed': revealed,
    'client': revealed
        ? {'name': 'Ana Souza', 'email': 'ana@example.com'}
        : {'name': null, 'email': null},
    'address': revealed
        ? {
            'revealed': true,
            'street': 'Rua dos Pinheiros',
            'number': '1200',
            'neighborhood': 'Pinheiros',
            'city': 'São Paulo',
            'state': 'SP',
          }
        : {
            'revealed': false,
            'neighborhood': 'Pinheiros',
            'city': 'São Paulo',
            'state': 'SP',
          },
    'location': 'Pinheiros, São Paulo - SP',
    'contract': contract,
  };
}

Map<String, dynamic> _contract(String status, {int? priceCents, String? startDate}) =>
    {
      'id': 'c1',
      'code': 'JB-2026-0001',
      'status': status,
      'priceCents': priceCents,
      'startDate': startDate,
    };

void main() {
  group('etapa do trabalho', () {
    test('chamado novo pede resposta', () {
      expect(OrgMatch.fromJson(_match()).stage, JobStage.awaitingResponse);
    });

    test('aceito espera a escolha do cliente', () {
      expect(
        OrgMatch.fromJson(_match(status: 'ACCEPTED')).stage,
        JobStage.awaitingClient,
      );
    });

    test('escolhido sem contrato vai para o contrato', () {
      expect(
        OrgMatch.fromJson(_match(status: 'HIRED', revealed: true)).stage,
        JobStage.contractToFill,
      );
    });

    test('depois da escolha, o contrato manda', () {
      JobStage stageOf(String contractStatus) => OrgMatch.fromJson(
        _match(
          status: 'HIRED',
          revealed: true,
          contract: _contract(contractStatus),
        ),
      ).stage;

      expect(stageOf('DRAFT'), JobStage.contractToFill);
      expect(stageOf('SIGNED'), JobStage.inProgress);
      expect(stageOf('COMPLETED'), JobStage.completed);
      expect(stageOf('CANCELED'), JobStage.closed);
    });

    test('recusado, descartado ou preterido sai da lista', () {
      for (final status in ['DECLINED', 'REJECTED', 'IGNORED']) {
        expect(OrgMatch.fromJson(_match(status: status)).stage, JobStage.closed);
      }
    });
  });

  group('privacidade do cliente', () {
    test('antes da escolha, nem nome nem rua', () {
      final match = OrgMatch.fromJson(_match(status: 'ACCEPTED'));
      expect(match.clientRevealed, isFalse);
      expect(match.clientName, isNull);
      expect(match.addressLine, isNull);
      expect(match.location, 'Pinheiros, São Paulo - SP');
    });

    test('sem a revelação, o app não mostra o nome nem se ele vier', () {
      final json = _match(status: 'ACCEPTED')
        ..['client'] = {'name': 'Ana Souza'};
      expect(OrgMatch.fromJson(json).clientName, isNull);
    });

    test('depois da escolha, nome e endereço', () {
      final match = OrgMatch.fromJson(_match(status: 'HIRED', revealed: true));
      expect(match.clientName, 'Ana Souza');
      expect(match.addressLine, 'Rua dos Pinheiros, 1200');
    });
  });

  test('o valor do contrato vale mais que o da devolutiva', () {
    final match = OrgMatch.fromJson(
      _match(
        status: 'HIRED',
        revealed: true,
        bidValue: 120,
        contract: _contract('SIGNED', priceCents: 15000),
      ),
    );
    expect(match.value, 150);
  });

  test('a data do contrato decide o dia do trabalho', () {
    final match = OrgMatch.fromJson(
      _match(
        status: 'HIRED',
        revealed: true,
        proposedDate: '2026-09-20T13:00:00.000Z',
        contract: _contract('SIGNED', startDate: '2026-09-22T12:00:00.000Z'),
      ),
    );
    expect(match.hasAgreedDate, isTrue);
    expect(match.when, DateTime.parse('2026-09-22T12:00:00.000Z').toLocal());
  });

  test('sem data combinada, o dia é o da chegada do chamado', () {
    final match = OrgMatch.fromJson(_match());
    expect(match.hasAgreedDate, isFalse);
    expect(match.when, DateTime.parse('2026-09-15T12:00:00.000Z').toLocal());
  });
}
