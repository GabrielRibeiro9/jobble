import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/network/dio_client.dart';
import 'package:flutter_tcc/injection_container.dart';
import 'package:flutter_tcc/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_tcc/features/notifications/data/models/notification_model.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';
import 'package:flutter_tcc/features/bids/presentation/pages/match_details_page.dart';

enum NotificationType { match, proposalApproved }

class NotificationItem {
  final String id;
  final String personName;
  final NotificationType type;
  final DateTime dateTime;
  final bool? isUnread;
  final String? serviceRequestId;

  NotificationItem({
    required this.id,
    required this.personName,
    required this.type,
    required this.dateTime,
    this.isUnread,
    this.serviceRequestId,
  });

  String get title {
    return switch (type) {
      NotificationType.match => '$personName precisa dos seus serviços',
      NotificationType.proposalApproved => '$personName aceitou a sua proposta',
    };
  }

  IconData get icon => switch (type) {
    NotificationType.match => LucideIcons.sparkle,
    NotificationType.proposalApproved => LucideIcons.badge_check,
  };
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final NotificationRemoteDataSource _dataSource = NotificationRemoteDataSource(
    dioClient: sl<DioClient>(),
  );
  List<NotificationItem> _notifications = [];
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final models = await _dataSource.fetchAll();
      if (!mounted) return;
      setState(() {
        _notifications = models.map(_toNotificationItem).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar notificações: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  NotificationItem _toNotificationItem(NotificationModel model) {
    final type = model.type == 'MATCH'
        ? NotificationType.match
        : NotificationType.proposalApproved;
    return NotificationItem(
      id: model.id,
      personName: model.personName,
      type: type,
      dateTime: model.createdAt,
      isUnread: model.isUnread,
      serviceRequestId: model.serviceRequestId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_loading) {
      return const Center(child: AppLoader());
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState(colors);
    }

    final grouped = _groupByDay(_notifications);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final group in grouped) ...[
          _buildDayHeader(colors, group.date),
          for (final notification in group.items)
            _buildNotification(colors, notification),
        ],
      ],
    );
  }

  Widget _buildDayHeader(AppColorsTheme colors, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    String label;
    if (dateDay == today) {
      label = 'Hoje';
    } else if (dateDay == yesterday) {
      label = 'Ontem';
    } else {
      const months = [
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      label =
          '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotification(AppColorsTheme colors, NotificationItem item) {
    final hour = item.dateTime.hour.toString().padLeft(2, '0');
    final minute = item.dateTime.minute.toString().padLeft(2, '0');
    final timeLabel = '${hour}h$minute';

    return GestureDetector(
      onTap: () {
        if (item.type == NotificationType.match &&
            item.serviceRequestId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatchDetailsPage(
                serviceRequestId: item.serviceRequestId!,
                clientName: item.personName,
              ),
            ),
          );
        }
      },
      child: Opacity(
        opacity: item.isUnread == false ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 18, color: colors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorsTheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação por enquanto',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

List<DayGroup> _groupByDay(List<NotificationItem> items) {
  final sorted = List<NotificationItem>.from(items)
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  final groups = <DayGroup>[];
  for (final item in sorted) {
    final day = DateTime(
      item.dateTime.year,
      item.dateTime.month,
      item.dateTime.day,
    );
    if (groups.isEmpty || groups.last.date != day) {
      groups.add(DayGroup(date: day, items: []));
    }
    groups.last.items.add(item);
  }
  return groups;
}

class DayGroup {
  final DateTime date;
  final List<NotificationItem> items;

  DayGroup({required this.date, required this.items});
}
