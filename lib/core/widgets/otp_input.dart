import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Entrada de código de verificação em caixas separadas.
///
/// Uma caixa por dígito, com o campo em foco marcado pela borda em lima —
/// mesmo tratamento de foco dos campos comuns. O avanço e o retrocesso entre
/// as caixas são automáticos, e colar um código completo distribui os dígitos.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final int length;

  /// Chamado a cada alteração, com o código concatenado.
  final ValueChanged<String> onChanged;

  /// Chamado quando todas as caixas estão preenchidas.
  final ValueChanged<String>? onCompleted;

  final bool autofocus;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    for (final node in _nodes) {
      node.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node
        ..removeListener(_onFocusChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChange(int index, String value) {
    // Código colado: distribui os dígitos a partir da caixa atual.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < digits.length && index + i < widget.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }

    final code = _code;
    widget.onChanged(code);
    if (code.length == widget.length) {
      _nodes[index].unfocus();
      widget.onCompleted?.call(code);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final isFocused = _nodes[index].hasFocus;
        final isFilled = _controllers[index].text.isNotEmpty;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == widget.length - 1 ? 0 : AppSpacing.xs,
            ),
            child: AnimatedContainer(
              duration: AppDuration.fast,
              height: 62,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: isFocused
                      ? colors.primary
                      : (isFilled ? colors.borderStrong : colors.border),
                  width: isFocused ? AppSize.borderFocused : AppSize.border,
                ),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[index],
                focusNode: _nodes[index],
                autofocus: widget.autofocus && index == 0,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTypography.h2.copyWith(color: colors.textPrimary),
                cursorColor: colors.primary,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _handleChange(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}
