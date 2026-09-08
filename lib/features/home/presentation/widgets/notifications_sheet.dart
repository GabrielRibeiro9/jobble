import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

class NotificationItem {
  const NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;
}

/// Folha de notificações da home.
///
/// Cada item traz o ícone da categoria em um círculo tingido pela própria cor
/// — é o único lugar onde as cores categóricas aparecem fora dos gráficos — e
/// as não lidas recebem um ponto em lima.
class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key, required this.notifications});

  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.borderStrong,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificações',
                  style: AppTypography.h3.copyWith(color: colors.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Limpar tudo'),
                ),
              ],
            ),
          ),
          Flexible(
            child: notifications.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.section),
                    child: AppEmptyState(
                      icon: LucideIcons.bell_off,
                      title: 'Nenhuma notificação',
                      description: 'Você está em dia.',
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.md + bottomInset,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colors.borderLight),
                    itemBuilder: (context, index) =>
                        _NotificationRow(item: notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.categoryIcon,
            height: AppSize.categoryIcon,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 19),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.title.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.time,
                  style: AppTypography.caption.copyWith(color: colors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
