import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tcc/core/theme/app_theme.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/features/legal/presentation/widgets/readiness_card.dart';

import 'contracts/contract_fixtures.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('checklist mostra o que falta e oferece a correção', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      _wrap(
        ReadinessCard(
          title: 'Seu cadastro',
          readiness: const PartyReadiness(
            ready: false,
            profileComplete: false,
            identityStatus: IdentityStatus.notSubmitted,
            missing: ['CPF', 'Endereço de residência'],
          ),
          onFix: () => tapped = true,
        ),
      ),
    );

    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('Endereço de residência'), findsOneWidget);
    expect(find.text('Verificação de identidade'), findsOneWidget);

    await tester.tap(find.text('Completar agora'));
    expect(tapped, isTrue);
  });

  testWidgets('cadastro pronto não pede nada', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ReadinessCard(
          title: 'Seu cadastro',
          readiness: const PartyReadiness(
            ready: true,
            profileComplete: true,
            identityStatus: IdentityStatus.approved,
          ),
          onFix: () {},
        ),
      ),
    );

    expect(find.text('Cadastro completo e identidade verificada.'), findsOneWidget);
    expect(find.text('Completar agora'), findsNothing);
  });

  testWidgets('texto do contrato numera parágrafos e preserva itens', (
    tester,
  ) async {
    final contract = ContractModel.fromJson(contractJson());

    await tester.pumpWidget(
      _wrap(ContractDocumentView(document: contract.document, isPreview: true)),
    );

    expect(find.text('CLÁUSULA 1 — DO OBJETO'), findsOneWidget);
    expect(find.text('1.1. O presente contrato tem por objeto…'), findsOneWidget);
    expect(find.text('a) item'), findsOneWidget);
    expect(find.textContaining('Prévia.'), findsOneWidget);
  });
}
