import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/offline_dashboard.dart';

class HomeBottomDashboard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleDrawer;

  const HomeBottomDashboard({
    super.key,
    required this.isOnline,
    required this.onToggleDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            border: Border(
              top: BorderSide(color: colors.border, width: AppSize.border),
            ),
          ),
          child: Column(
            children: [
              // Handle and Header (Collapsed View)
              _buildHeader(context, colors),
              
              // Scalable Content (Expanded View)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const OfflineDashboard(), // Reusing the existing dashboard content
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppColorsTheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderStrong,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Status Line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.chevron_up, size: 20),
              Column(
                children: [
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: AppTypography.h3.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    '5 min para pedidos',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onToggleDrawer,
                icon: const Icon(LucideIcons.list, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
