import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/constants/app_assets.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/signup_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (zoomed & centered)
          Positioned.fill(
            child: ClipRect(
              child: Transform.scale(
                scale: 1.1,
                alignment: Alignment.center,
                child: Image.asset(AppAssets.introBg, fit: BoxFit.cover),
              ),
            ),
          ),

          // Radial gradient overlay (dark edges, clearer center)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                0,
                AppSpacing.screenH,
                AppSpacing.xxxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppPrimaryButton(
                    label: 'Já tenho uma conta',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    label: 'Criar nova conta',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
