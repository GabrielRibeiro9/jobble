import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_status_chip.dart';
import 'package:flutter_tcc/features/contracts/data/models/contract_model.dart';

Color contractStatusColor(AppColorsTheme colors, ContractStatus status) {
  return switch (status) {
    ContractStatus.draft || ContractStatus.changesRequested => colors.warning,
    ContractStatus.pendingSignatures ||
    ContractStatus.awaitingConfirmation => colors.info,
    ContractStatus.signed || ContractStatus.completed => colors.success,
    ContractStatus.canceled || ContractStatus.terminated => colors.textHint,
  };
}

class ContractStatusChip extends StatelessWidget {
  const ContractStatusChip({super.key, required this.status});

  final ContractStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(
      label: status.label,
      color: contractStatusColor(context.colors, status),
    );
  }
}

/// O texto integral do contrato, como o backend montou.
///
/// Os parágrafos ganham numeração (`3.2.`) para poderem ser citados numa
/// conversa entre as partes; os itens já listados (`a)`, `b)`) mantêm a letra.
class ContractDocumentView extends StatelessWidget {
  const ContractDocumentView({
    super.key,
    required this.document,
    this.isPreview = false,
  });

  final ContractDocument document;
  final bool isPreview;

  static final _lettered = RegExp(r'^[a-z]\)');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final body = AppTypography.body.copyWith(
      color: colors.textPrimary,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPreview) ...[
          AppCard(
            color: colors.surfaceLight,
            child: Text(
              'Prévia. O texto definitivo é gerado quando o contrato é enviado '
              'para assinatura, com os dados das duas partes naquele momento.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          document.title,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final paragraph in document.preamble) ...[
          Text(paragraph, style: body, textAlign: TextAlign.justify),
          const SizedBox(height: AppSpacing.xs),
        ],
        for (final clause in document.clauses) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'CLÁUSULA ${clause.number} — ${clause.title.toUpperCase()}',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < clause.paragraphs.length; i++) ...[
            Text(
              _lettered.hasMatch(clause.paragraphs[i])
                  ? clause.paragraphs[i]
                  : '${clause.number}.${i + 1}. ${clause.paragraphs[i]}',
              style: body,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
        const SizedBox(height: AppSpacing.md),
        for (final paragraph in document.closing) ...[
          Text(paragraph, style: body),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

/// Pede um motivo antes de uma ação que não tem volta (cancelar, rescindir,
/// contestar). O motivo vai para a trilha do contrato e para a outra parte.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _controller.text.trim();
    if (reason.length < 5) {
      setState(() => _error = 'Explique em poucas palavras');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: 'Motivo',
              errorText: _error,
              counterText: '',
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Voltar'),
        ),
        TextButton(
          onPressed: _confirm,
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Pergunta simples de sim/não antes de uma ação importante.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Voltar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
