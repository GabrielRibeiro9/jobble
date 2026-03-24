import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_tcc/core/constants/app_assets.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/auth_error_card.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_form.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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

                        // ── Logo ──
                        Image.asset(AppAssets.logo, height: 24),

                        const Spacer(),
                        // ── Conteúdo Centralizado ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (state is AuthFailure) ...[
                                        AuthErrorCard(message: state.message),
                                        const SizedBox(height: 32),
                                      ],
                                      // ── Title ──
                                      const Text(
                                        'Vamos Começar',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Crie uma nova conta',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // ── Google button ──
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppColors.textPrimary,
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO: Google sign-in
                                        },
                                        icon: SvgPicture.asset(
                                          AppAssets.googleIcon,
                                          height: 18,
                                          width: 18,
                                        ),
                                        label: const Text(
                                          'Começar com Google',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // ── Divider ──
                                      const Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.border,
                                              thickness: 0.3,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(
                                              'Ou continue com',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: AppColors.border,
                                              thickness: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      // ── Signup form ──
                                      const SignupForm(),

                                      const SizedBox(height: 24),

                                      // ── Login link ──
                                      Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Já tem uma conta? ',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Entrar',
                                                style: TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        // ── Footer ──
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Center(
                            child: Text.rich(
                              const TextSpan(
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Ao continuar, você concorda com os ',
                                  ),
                                  TextSpan(
                                    text: 'Termos de Serviço',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(text: '\ne a '),
                                  TextSpan(
                                    text: 'Política de Privacidade',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(text: ' da Base Brasil.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
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
