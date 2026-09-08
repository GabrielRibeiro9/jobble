import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';

/// Barra de navegação flutuante em pill, sobre um desfoque da tela.
///
/// O item ativo é um círculo em lima com ícone escuro — é o único lugar da
/// navegação onde o acento aparece preenchido, o que torna a posição atual
/// legível de relance. Os inativos ficam em texto terciário.
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const _items = <({IconData icon, String label})>[
    (icon: LucideIcons.house, label: 'Início'),
    (icon: LucideIcons.calendar, label: 'Agenda'),
    (icon: LucideIcons.inbox, label: 'Mensagens'),
    (icon: LucideIcons.settings, label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: ClipRRect(
        borderRadius: AppRadius.pillAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.surfaceLight.withValues(alpha: 0.86),
              borderRadius: AppRadius.pillAll,
              border: Border.all(color: colors.border, width: AppSize.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _items.length; i++) ...[
                  _NavItem(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    isActive: currentIndex == i,
                    onTap: () => onItemSelected(i),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                ],
                _ProfileItem(
                  isActive: currentIndex == _items.length,
                  onTap: () => onItemSelected(_items.length),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? colors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? colors.onPrimary : colors.textHint,
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isActive,
      label: 'Perfil',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? colors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String? avatarUrl;
              var fallbackName = '';
              if (state is AuthSuccess && state.user != null) {
                final org = state.user!.organization;
                avatarUrl = org?.avatarUrl;
                fallbackName = org?.name ?? '';
              }

              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                return ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _fallback(context, fallbackName),
                  ),
                );
              }
              return _fallback(context, fallbackName);
            },
          ),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context, String name) {
    final colors = context.colors;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: name.isEmpty
          ? Icon(Icons.person_rounded, size: 20, color: colors.textHint)
          : Text(
              name.substring(0, 1).toUpperCase(),
              style: AppTypography.label.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
