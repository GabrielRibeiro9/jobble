import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';

/// Avaliação em estrelas, seguida da nota e da contagem.
///
/// As estrelas usam o acento; as vazias ficam na cor de borda, para o
/// preenchimento ser lido pela diferença de contraste e não por outra cor.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    required this.hiring,
    this.starSize = 16,
  });

  final double rating;
  final int hiring;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filledStars = rating.round().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.star_rounded,
              size: starSize,
              color: index < filledStars ? colors.ratingStar : colors.border,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.label.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hiring > 0) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '($hiring)',
            style: AppTypography.label.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
