import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class EarningsFloatingCard extends StatelessWidget {
  final Map<String, String> lastService;
  final VoidCallback onSeeAll;

  const EarningsFloatingCard({
    super.key,
    required this.lastService,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spacer for the badge from the parent
          const SizedBox(height: 80),
          Text(
            'ÚLTIMO TRABALHO',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const Divider(height: 32),

          // Service info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  '${lastService['startTime']} - ${lastService['service']}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  lastService['clientName'] ?? '',
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Footer
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'VER TODOS OS TRABALHOS',
              style: TextStyle(
                color: colors.themePrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
