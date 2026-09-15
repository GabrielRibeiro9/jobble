import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_theme.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// O card lima é igual nos dois temas: o conteúdo dele sempre usa o tema
/// claro, para que as pills (floresta e branca) e o chip de fechar mantenham
/// o contraste sobre o lima também no modo escuro.
final ThemeData _onBrandTheme = AppTheme.light;

/// O card de destaque do sistema: degradê lima, raio 24, curvas brancas ao
/// fundo, e o valor grande em Space Grotesk.
///
/// É o único card lima da tela — dinheiro a seu favor. Abaixo do valor,
/// [footer] recebe o conteúdo de apoio e as ações (pill floresta e pill
/// branca, como "Depositar"/"Enviar" no sistema).
class AppBalanceCard extends StatelessWidget {
  const AppBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.currency,
    this.action,
    this.footer,
  });

  final String label;

  /// O valor já formatado, com símbolo ("R$ 1.250,00").
  final String amount;

  /// Código da moeda, menor e depois do valor. Opcional.
  final String? currency;

  /// Ação no canto superior direito (fechar, adicionar).
  final Widget? action;

  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.onPrimary;

    final card = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColorsTheme.brandGradient,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadow.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _CurvesPainter())),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: Text(
                            label,
                            style: AppTypography.label.copyWith(color: ink),
                          ),
                        ),
                      ),
                      ?action,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 7,
                    children: [
                      Text(
                        amount,
                        style: AppTypography.numeric.copyWith(
                          color: ink,
                          fontSize: 36,
                          letterSpacing: -0.9,
                          height: 1,
                        ),
                      ),
                      if (currency != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            currency!,
                            style: AppTypography.label.copyWith(
                              color: ink,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    footer!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Theme(data: _onBrandTheme, child: card);
  }
}

/// As três curvas largas que atravessam o card, redesenhadas do SVG do
/// sistema (viewBox 400×220, esticado ao tamanho do card).
class _CurvesPainter extends CustomPainter {
  const _CurvesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 400;
    final sy = size.height / 220;
    final scale = (sx + sy) / 2;

    Path curve(List<double> p) => Path()
      ..moveTo(p[0] * sx, p[1] * sy)
      ..cubicTo(p[2] * sx, p[3] * sy, p[4] * sx, p[5] * sy, p[6] * sx, p[7] * sy)
      ..cubicTo(
        p[8] * sx,
        p[9] * sy,
        p[10] * sx,
        p[11] * sy,
        p[12] * sx,
        p[13] * sy,
      );

    Paint stroke(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width * scale
      ..color = color;

    canvas
      ..drawPath(
        curve([-40, 180, 90, 110, 150, 220, 300, 120, 450, 20, 430, 30, 470, 60]),
        stroke(const Color(0x46FFFFFF), 14),
      )
      ..drawPath(
        curve([-40, 215, 110, 150, 170, 250, 320, 155, 470, 60, 450, 70, 490, 100]),
        stroke(const Color(0x2AFFFFFF), 14),
      )
      ..drawPath(
        curve([-30, 150, 100, 80, 160, 190, 310, 90, 460, -10, 440, 5, 480, 35]),
        stroke(const Color(0x2D5FB733), 10),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
