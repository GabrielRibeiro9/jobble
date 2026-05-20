import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Status Line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.chevron_up, size: 20),
              Column(
                children: [
                   Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '5 min para pedidos',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
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
