import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';

/// Indicador de carregamento do app.
///
/// Um arco fino em lima: mesma linguagem de traço dos ícones e do acento de
/// foco. A cor pode ser sobrescrita quando o loader fica sobre uma superfície
/// de alto contraste (dentro da CTA branca, por exemplo).
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
        color: color ?? context.colors.primary,
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
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoader(size: 28),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
