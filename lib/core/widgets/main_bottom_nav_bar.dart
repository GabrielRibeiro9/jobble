import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNavItem(LucideIcons.house, 0),
                const SizedBox(width: 10),
                _buildNavItem(LucideIcons.calendar, 1),
                const SizedBox(width: 10),
                _buildNavItem(LucideIcons.inbox, 2),
                const SizedBox(width: 10),
                _buildNavItem(LucideIcons.settings, 3),
                const SizedBox(width: 10),
                _buildProfileItem(context, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, int index) {
    final isActive = currentIndex == index;
    final authState = context.read<AuthBloc>().state;
    final hasPhoto = authState is AuthSuccess &&
        authState.user != null &&
        authState.user!.organization?.avatarUrl != null &&
        authState.user!.organization!.avatarUrl!.isNotEmpty;
    final itemPadding = hasPhoto ? 6.0 : 10.0;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(itemPadding),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String? avatarUrl;
            String fallbackName = '';
            if (state is AuthSuccess && state.user != null) {
              final org = state.user!.organization;
              avatarUrl = org?.avatarUrl;
              fallbackName = org?.name ?? '';
            }

            if (avatarUrl != null && avatarUrl.isNotEmpty) {
              return ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackAvatar(fallbackName),
                ),
              );
            }
            return _buildFallbackAvatar(fallbackName);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    if (name.isNotEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return const Icon(Icons.person, size: 24, color: Colors.white54);
  }
}
