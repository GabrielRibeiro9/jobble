import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/onboard/presentation/pages/onboarding_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/home_page.dart';
import 'package:flutter_tcc/core/services/token_service.dart';
import 'package:flutter_tcc/injection_container.dart' as di;

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // SnackBar removed
        }
        if (state is AuthSuccess) {
          final tokenService = di.sl<TokenService>();
          tokenService.saveToken(state.accessToken);

          final completed = tokenService.isOnboardingCompleted(
            state.accessToken,
          );

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  completed ? const HomePage() : const OnboardingPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── E-mail field ──
            const Text(
              'Email',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'exemplo@basebrasil.com.br',
              ),
            ),

            const SizedBox(height: 20),

            // ── Senha field ──
            const Text(
              'Senha',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Deve ter no mínimo 8 caracteres.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // ── Confirmar Senha field ──
            const Text(
              'Confirme sua Senha',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        // SnackBar removed
                        return;
                      }
                      context.read<AuthBloc>().add(
                        SignupSubmitted(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ),
                      );
                    },
              child: state is AuthLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Text(
                      'Crie sua Conta',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
