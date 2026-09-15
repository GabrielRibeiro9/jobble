import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_theme.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Conteúdo do card lima usa sempre o tema claro — o lima não muda com o
/// tema, então o que vai sobre ele também não pode mudar.
final ThemeData _onBrandTheme = AppTheme.light;

/// Tons de card do sistema.
///
/// - `plain`: branco, borda fina e sombra suave — o card padrão.
/// - `sunken`: cinza muito claro, para blocos dentro de outro card.
/// - `brand`: o degradê lima. **Um por tela, no máximo.**
/// - `brandSoft`: lavagem pálida de lima, para um item escolhido/destacado.
/// - `inverse`: floresta, com texto claro.
enum AppCardTone { plain, sunken, brand, brandSoft, inverse }

/// Superfície de conteúdo: branco, raio 18, borda de 1px e a sombra `card`
/// tingida de floresta. Nunca borda colorida à esquerda, nunca contorno em
/// lima.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.color,
    this.borderRadius = AppRadius.lgAll,
    this.bordered = false,
    this.tone = AppCardTone.plain,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Sobrescreve o fundo do tom.
  final Color? color;
  final BorderRadius borderRadius;

  /// Troca a borda sutil pela borda padrão, um degrau mais escura. Use
  /// quando o card precisa de definição sobre uma superfície parecida.
  final bool bordered;

  final AppCardTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (Color? fill, Gradient? gradient, Color borderColor) = switch (tone) {
      AppCardTone.plain => (
        colors.surface,
        null,
        bordered ? colors.border : colors.borderLight,
      ),
      AppCardTone.sunken => (colors.surfaceLight, null, colors.borderLight),
      AppCardTone.brand => (null, AppColorsTheme.brandGradient, Colors.transparent),
      AppCardTone.brandSoft => (colors.accentSoft, null, colors.primary),
      AppCardTone.inverse => (colors.inverse, null, colors.inverse),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? fill,
        gradient: color == null ? gradient : null,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: AppSize.border),
        boxShadow: tone == AppCardTone.sunken ? null : AppShadow.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: tone == AppCardTone.brand
                ? Theme(data: _onBrandTheme, child: child)
                : child,
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho de seção: título à esquerda e um link opcional à direita.
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
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTypography.h3.copyWith(color: colors.textPrimary),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text('$actionLabel  →')),
      ],
    );
  }
}

/// Card de escolha única: título, apoio e um rádio à direita.
///
/// A seleção é comunicada por três sinais somados — fundo lima pálido, borda
/// lima e o rádio preenchido — para não depender só de cor.
class AppSelectableCard extends StatelessWidget {
  const AppSelectableCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: AppCurve.standard,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? colors.accentSoft : colors.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: selected ? colors.primary : colors.borderLight,
              width: AppSize.border,
            ),
            boxShadow: AppShadow.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
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
              const SizedBox(width: AppSpacing.sm),
              AnimatedContainer(
                duration: AppDuration.fast,
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: Border.all(
                    color: selected ? colors.accentText : colors.borderStrong,
                    width: selected ? 1.5 : AppSize.border,
                  ),
                ),
                child: AnimatedScale(
                  scale: selected ? 1 : 0,
                  duration: AppDuration.fast,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accentText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
