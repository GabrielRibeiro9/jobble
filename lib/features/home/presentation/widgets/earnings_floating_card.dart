import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Card do último trabalho, ancorado acima do rodapé da home.
///
/// O espaço no topo é reservado para o badge que o pai sobrepõe ao card.
class EarningsFloatingCard extends StatelessWidget {
  const EarningsFloatingCard({
    super.key,
    required this.lastService,
    required this.onSeeAll,
  });

  final Map<String, String> lastService;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.border, width: AppSize.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Espaço para o badge sobreposto pelo widget pai.
          const SizedBox(height: 80),
          Text(
            'Último trabalho'.toUpperCase(),
            style: AppTypography.overline.copyWith(color: colors.textHint),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: colors.borderLight),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  '${lastService['startTime']} · ${lastService['service']}',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastService['clientName'] ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todos os trabalhos'),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
