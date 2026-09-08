import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';

/// Progresso de fluxo em segmentos: uma barra curta por passo, preenchida em
/// lima até o passo atual. Comunica quantos passos faltam de forma mais direta
/// que uma barra contínua.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.segmentWidth = 34,
    this.height = 6,
  });

  /// Total de passos do fluxo.
  final int totalSteps;

  /// Passo atual, base 1. Segmentos até este índice ficam preenchidos.
  final int currentStep;

  final double segmentWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isFilled = index < currentStep;
        return AnimatedContainer(
          duration: AppDuration.normal,
          curve: Curves.easeOut,
          width: segmentWidth,
          height: height,
          margin: EdgeInsets.only(
            right: index == totalSteps - 1 ? 0 : AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isFilled ? colors.primary : colors.surfaceStrong,
            borderRadius: AppRadius.pillAll,
          ),
        );
      }),
    );
  }
}
