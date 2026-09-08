import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';

/// Superfície de conteúdo: retângulo arredondado sobre o fundo, sem sombra.
/// A separação vem da diferença de luminância, não de elevação.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.color,
    this.borderRadius = AppRadius.lgAll,
    this.bordered = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius borderRadius;

  /// Acrescenta um contorno de 1px. Use quando o card fica sobre uma
  /// superfície de luminância parecida e precisa de definição.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: color ?? colors.surface,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: bordered
              ? BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: colors.border,
                    width: AppSize.border,
                  ),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}

/// Cabeçalho de seção: título à esquerda, ação opcional à direita em lima.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: context.colors.link,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
