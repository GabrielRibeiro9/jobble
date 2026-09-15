import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

import 'contract_fixtures.dart';

void main() {
  group('ContractModel.fromJson', () {
    test('lê estado, ações e termos', () {
      final contract = ContractModel.fromJson(contractJson());

      expect(contract.status, ContractStatus.draft);
      expect(contract.viewerParty, ContractParty.provider);
      expect(contract.allowedActions, {
        ContractAction.editTerms,
        ContractAction.submit,
        ContractAction.cancel,
      });
      expect(contract.terms.priceCents, 150000);
      expect(contract.terms.paymentMethod, PaymentMethod.pix);
      expect(contract.terms.materialsResponsibility, MaterialsResponsibility.provider);
      expect(contract.document.clauses.single.paragraphs, hasLength(2));
      expect(contract.isPreview, isTrue);
    });

    test('ação desconhecida é ignorada, não quebra a tela', () {
      final contract = ContractModel.fromJson(
        contractJson(actions: ['SUBMIT', 'SOMETHING_NEW']),
      );
      expect(contract.allowedActions, {ContractAction.submit});
    });

    test('a prontidão "minha" é a do lado de quem olha', () {
      final contract = ContractModel.fromJson(contractJson());

      expect(contract.myReadiness.ready, isFalse);
      expect(contract.myReadiness.pendingItems, [
        'Telefone',
        'Verificação de identidade (em análise)',
      ]);
      expect(contract.otherReadiness.ready, isTrue);
    });

    test('assinaturas e pedido de ajuste', () {
      final contract = ContractModel.fromJson(
        contractJson(
          status: 'CHANGES_REQUESTED',
          contentHash: 'a' * 64,
          signatures: [
            {
              'party': 'CLIENT',
              'signerName': 'Maria da Silva',
              'signedAt': '2026-09-14T10:00:00.000Z',
            },
          ],
          changeRequest: {
            'message': 'Baixar o valor',
            'counterProposalCents': 120000,
            'requestedAt': '2026-09-14T11:00:00.000Z',
          },
        ),
      );

      expect(contract.hasSigned(ContractParty.client), isTrue);
      expect(contract.hasSigned(ContractParty.provider), isFalse);
      expect(contract.changeRequest!.counterProposalCents, 120000);
    });
  });

  group('ContractTerms.toJson', () {
    test('datas vão ao meio-dia UTC e vazio vira null', () {
      final json = ContractTerms(
        scope: '  Trocar a fiação toda  ',
        priceCents: 1000,
        paymentMethod: PaymentMethod.cash,
        paymentTerms: '   ',
        startDate: DateTime(2026, 9, 20, 23, 59),
        warrantyDays: 120,
        materialsResponsibility: MaterialsResponsibility.shared,
        materialsNotes: 'fios por conta do cliente',
      ).toJson();

      expect(json['scope'], 'Trocar a fiação toda');
      expect(json['paymentTerms'], isNull);
      expect(json['startDate'], '2026-09-20T12:00:00.000Z');
      expect(json['estimatedEndDate'], isNull);
      expect(json['paymentMethod'], 'CASH');
      expect(json['materialsResponsibility'], 'SHARED');
    });
  });

  group('rótulos', () {
    test('evento de assinatura diz quem assinou', () {
      final event = ContractEventInfo.fromJson({
        'type': 'SIGNED',
        'party': 'PROVIDER',
        'createdAt': '2026-09-14T10:00:00.000Z',
      });
      expect(event.label, 'Assinado pelo contratado');
    });

    test('estados finais', () {
      expect(ContractStatus.completed.isFinal, isTrue);
      expect(ContractStatus.signed.isFinal, isFalse);
      expect(ContractStatus.fromJson('AWAITING_CONFIRMATION').label, 'Aguardando confirmação');
    });

    test('identidade recusada pede reenvio', () {
      const readiness = PartyReadiness(
        ready: false,
        profileComplete: true,
        identityStatus: IdentityStatus.rejected,
        rejectionReason: 'Foto ilegível',
      );
      expect(readiness.pendingItems, ['Verificação de identidade (reenviar)']);
    });
  });
}
