import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Etiqueta de status: pill em caixa alta, tingido pela cor semântica.
///
/// O fundo é a cor com opacidade baixa e o texto é a cor cheia — assim o
/// status se destaca sem competir com o acento da tela, e o mesmo componente
/// serve para sucesso, atenção, erro e neutro.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(color: color),
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

  /// Destaca o texto em cor primária e peso médio.
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
