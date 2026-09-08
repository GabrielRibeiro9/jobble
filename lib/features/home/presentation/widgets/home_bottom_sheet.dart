import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';

class HomeBottomSheet extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;

  const HomeBottomSheet({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.15, 0.5, 0.9],
      builder: (context, scrollController) {
        final colors = context.colors;

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
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      LucideIcons.sliders_horizontal,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                    Text(
                      isOnline ? 'Você está online' : 'Você está offline',
                      style: AppTypography.h2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Icon(
                      LucideIcons.list,
                      size: 24,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(height: 1, color: colors.borderLight),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.lg,
                    AppSpacing.screenH,
                    AppSpacing.lg,
                  ),
                  children: [
                    // A ação de sair de operação é destrutiva; a de entrar é
                    // o acento. Nunca as duas com o mesmo peso visual.
                    if (isOnline)
                      AppSecondaryButton(
                        label: 'Ficar offline',
                        onPressed: onToggleOnline,
                      )
                    else
                      AppAccentButton(
                        label: 'Ficar online',
                        onPressed: onToggleOnline,
                      ),
                    const SizedBox(height: AppSpacing.section),
                    AppListGroup(
                      children: [
                        AppListRow(
                          icon: LucideIcons.user,
                          title: 'Perfil e conta',
                          onTap: () {},
                        ),
                        AppListRow(
                          icon: LucideIcons.history,
                          title: 'Histórico de serviços',
                          onTap: () {},
                        ),
                        AppListRow(
                          icon: LucideIcons.wallet,
                          title: 'Pagamentos',
                          onTap: () {},
                        ),
                        AppListRow(
                          icon: LucideIcons.shield_question_mark,
                          title: 'Ajuda',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
