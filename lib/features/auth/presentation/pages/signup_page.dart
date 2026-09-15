import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/core/theme/app_spacing.dart';
import 'package:flutter_tcc/core/utils/br_documents.dart';
import 'package:flutter_tcc/core/widgets/app_buttons.dart';
import 'package:flutter_tcc/features/legal/data/models/legal_models.dart';
import 'package:flutter_tcc/core/widgets/step_progress.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_tcc/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_email.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_otp.dart';
import 'package:flutter_tcc/features/auth/presentation/widgets/signup_step_profile.dart';
import 'package:flutter_tcc/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:flutter_tcc/features/legal/presentation/pages/account_gate_page.dart';
import 'package:flutter_tcc/core/services/token_service.dart';
import 'package:flutter_tcc/injection_container.dart' as di;

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
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _legalNameController = TextEditingController();

  final _cpfMask = BrMasks.cpf();
  final _birthDateMask = BrMasks.date();
  final _phoneMask = BrMasks.phone();
  final _cnpjMask = BrMasks.cnpj();

  final _step1FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  OrganizationLegalType _legalType = OrganizationLegalType.individual;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();
    _descriptionController.dispose();
    _documentController.dispose();
    _legalNameController.dispose();
    super.dispose();
  }

  void _onStep1Continue() {
    if (!(_step1FormKey.currentState?.validate() ?? false)) return;

    final birth = parseBrDate(_birthDateController.text)!;

    context.read<AuthBloc>().add(
      SignupSubmitted(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cpf: onlyDigits(_cpfController.text),
        phone: onlyDigits(_phoneController.text),
        // Meio-dia UTC: nascimento é um dia, e meia-noite local viraria o
        // dia anterior no servidor.
        birthDate: DateTime.utc(
          birth.year,
          birth.month,
          birth.day,
          12,
        ).toIso8601String(),
      ),
    );
  }

  CompleteOnboardingSubmitted _onboardingEvent() {
    final isCompany = _legalType == OrganizationLegalType.company;
    return CompleteOnboardingSubmitted(
      organizationName: _orgNameController.text.trim(),
      description: _descriptionController.text,
      legalType: _legalType.apiValue,
      document: isCompany ? onlyDigits(_documentController.text) : null,
      legalName: isCompany ? _legalNameController.text.trim() : null,
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
    if (!(_step3FormKey.currentState?.validate() ?? false)) return;

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
          _pageController.jumpToPage(2);
        } else if (state is AuthVerificationSuccess) {
          _nextPage();
        } else if (state is AuthSuccess) {
          final tokenService = di.sl<TokenService>();

          final completed = tokenService.isOnboardingCompleted(
            state.accessToken,
          );

          if (!completed && _currentStep == 2) {
            context.read<AuthBloc>().add(_onboardingEvent());
            return;
          }

          if (!mounted) return;

          Widget nextStep;
          if (!completed) {
            nextStep = const CompleteProfilePage();
          } else {
            nextStep = const AccountGatePage();
          }

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => nextStep),
            (route) => false,
          );
        } else if (state is AuthOnboardingSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AccountGatePage()),
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: AppSpacing.screenH,
          centerTitle: false,
          title: Row(
            children: [
              AppCircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Voltar',
                onPressed: _previousPage,
              ),
              const SizedBox(width: AppSpacing.md),
              StepProgress(totalSteps: 3, currentStep: _currentStep + 1),
            ],
          ),
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

                return PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() => _currentStep = page);
                  },
                  children: [
                    SignupStepEmail(
                      formKey: _step1FormKey,
                      nameController: _nameController,
                      cpfController: _cpfController,
                      birthDateController: _birthDateController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      cpfMask: _cpfMask,
                      birthDateMask: _birthDateMask,
                      phoneMask: _phoneMask,
                      onContinue: _onStep1Continue,
                      isLoading: isLoading && _currentStep == 0,
                    ),
                    SignupStepOtp(
                      email: _emailController.text,
                      onContinue: _onStep2Continue,
                      isLoading: isLoading && _currentStep == 1,
                    ),
                    SignupStepProfile(
                      formKey: _step3FormKey,
                      orgNameController: _orgNameController,
                      descriptionController: _descriptionController,
                      legalType: _legalType,
                      onLegalTypeChanged: (type) =>
                          setState(() => _legalType = type),
                      documentController: _documentController,
                      legalNameController: _legalNameController,
                      cnpjMask: _cnpjMask,
                      onFinish: _onFinish,
                      isLoading: isLoading && _currentStep == 2,
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
