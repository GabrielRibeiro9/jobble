import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Campo de texto do design system: contorno discreto, rótulo flutuante
/// recortado na borda e foco em lima.
///
/// A decoração toda vem do `inputDecorationTheme` — este widget só padroniza
/// altura, ícone de sufixo e o comportamento de senha.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget? suffix = widget.suffixIcon;
    if (widget.obscureText) {
      suffix = IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        color: colors.textSecondary,
        style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.transparent)),
        tooltip: _obscured ? 'Mostrar senha' : 'Ocultar senha',
      );
    }

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      obscureText: _obscured,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      cursorColor: colors.primary,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        errorText: widget.errorText,
        counterText: '',
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon: suffix,
        constraints: const BoxConstraints(minHeight: AppSize.field),
      ),
    );
  }
}

/// Rótulo + controle + texto de apoio, para controles que não são
/// [AppTextField] e portanto não têm rótulo flutuante próprio (seletor de
/// tags, seletor de data, toggles). Mantém o mesmo ritmo vertical dos campos.
class AppFieldGroup extends StatelessWidget {
  const AppFieldGroup({
    super.key,
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helper!,
            style: AppTypography.caption.copyWith(color: colors.textHint),
          ),
        ],
      ],
    );
  }
}
