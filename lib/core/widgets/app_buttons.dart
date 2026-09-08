import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';

/// Três níveis de ação, todos em pill de 56 de altura.
///
/// - [AppPrimaryButton]: a ação principal da tela. Alto contraste.
/// - [AppAccentButton]: destaque de acento (lima). No máximo um por tela.
/// - [AppSecondaryButton]: alternativa, contornada sobre fundo transparente.
///
/// Todos aceitam [isLoading], que troca o rótulo por um indicador e desabilita
/// o toque — sem mudar a largura, para o layout não pular.

enum _ButtonKind { primary, accent, secondary }

class _BaseButton extends StatelessWidget {
  const _BaseButton({
    required this.kind,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.onImage = false,
  });

  final _ButtonKind kind;
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expanded;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !isLoading;

    final Color spinnerColor = switch (kind) {
      _ButtonKind.primary => colors.onInverse,
      _ButtonKind.accent => colors.onPrimary,
      _ButtonKind.secondary => onImage ? colors.inverse : colors.textPrimary,
    };

    final Widget child = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        : _label(context);

    final Widget button = switch (kind) {
      _ButtonKind.primary => ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      _ButtonKind.accent => FilledButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
      // Sobre uma foto, a borda discreta some. A variante onImage troca o
      // contorno pela cor de alto contraste, que lê sobre qualquer imagem.
      _ButtonKind.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: onImage
            ? OutlinedButton.styleFrom(
                foregroundColor: colors.inverse,
                side: BorderSide(color: colors.inverse, width: 1.5),
              )
            : null,
        child: child,
      ),
    };

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        height: AppSize.button,
        child: button,
      );
    }
    return SizedBox(height: AppSize.button, child: button);
  }

  Widget _label(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme.merge(data: const IconThemeData(size: 20), child: icon!),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) => _BaseButton(
    kind: _ButtonKind.primary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expanded: expanded,
  );
}

class AppAccentButton extends StatelessWidget {
  const AppAccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) => _BaseButton(
    kind: _ButtonKind.accent,
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expanded: expanded,
  );
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.onImage = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expanded;

  /// Use quando o botão fica sobre uma foto ou vídeo, onde a borda padrão
  /// não tem contraste suficiente.
  final bool onImage;

  @override
  Widget build(BuildContext context) => _BaseButton(
    kind: _ButtonKind.secondary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    isLoading: isLoading,
    expanded: expanded,
    onImage: onImage,
  );
}

/// Botão de ícone circular usado na navegação (voltar, fechar, menu).
/// Fundo de superfície elevada, sem borda.
class AppCircleIconButton extends StatelessWidget {
  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = AppSize.iconButton,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: colors.surfaceLight,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, size: 20, color: colors.textPrimary),
        ),
      ),
    );
  }
}
