import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_typography.dart';
import 'package:flutter_tcc/core/widgets/app_loader.dart';

/// Avatar circular com três estados: imagem, iniciais e ícone genérico.
///
/// Sem foto, as iniciais ficam em tinta sobre lima pálido. [ringed]
/// acrescenta o anel do sistema — 2px de respiro na cor da superfície e 2px
/// de lima por fora. Use para marcar o próprio usuário ou um item escolhido,
/// nunca como decoração.
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

  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inner = ringed ? size - _ring * 4 : size;

    final Widget avatar = Container(
      width: inner,
      height: inner,
      decoration: BoxDecoration(
        color: colors.accentSoft,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _content(context, inner),
    );

    if (!ringed) return avatar;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(_ring),
      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
      child: Container(
        padding: const EdgeInsets.all(_ring),
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: avatar,
      ),
    );
  }

  Widget _content(BuildContext context, double inner) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _fallback(context, inner);

    return Image.network(
      url,
      width: inner,
      height: inner,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallback(context, inner),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(child: AppLoader(size: inner * 0.35));
      },
    );
  }

  Widget _fallback(BuildContext context, double inner) {
    final colors = context.colors;
    final initials = _initials(fallbackName);

    if (initials.isNotEmpty) {
      return Center(
        child: Text(
          initials,
          style: AppTypography.label.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: inner * 0.36,
            height: 1,
          ),
        ),
      );
    }
    return Icon(
      LucideIcons.user,
      size: inner * 0.45,
      color: colors.textPrimary,
    );
  }

  static String _initials(String? name) {
    if (name == null) return '';
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0]).join().toUpperCase();
  }
}
