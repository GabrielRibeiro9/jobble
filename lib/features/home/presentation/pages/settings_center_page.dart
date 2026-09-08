import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_card.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/features/settings/presentation/pages/settings_page.dart';

class SettingsCenterPage extends StatelessWidget {
  const SettingsCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        // Espaço para a barra de navegação flutuante não cobrir o conteúdo.
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionRow(
            items: [
              (
                icon: LucideIcons.settings_2,
                title: 'Ajustes de atuação',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              (
                icon: LucideIcons.history,
                title: 'Histórico de serviços',
                onTap: null,
              ),
              (icon: LucideIcons.gauge, title: 'Meus ganhos', onTap: null),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const AppSectionHeader(title: 'Central de segurança'),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: _SecurityCard(
                  title: 'Trocar senha',
                  subtitle: 'Alterar sua senha de acesso',
                  icon: LucideIcons.lock,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SecurityCard(
                  title: 'Autenticação em 2 fatores',
                  subtitle: 'Camada extra de segurança',
                  icon: LucideIcons.shield,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          AppListGroup(
            children: [
              AppListRow(
                title: 'Central de ajuda',
                icon: LucideIcons.circle_question_mark,
                onTap: () {},
              ),
              AppListRow(
                title: 'Sair do app',
                subtitle: 'Versão 1.0.0',
                icon: LucideIcons.log_out,
                destructive: true,
                onTap: () {
                  // TODO: encerrar sessão
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Atalhos em cards quadrados que rolam na horizontal.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.items});

  final List<({IconData icon, String title, VoidCallback? onTap})> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            SizedBox(
              width: 118,
              height: 118,
              child: AppCard(
                color: colors.surface,
                onTap: items[i].onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(items[i].icon, size: 22, color: colors.textPrimary),
                    const Spacer(),
                    Text(
                      items[i].title,
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 148,
      child: AppCard(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(icon, size: 18, color: colors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
