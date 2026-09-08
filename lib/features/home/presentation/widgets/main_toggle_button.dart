import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';

/// Botão de entrar/sair de operação.
///
/// Online é o estado de acento (lima, ícone escuro); offline é neutro
/// (superfície elevada, ícone terciário). O contraste entre os dois é
/// suficiente sem depender de sombra.
class MainToggleButton extends StatelessWidget {
  const MainToggleButton({
    super.key,
    required this.isOnline,
    required this.onTap,
  });

  final bool isOnline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: isOnline ? 'Ficar offline' : 'Ficar online',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: Curves.easeOut,
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: isOnline ? colors.primary : colors.surfaceStrong,
            shape: BoxShape.circle,
            border: Border.all(
              color: isOnline ? colors.primary : colors.border,
              width: AppSize.border,
            ),
          ),
          child: Icon(
            LucideIcons.power,
            size: 30,
            color: isOnline ? colors.onPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
