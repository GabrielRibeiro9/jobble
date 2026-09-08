import 'package:flutter/material.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';

/// Avatar circular com três estados: imagem, inicial do nome e ícone genérico.
///
/// [ringed] acrescenta um anel em lima — use para marcar o próprio usuário ou
/// um item selecionado, nunca como decoração.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 64.0,
    this.fallbackName,
    this.ringed = false,
  });

  final String? imageUrl;
  final double size;
  final String? fallbackName;
  final bool ringed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        shape: BoxShape.circle,
        border: ringed
            ? Border.all(color: colors.primary, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _fallback(context);

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(context),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(child: AppLoader(size: size * 0.35));
      },
    );
  }

  Widget _fallback(BuildContext context) {
    final colors = context.colors;
    final name = fallbackName;

    if (name != null && name.isNotEmpty) {
      return Center(
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: AppTypography.h2.copyWith(
            color: colors.textSecondary,
            fontSize: size * 0.38,
          ),
        ),
      );
    }
    return Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: colors.textSecondary,
    );
  }
}
