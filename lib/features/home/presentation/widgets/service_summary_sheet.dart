import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_empty_state.dart';

/// Resumo do dia: total ganho em um pill de destaque e a lista dos serviços.
class ServiceSummarySheet extends StatelessWidget {
  const ServiceSummarySheet({
    super.key,
    required this.services,
    required this.totalEarnings,
  });

  final List<Map<String, String>> services;
  final String totalEarnings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(top: media.padding.top + AppSpacing.xxxl),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AppCircleIconButton(
                    icon: LucideIcons.chevron_down,
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Resumo do dia',
                      style: AppTypography.h3.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                // Total do dia em pill de acento: é o número que a pessoa
                // abriu a folha para ver.
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: AppRadius.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.wallet,
                        size: 14,
                        color: colors.onPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        totalEarnings,
                        style: AppTypography.title.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: services.isEmpty
                  ? const AppEmptyState(
                      icon: LucideIcons.calendar_check,
                      title: 'Nenhum serviço hoje',
                      description:
                          'Os trabalhos concluídos no dia aparecem aqui.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.md + media.padding.bottom,
                      ),
                      itemCount: services.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: colors.borderLight),
                      itemBuilder: (context, index) =>
                          _ServiceRow(item: services[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.item});

  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['clientName'] ?? 'Cliente',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                item['value'] ?? '',
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${item['startTime']} — ${item['endTime']}',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            item['address'] ?? 'Sem endereço',
            style: AppTypography.caption.copyWith(color: colors.textHint),
          ),
        ],
      ),
    );
  }
}
