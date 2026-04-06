import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class OfflineDashboard extends StatelessWidget {
  const OfflineDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: colors.background.withOpacity(isDark ? 0.95 : 0.9),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
              _buildPerformanceSection(context),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bom trabalho hoje, Filipe!',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Confira seu desempenho até agora.',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context,
          icon: LucideIcons.wallet,
          title: 'Ganhos',
          value: 'R\$ 250,00',
          color: context.colors.success,
        ),
        _buildStatCard(
          context,
          icon: LucideIcons.briefcase,
          title: 'Serviços',
          value: '3',
          color: context.colors.themePrimary,
        ),
        _buildStatCard(
          context,
          icon: LucideIcons.clock,
          title: 'Tempo Online',
          value: '4h 30m',
          color: context.colors.warning,
        ),
        _buildStatCard(
          context,
          icon: LucideIcons.star,
          title: 'Avaliação',
          value: '4.8',
          color: context.colors.ratingStar,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de Aceitação',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '92%',
                style: TextStyle(
                  color: context.colors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.92,
            backgroundColor: context.colors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.success),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            'Você está com um ótimo desempenho hoje!',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividade Recente',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityRow(
          context,
          title: 'Instalação Elétrica',
          time: 'Hoje, 14:30',
          value: 'R\$ 120,00',
          isLast: false,
        ),
        _buildActivityRow(
          context,
          title: 'Reparo Hidráulico',
          time: 'Hoje, 11:15',
          value: 'R\$ 85,00',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildActivityRow(
    BuildContext context, {
    required String title,
    required String time,
    required String value,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: context.colors.border.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.circle_check,
              color: context.colors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
