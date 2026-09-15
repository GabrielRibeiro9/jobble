import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';

/// AppBar das telas empilhadas: chip de voltar, título e, opcionalmente, o
/// descritor em itálico que o sistema põe sob todo título de tela.
class AppBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBackAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;

  /// Uma linha curta em itálico sob o título ("Acompanhe o que foi
  /// combinado.").
  final String? subtitle;

  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 60 : 68);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      toolbarHeight: preferredSize.height,
      leadingWidth: AppSize.iconButton + AppSpacing.screenH,
      titleSpacing: AppSpacing.sm,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.screenH),
        child: Center(
          child: AppCircleIconButton(
            icon: LucideIcons.arrow_left,
            tooltip: 'Voltar',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      title: subtitle == null
          ? Text(title)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.descriptor.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
      actions: [...?actions, const SizedBox(width: AppSpacing.xs)],
    );
  }
}
