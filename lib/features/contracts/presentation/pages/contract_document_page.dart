import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_back_app_bar.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';
import 'package:flutter_tcc/features/contracts/presentation/widgets/contract_widgets.dart';

/// Leitura do contrato em tela cheia.
class ContractDocumentPage extends StatelessWidget {
  const ContractDocumentPage({super.key, required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hash = contract.contentHash;

    return Scaffold(
      appBar: AppBackAppBar(title: 'Contrato ${contract.code}'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: [
          ContractDocumentView(
            document: contract.document,
            isPreview: contract.isPreview,
          ),
          if (hash != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Versão ${contract.version} · código de verificação $hash',
              style: AppTypography.caption.copyWith(color: colors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}
