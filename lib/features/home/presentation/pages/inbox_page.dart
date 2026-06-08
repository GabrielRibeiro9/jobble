import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/home/presentation/widgets/notifications_sheet.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  static const List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Novo pedido próximo',
      description:
          'Um novo serviço de Elétrica está disponível a 2.5km de você.',
      time: 'há 5 min',
      icon: LucideIcons.map_pin,
      iconColor: Colors.blue,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Pagamento recebido',
      description: 'Sua transferência de R\$ 250,00 foi concluída com sucesso.',
      time: 'há 2 horas',
      icon: LucideIcons.circle_check,
      iconColor: Colors.green,
    ),
    NotificationItem(
      title: 'Nova avaliação',
      description:
          'João Silva te avaliou com 5 estrelas: "Excelente profissional!".',
      time: 'Ontem',
      icon: LucideIcons.star,
      iconColor: Colors.amber,
      isUnread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _notifications.isEmpty
        ? _buildEmptyState(colors)
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            separatorBuilder: (context, index) =>
                Divider(color: colors.border.withValues(alpha: 0.3), height: 1),
            itemBuilder: (context, index) {
              return _buildNotificationCard(colors, _notifications[index]);
            },
          );
  }

  Widget _buildEmptyState(AppColorsTheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bell_off,
            size: 48,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação por enquanto',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppColorsTheme colors, NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight:
                              item.isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.themePrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: TextStyle(
                    color: colors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
