import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AppLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 18, this.color});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.grey[400];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 3.14159 * 2,
          child: child,
        );
      },
      child: Icon(
        LucideIcons.loader,
        size: widget.size,
        color: color,
      ),
    );
  }
}
