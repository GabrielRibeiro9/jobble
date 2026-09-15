import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/theme/theme_cubit.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/core/widgets/app_list_row.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_bloc.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_event.dart';
import 'package:flutter_tcc/features/settings/presentation/bloc/config_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: AppCircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          AppSpacing.xxxl,
        ),
        children: [
          AppListGroup(
            header: 'Conta',
            children: [
              AppListRow(
                icon: LucideIcons.user,
                title: 'Gerenciar conta',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.lock,
                title: 'Privacidade',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.shield_check,
                title: 'Segurança e login',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.wallet_minimal,
                title: 'Saldo',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.qr_code,
                title: 'Código QR',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.share_2,
                title: 'Compartilhar perfil',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppListGroup(
            header: 'Conteúdo e atividade',
            children: [
              AppListRow(
                icon: LucideIcons.bell,
                title: 'Notificações push',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
              ),
              AppListRow(
                icon: LucideIcons.languages,
                title: 'Idioma do aplicativo',
                value: 'Português',
                onTap: () {},
              ),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return AppListRow(
                    icon: LucideIcons.moon,
                    title: 'Modo escuro',
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) =>
                          context.read<ThemeCubit>().toggleTheme(),
                    ),
                  );
                },
              ),
              AppListRow(
                icon: LucideIcons.video,
                title: 'Preferências de conteúdo',
                onTap: () {},
              ),
              AppListRow(
                icon: LucideIcons.megaphone,
                title: 'Anúncios',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppListGroup(
            header: 'Parâmetros de trabalho',
            children: [
              BlocBuilder<ConfigBloc, ConfigState>(
                builder: (context, state) {
                  return _RadiusRow(
                    value: state.raioAtuacao,
                    onChanged: (value) {
                      context.read<ConfigBloc>().add(UpdateRaioAtuacao(value));
                    },
                  );
                },
              ),
              AppListRow(
                icon: LucideIcons.briefcase,
                title: 'Categorias de serviços',
                onTap: () {
                  // TODO: navegar para a tela de categorias
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppListGroup(
            children: [
              AppListRow(
                icon: LucideIcons.log_out,
                title: 'Sair da conta',
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

/// Raio de atuação: a linha mostra o valor e o slider fica logo abaixo, dentro
/// do mesmo bloco, para o controle ficar junto do rótulo que ele altera.
class _RadiusRow extends StatelessWidget {
  const _RadiusRow({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        AppListRow(
          icon: LucideIcons.map_pin,
          title: 'Raio de atuação',
          trailing: Text(
            '${value.toInt()} km',
            style: AppTypography.numeric.copyWith(
              color: colors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Slider(value: value, min: 5, max: 50, onChanged: onChanged),
        ),
      ],
    );
  }
}
