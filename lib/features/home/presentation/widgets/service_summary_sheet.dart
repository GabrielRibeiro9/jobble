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

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 48),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: _buildTotalEarningsItem(context),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPadding),
                itemCount: services.length,
                separatorBuilder: (context, index) =>
                    Divider(color: colors.border.withValues(alpha: 0.3), height: 1),
                itemBuilder: (context, index) {
                  return _buildServiceCard(context, services[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.border.withValues(alpha: 0.3)),
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
                color: colors.textPrimary, // Changed from error (red) to black
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

  Widget _buildTotalEarningsItem(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wallet, color: colors.textSecondary, size: 14),
            const SizedBox(width: 8),
            Text(
              totalEarnings,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, String> item) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['clientName'] ?? 'Cliente',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item['value'] ?? '',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item['startTime']} - ${item['endTime']}',
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            item['address'] ?? 'Sem endereço',
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
