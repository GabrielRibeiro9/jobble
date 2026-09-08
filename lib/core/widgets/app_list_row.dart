import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Linha de lista: ícone opcional em círculo, título, apoio e valor à direita.
///
/// O chevron aparece automaticamente quando a linha é tocável, e some quando
/// não é — assim a affordance nunca mente sobre o que é clicável.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final IconData? icon;

  /// Cor de fundo do círculo do ícone. Sem valor, usa a superfície elevada.
  final Color? iconColor;

  /// Substitui o valor/chevron à direita.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Pinta título e ícone com a cor de erro. Para ações como sair ou excluir.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = destructive ? colors.error : colors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: AppSize.categoryIcon,
                  height: AppSize.categoryIcon,
                  decoration: BoxDecoration(
                    color: iconColor ?? colors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: iconColor != null
                        ? colors.onPrimary
                        : (destructive ? colors.error : colors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title.copyWith(color: titleColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                if (value != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Text(
                        value!,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.textHint,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Agrupa [AppListRow]s em um card, com divisores só entre as linhas.
///
/// Agrupar é o que dá hierarquia a uma tela de configurações: cada grupo é um
/// bloco de assunto, e o cabeçalho opcional o nomeia.
class AppListGroup extends StatelessWidget {
  const AppListGroup({super.key, required this.children, this.header});

  final List<Widget> children;
  final String? header;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              header!,
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgAll,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacing.md,
                    color: colors.borderLight,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
