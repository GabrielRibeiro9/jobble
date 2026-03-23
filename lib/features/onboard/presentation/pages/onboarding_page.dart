import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/constants/app_assets.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/onboard/presentation/widgets/onboarding_form.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),

                        Image.asset(AppAssets.logo, height: 24),

                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Complete seu perfil',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Conte-nos um pouco sobre você para começar',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  const OnboardingForm(),

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
