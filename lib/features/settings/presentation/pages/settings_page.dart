import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/core/theme/theme_cubit.dart';
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
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: context.colors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configurações e privacidade',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: context.colors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('CONTA'),
          _buildActionTile(
            icon: LucideIcons.user,
            title: 'Gerenciar conta',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.lock,
            title: 'Privacidade',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.shield_check,
            title: 'Segurança e login',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.wallet_minimal,
            title: 'Saldo',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.qr_code,
            title: 'Código QR',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.share_2,
            title: 'Compartilhar perfil',
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('CONTEÚDO E ATIVIDADE'),
          _buildSwitchTile(
            icon: LucideIcons.bell,
            title: 'Notificações push',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildActionTile(
            icon: LucideIcons.languages,
            title: 'Idioma do aplicativo',
            trailingText: 'Português',
            onTap: () {},
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final bool isDark = themeMode == ThemeMode.dark;
              return _buildSwitchTile(
                icon: LucideIcons.moon,
                title: 'Modo escuro',
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          _buildActionTile(
            icon: LucideIcons.video,
            title: 'Preferências de conteúdo',
            onTap: () {},
          ),
          _buildActionTile(
            icon: LucideIcons.megaphone,
            title: 'Anúncios',
            onTap: () {},
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('PARÂMETROS DE TRABALHO'),
          BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, state) {
              return _buildSliderTile(
                icon: LucideIcons.map_pin,
                title: 'Raio de Atuação',
                value: state.raioAtuacao,
                min: 5,
                max: 50,
                label: '${state.raioAtuacao.toInt()} km',
                onChanged: (value) {
                  context.read<ConfigBloc>().add(UpdateRaioAtuacao(value));
                },
              );
            },
          ),
          _buildActionTile(
            icon: LucideIcons.briefcase,
            title: 'Categorias de Serviços',
            onTap: () {
              // TODO: Navegar para tela de categorias
            },
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('OUTROS'),
          _buildActionTile(
            icon: LucideIcons.log_out,
            title: 'Sair da conta',
            textColor: context.colors.error,
            showChevron: false,
            onTap: () {
              // TODO: Lógica de logout
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? textColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(
        icon,
        color: textColor ?? context.colors.textPrimary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? context.colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.colors.textHint, size: 20),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, color: context.colors.textPrimary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.colors.onPrimary,
            activeTrackColor: context.colors.themePrimary,
            inactiveThumbColor: context.colors.onPrimary,
            inactiveTrackColor: context.colors.border,
          ),
          const SizedBox(width: 0),
          Icon(Icons.chevron_right, color: context.colors.textHint, size: 20),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          leading: Icon(icon, color: context.colors.textPrimary, size: 22),
          title: Text(
            title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: context.colors.themePrimary,
              inactiveTrackColor: context.colors.border,
              thumbColor: context.colors.onPrimary,
              overlayColor: context.colors.themePrimary.withValues(alpha: 0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
