import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Badge de status: pill com fundo pálido e texto na cor cheia.
///
/// Recebe a cor semântica (`success`, `warning`, `error`, `info`) e deriva o
/// par fundo/texto. Dois casos viram tons próprios do sistema:
/// - `primary` (lima) vira o badge de marca: lima cheio com tinta floresta —
///   lima como texto sobre lima pálido não teria leitura.
/// - `textHint` vira o neutro: cinza claro com texto cinza médio.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (Color background, Color foreground) = switch (color) {
      _ when color == colors.primary => (colors.primary, colors.onPrimary),
      _ when color == colors.textHint || color == colors.textSecondary => (
        colors.surfaceLight,
        colors.textSecondary,
      ),
      _ => (color.withValues(alpha: 0.12), color),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Linha de metadado: ícone pequeno + texto, usada dentro de cards.
class AppMetaRow extends StatelessWidget {
  const AppMetaRow({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;

  /// Destaca o texto em cor de tinta e peso médio.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 15, color: colors.textHint),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: emphasized ? colors.textPrimary : colors.textSecondary,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
