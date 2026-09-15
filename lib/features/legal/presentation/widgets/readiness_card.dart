import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';

/// Checklist de prontidão para assinar: ou "pronto", ou o que falta.
///
/// É a mesma lista que o servidor usa para barrar o envio e a assinatura, então
/// o usuário descobre aqui — e não na hora de assinar — o que precisa fazer.
class ReadinessCard extends StatelessWidget {
  const ReadinessCard({
    super.key,
    required this.title,
    required this.readiness,
    this.onFix,
    this.fixLabel = 'Completar agora',
    this.footnote,
    this.pendingIntro = 'Para assinar contratos, falta:',
  });

  final String title;
  final PartyReadiness readiness;

  /// Sem ação, o card só informa — é o caso do cadastro da outra parte.
  final VoidCallback? onFix;
  final String fixLabel;
  final String? footnote;

  /// A frase antes da lista do que falta. A porta de entrada troca o
  /// "assinar contratos" por "liberar a conta".
  final String pendingIntro;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ready = readiness.ready;
    final items = readiness.pendingItems;

    return AppCard(
      bordered: !ready,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ready ? LucideIcons.shield_check : LucideIcons.shield_alert,
                size: 20,
                color: ready ? colors.success : colors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (ready)
            Text(
              'Cadastro completo e identidade verificada.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else ...[
            Text(
              pendingIntro,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTypography.body.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (readiness.rejectionReason != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Motivo da recusa: ${readiness.rejectionReason}',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            ],
          ],
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              footnote!,
              style: AppTypography.caption.copyWith(color: colors.textHint),
            ),
          ],
          if (!ready && onFix != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppSecondaryButton(label: fixLabel, onPressed: onFix),
          ],
        ],
      ),
    );
  }
}
