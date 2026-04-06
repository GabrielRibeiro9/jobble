import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_email.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_otp.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_profile.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:flutter_tcc/features/home/presentation/pages/home_page.dart';
import 'package:flutter_tcc/core/services/token_service.dart';
import 'package:flutter_tcc/injection_container.dart' as di;
import 'package:flutter_tcc/features/auth/presentation/pages/verify_otp_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _onStep1Continue() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('As senhas não coincidem'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      SignupSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _onStep2Continue(String code) {
    context.read<AuthBloc>().add(
      EmailVerificationSubmitted(email: _emailController.text, code: code),
    );
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onFinish() {
    context.read<AuthBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignupStep1Success) {
          _nextPage();
          // Trigger OTP resend automatically when reaching Step 2
          context.read<AuthBloc>().add(
            ResendVerificationEmailRequested(email: _emailController.text),
          );
        } else if (state is AuthVerificationSuccess) {
          _nextPage();
        } else if (state is AuthSuccess) {
          final tokenService = di.sl<TokenService>();

          final verified = tokenService.isVerified(state.accessToken);
          final completed = tokenService.isOnboardingCompleted(
            state.accessToken,
          );
          final email = tokenService.getUserEmail(state.accessToken);

          if (!completed && _currentStep == 2) {
            context.read<AuthBloc>().add(
              CompleteOnboardingSubmitted(
                name: _nameController.text,
                cpf: _cpfController.text,
              ),
            );
            return;
          }

          if (!mounted) return;

          Widget nextStep;
          if (!verified) {
            nextStep = VerifyOtpPage(
              email: email ?? _emailController.text,
              source: VerifyOtpSource.signup,
            );
          } else if (!completed) {
            nextStep = const CompleteProfilePage();
          } else {
            nextStep = const HomePage();
          }

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => nextStep),
            (route) => false,
          );
        } else if (state is AuthOnboardingSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: context.colors.textPrimary,
              size: 20,
            ),
            onPressed: _previousPage,
          ),
          centerTitle: true,
          title: Text(
            'CADASTRAR CONTA',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    Stack(
                      children: [
                        SignupStepEmail(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          onContinue: isLoading ? () {} : _onStep1Continue,
                        ),
                        if (isLoading && _currentStep == 0)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                    Stack(
                      children: [
                        SignupStepOtp(
                          email: _emailController.text,
                          onContinue: isLoading ? (_) {} : _onStep2Continue,
                        ),
                        if (isLoading && _currentStep == 1)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                    Stack(
                      children: [
                        SignupStepProfile(
                          nameController: _nameController,
                          cpfController: _cpfController,
                          onFinish: isLoading ? () {} : _onFinish,
                        ),
                        if (isLoading && _currentStep == 2)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
