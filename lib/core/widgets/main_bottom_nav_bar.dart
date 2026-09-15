import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/widgets/app_tab_bar.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';

/// Abas do app profissional sobre a [AppTabBar] do sistema.
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        var name = '';
        if (state is AuthSuccess && state.user != null) {
          final org = state.user!.organization;
          avatarUrl = org?.avatarUrl;
          name = org?.name ?? '';
        }

        return AppTabBar(
          currentIndex: currentIndex,
          onSelected: onItemSelected,
          items: [
            const AppTabItem(icon: LucideIcons.house, label: 'Início'),
            const AppTabItem(icon: LucideIcons.briefcase, label: 'Serviços'),
            const AppTabItem(icon: LucideIcons.file_text, label: 'Contratos'),
            const AppTabItem(icon: LucideIcons.settings, label: 'Ajustes'),
            AppTabItem.avatar(
              label: 'Perfil',
              avatarUrl: avatarUrl,
              name: name,
            ),
          ],
        );
      },
    );
  }
}
