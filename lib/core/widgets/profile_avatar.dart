import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackName;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 64.0,
    this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CupertinoActivityIndicator());
          },
        ),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    if (fallbackName != null && fallbackName!.isNotEmpty) {
      final initial = fallbackName!.substring(0, 1).toUpperCase();
      return Center(
        child: Text(
          initial,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Icon(
      Icons.person,
      size: size * 0.6,
      color: context.colors.textSecondary,
    );
  }
}
