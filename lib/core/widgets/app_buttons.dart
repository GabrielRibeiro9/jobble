import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';

/// Três níveis de ação, todos em pill de 48 de altura.
///
/// - [AppPrimaryButton]: a ação principal da tela. Pill floresta.
/// - [AppAccentButton]: confirmação ou destaque (lima). No máximo um por tela.
/// - [AppSecondaryButton]: alternativa, pill branca com borda fina.
///
/// Pressionar encolhe o botão para 97% — a escala é o feedback, a cor não
/// muda. Todos aceitam [isLoading], que troca o rótulo por um indicador e
/// desabilita o toque sem mudar a largura, para o layout não pular.

enum _ButtonKind { primary, accent, secondary }

class _BaseButton extends StatefulWidget {
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
  State<_BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<_BaseButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onPressed != null && !widget.isLoading;

    // Sobre foto, a pill branca vira contorno branco translúcido: a borda
    // cinza padrão some sobre a imagem.
    const onImageInk = Color(0xFFFFFFFF);

    final Color spinnerColor = switch (widget.kind) {
      _ButtonKind.primary => colors.onInverse,
      _ButtonKind.accent => colors.onPrimary,
      _ButtonKind.secondary => widget.onImage ? onImageInk : colors.textPrimary,
    };

    final Widget child = widget.isLoading
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              strokeCap: StrokeCap.round,
              color: spinnerColor,
            ),
          )
        : _label();

    final VoidCallback? onPressed = enabled ? widget.onPressed : null;

    // O tema dá largura mínima infinita aos botões (CTA de largura total).
    // Sem expandir, o botão volta a medir o próprio conteúdo — senão ele
    // estica numa Column e quebra o layout numa Row.
    final ButtonStyle? sizeStyle = widget.expanded
        ? null
        : const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(64, AppSize.button)),
          );

    final Widget button = switch (widget.kind) {
      _ButtonKind.primary => ElevatedButton(
        onPressed: onPressed,
        style: sizeStyle,
        child: child,
      ),
      _ButtonKind.accent => FilledButton(
        onPressed: onPressed,
        style: sizeStyle,
        child: child,
      ),
      _ButtonKind.secondary => OutlinedButton(
        onPressed: onPressed,
        style: widget.onImage
            ? OutlinedButton.styleFrom(
                foregroundColor: onImageInk,
                backgroundColor: onImageInk.withValues(alpha: 0.12),
                side: BorderSide(color: onImageInk.withValues(alpha: 0.7)),
              ).merge(sizeStyle)
            : sizeStyle,
        child: child,
      ),
    };

    return Listener(
      onPointerDown: enabled ? (_) => _setPressed(true) : null,
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? kAppPressScale : 1,
        duration: AppDuration.fast,
        curve: AppCurve.standard,
        child: SizedBox(
          width: widget.expanded ? double.infinity : null,
          height: AppSize.button,
          child: button,
        ),
      ),
    );
  }

  Widget _label() {
    if (widget.icon == null) return Text(widget.label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme.merge(
          data: const IconThemeData(size: 18),
          child: widget.icon!,
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
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

/// O chip de ícone do sistema: círculo branco com borda fina e uma sombra de
/// 1px. É o dispositivo recorrente da navegação (voltar, fechar, menu).
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

    final Widget chip = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadow.xs,
        border: Border.all(color: colors.borderLight, width: AppSize.border),
      ),
      child: Material(
        color: colors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, size: 18, color: colors.textPrimary),
        ),
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: tooltip == null ? chip : Tooltip(message: tooltip, child: chip),
    );
  }
}
