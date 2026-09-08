import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_otp.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/login_page.dart';

enum VerifyOtpSource { login, signup }

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final VerifyOtpSource source;

  const VerifyOtpPage({
    super.key,
    required this.email,
    this.source = VerifyOtpSource.login,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  @override
  void initState() {
    super.initState();
    // Trigger OTP resend automatically upon arrival
    context.read<AuthBloc>().add(
          ResendVerificationEmailRequested(email: widget.email),
        );
  }

  void _onContinue(String code) {
    context.read<AuthBloc>().add(
          EmailVerificationSubmitted(
            email: widget.email,
            code: code,
          ),
        );
  }

  void _onBack() {
    if (widget.source == VerifyOtpSource.login) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthVerificationSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: AppSize.iconButton + AppSpacing.md + AppSpacing.xs,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: AppCircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: 'Voltar',
              onPressed: _onBack,
            ),
          ),
          title: const Text('Verificar e-mail'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.xl,
              AppSpacing.screenH,
              AppSpacing.xl,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return SignupStepOtp(
                  email: widget.email,
                  onContinue: _onContinue,
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
