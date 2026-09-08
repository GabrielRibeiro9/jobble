import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Aviso de falha de autenticação.
///
/// Fundo e borda derivam do vermelho semântico; o título carrega a cor de erro
/// e o corpo fica em texto primário, para a mensagem continuar legível sobre a
/// superfície tingida.
class AuthErrorCard extends StatelessWidget {
  const AuthErrorCard({super.key, required this.message, this.title});

  final String message;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.errorBackground,
        border: Border.all(color: colors.errorBorder, width: AppSize.border),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? 'Não foi possível continuar',
                  style: AppTypography.title.copyWith(color: colors.error),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
