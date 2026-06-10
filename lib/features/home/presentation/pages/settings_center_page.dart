import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/settings/presentation/pages/settings_page.dart';

class SettingsCenterPage extends StatelessWidget {
  const SettingsCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildActionGrid(context),
          const SizedBox(height: 40),
          _buildSectionHeader(context, 'Central de Segurança'),
          const SizedBox(height: 16),
          _buildSecurityCards(context),
          const SizedBox(height: 40),
          _buildSectionHeader(context, 'Benefícios'),
          const SizedBox(height: 40),
          _buildBottomLink(
            context,
            icon: LucideIcons.circle_question_mark,
            title: 'Central de ajuda',
          ),
          const SizedBox(height: 12),
          _buildBottomLink(
            context,
            icon: LucideIcons.log_out,
            title: 'Sair do App',
            subtitle: 'Versão 1.0.0',
            onTap: () {
              // Handle logout
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionCard(
            context,
            LucideIcons.settings_2,
            'Ajustes de\nAtuação',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(width: 12),
          _buildActionCard(
            context,
            LucideIcons.history,
            'Histórico de\nServiços',
          ),
          const SizedBox(width: 12),
          _buildActionCard(context, LucideIcons.gauge, 'Meus\nGanhos'),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.textPrimary, size: 24),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          LucideIcons.chevron_right,
          color: context.colors.textSecondary,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildSecurityCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            'Trocar Senha',
            'Alterar sua senha de acesso',
            LucideIcons.lock,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            context,
            'Autenticação em\n2 Fatores',
            'Adicionar camada extra de segurança',
            LucideIcons.shield,
          ),
        ),
      ],
    );
  }
}

Widget _buildInfoCard(
  BuildContext context,
  String title,
  String subtitle,
  IconData? icon,
) {
  return Container(
    height: 140,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surfaceLight,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
            if (icon != null)
              Icon(icon, color: context.colors.textPrimary, size: 20),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBottomLink(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: context.colors.textPrimary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
