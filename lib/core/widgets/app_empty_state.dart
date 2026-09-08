import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';

/// Estado vazio: ícone contido em um círculo de superfície, título, apoio e
/// uma ação opcional. Usado tanto para listas sem conteúdo quanto para telas
/// ainda em construção.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: colors.textPrimary),
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppSecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
