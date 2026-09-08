import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';

/// Painel de desempenho exibido quando o profissional está fora de operação.
class OfflineDashboard extends StatelessWidget {
  const OfflineDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.xxxl,
            AppSpacing.screenH,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom trabalho hoje!',
                style: AppTypography.h1.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Confira seu desempenho até agora.',
                style: AppTypography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.45,
                children: [
                  _StatCard(
                    icon: LucideIcons.wallet,
                    title: 'Ganhos',
                    value: r'R$ 250,00',
                    color: colors.success,
                  ),
                  _StatCard(
                    icon: LucideIcons.briefcase,
                    title: 'Serviços',
                    value: '3',
                    color: colors.primary,
                  ),
                  _StatCard(
                    icon: LucideIcons.clock,
                    title: 'Tempo online',
                    value: '4h 30m',
                    color: colors.warning,
                  ),
                  _StatCard(
                    icon: LucideIcons.star,
                    title: 'Avaliação',
                    value: '4,8',
                    color: colors.ratingStar,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const _AcceptanceCard(rate: 0.92),
              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(title: 'Atividade recente'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const _ActivityRow(
                      title: 'Instalação elétrica',
                      time: 'Hoje, 14:30',
                      value: r'R$ 120,00',
                    ),
                    Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      color: colors.borderLight,
                    ),
                    const _ActivityRow(
                      title: 'Reparo hidráulico',
                      time: 'Hoje, 11:15',
                      value: r'R$ 85,00',
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTypography.numeric.copyWith(
                  color: colors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcceptanceCard extends StatelessWidget {
  const _AcceptanceCard({required this.rate});

  /// Taxa entre 0 e 1.
  final double rate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percent = (rate * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de aceitação',
                style: AppTypography.title.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '$percent%',
                style: AppTypography.title.copyWith(color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: colors.surfaceStrong,
              color: colors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Você está com um ótimo desempenho hoje.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.time,
    required this.value,
  });

  final String title;
  final String time;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSize.categoryIcon,
            height: AppSize.categoryIcon,
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.circle_check,
              color: colors.success,
              size: 19,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
