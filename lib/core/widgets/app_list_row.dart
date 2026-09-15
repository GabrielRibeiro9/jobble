import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Tamanho do chevron — e da coluna que ele ocupa mesmo quando não aparece.
const double _chevronSize = 16;

/// Linha de lista: ícone opcional em chip, título, apoio e valor à direita.
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

  /// Fundo do chip do ícone (um dos `AppColorsTheme.categorical`). Sem valor,
  /// o chip é branco com borda fina.
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

    final Color chipFill = destructive
        ? colors.errorBackground
        : (iconColor ?? colors.surface);
    final Color iconInk = destructive
        ? colors.error
        : (iconColor != null ? colors.onPrimary : colors.textPrimary);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: AppSize.categoryIcon,
                      height: AppSize.categoryIcon,
                      decoration: BoxDecoration(
                        color: chipFill,
                        shape: BoxShape.circle,
                        border: iconColor == null && !destructive
                            ? Border.all(
                                color: colors.border,
                                width: AppSize.border,
                              )
                            : null,
                      ),
                      child: Icon(icon, size: 16, color: iconInk),
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
                          style: AppTypography.title.copyWith(
                            color: titleColor,
                            fontSize: 14,
                          ),
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
                    // O valor mede o próprio texto (até 55% da linha) e
                    // encosta à direita. Ao lado de um título `Expanded`, um
                    // valor `Flexible` dividia a linha ao meio: cada valor
                    // começava no meio e terminava onde o texto acabasse.
                    if (value != null)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.55,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.xs),
                          child: Text(
                            value!,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    // O chevron tem coluna fixa: linha com valor e sem toque
                    // reserva o mesmo espaço, para os valores de um grupo
                    // terminarem alinhados.
                    if (onTap != null || value != null) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      if (onTap != null)
                        Icon(
                          LucideIcons.chevron_right,
                          size: _chevronSize,
                          color: colors.textHint,
                        )
                      else
                        const SizedBox(width: _chevronSize),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Agrupa [AppListRow]s em um card, com divisores só entre as linhas.
///
/// O cabeçalho opcional é o micro-rótulo em caixa alta do sistema
/// ("PREFERÊNCIAS") — é ele que nomeia cada bloco de assunto.
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
              left: AppSpacing.xxs,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              header!.toUpperCase(),
              style: AppTypography.overline.copyWith(color: colors.textHint),
            ),
          ),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.borderLight, width: AppSize.border),
            boxShadow: AppShadow.card,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: colors.borderLight,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
