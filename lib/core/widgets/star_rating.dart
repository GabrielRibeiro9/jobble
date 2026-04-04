import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int hiring;

  const StarRating({super.key, required this.rating, required this.hiring});

  @override
  Widget build(BuildContext context) {
    final int filledStars = rating.round().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.star,
                size: 16,
                color: index < filledStars
                    ? context.colors.ratingStar
                    : context.colors.border,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hiring > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($hiring)',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
