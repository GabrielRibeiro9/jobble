import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class ServiceSummarySheet extends StatelessWidget {
  final List<Map<String, String>> services;
  final String totalEarnings;

  const ServiceSummarySheet({
    super.key,
    required this.services,
    required this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildSearchBar(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPadding),
              children: [
                _buildTotalEarningsItem(context),
                const SizedBox(height: 16),
                ...services.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildServiceCard(context, service, index == 0),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withOpacity(0.3)),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                LucideIcons.chevron_down,
                color: colors.error, // Uber Red
                size: 24,
              ),
            ),
          ),
          Text(
            'RESUMO DO DIA',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.border.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(LucideIcons.search, color: colors.error, size: 18),
            const SizedBox(width: 12),
            Text(
              'Buscar serviço ou valor',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarningsItem(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.wallet,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de Ganhos',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      totalEarnings,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: colors.border.withOpacity(0.3), height: 1),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    Map<String, String> item,
    bool isSelected,
  ) {
    final colors = context.colors;
    final iconMap = {
      'bolt': LucideIcons.zap,
      'wrench': LucideIcons.wrench,
      'paint': LucideIcons.paintbrush,
    };
    final iconData = iconMap[item['icon']] ?? LucideIcons.briefcase;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? colors.error.withOpacity(0.5) : colors.border.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              iconData,
              color: colors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['service'] ?? '',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Horário: ${item['time']}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Valor: ${item['value']}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Status: Concluído',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.more_vert,
            color: colors.error,
            size: 20,
          ),
        ],
      ),
    );
  }
}
