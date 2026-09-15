import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Indicador de carregamento do app.
///
/// Um arco fino na cor da tinta — floresta no claro, lima no escuro. A cor
/// pode ser sobrescrita quando o loader fica sobre uma superfície de alto
/// contraste (dentro da CTA, por exemplo).
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 20, this.color, this.strokeWidth = 2});

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? context.colors.inverse,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

/// Loader centralizado para estados de carregamento de tela inteira.
class AppLoaderCentered extends StatelessWidget {
  const AppLoaderCentered({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoader(size: 26),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(
              label!,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
