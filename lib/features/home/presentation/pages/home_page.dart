import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.background,
      ),
      body: const Center(
        child: Text(
          'Bem-vindo à Home!',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24),
        ),
      ),
    );
  }
}
