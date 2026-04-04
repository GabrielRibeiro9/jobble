import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';
import 'package:flutter_tcc/features/onboard/presentation/widgets/onboarding_form.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Middle: Form Fields (Lateral PageView) ──
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep(
                  title: 'Seu Perfil',
                  description: 'Preencha seus dados pessoais',
                  step: 0,
                ),
                _buildStep(
                  title: 'Seu Negócio',
                  description: 'Conte-nos sobre o seu negócio',
                  step: 1,
                ),
              ],
            ),

            // ── Top Navigation Bar (iOS Style) ──
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _currentStep > 0 ? _previousStep : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.chevron_left,
                          size: 18,
                          color: _currentStep > 0
                              ? context.colors.link
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Anterior',
                          style: TextStyle(
                            color: _currentStep > 0
                                ? context.colors.link
                                : Colors.transparent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _currentStep < 1 ? _nextStep : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Próximo',
                          style: TextStyle(
                            color: _currentStep < 1
                                ? context.colors.link
                                : Colors.transparent,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevron_right,
                          size: 18,
                          color: _currentStep < 1
                              ? context.colors.link
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom: Action Button (Cupertino Style with Material Reliability) ──
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_currentStep == 0) {
                      _nextStep();
                    } else {
                      // TODO: Finalizar onboarding
                    }
                  },
                  child: Text(
                    _currentStep == 0 ? 'Próximo' : 'Finalizar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String description,
    required int step,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 96, 32, 128),
      child: Column(
        children: [
          // ── Top: Title and Description ──
          Text(
            title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),

          // ── Middle: Form centered in remaining space ──
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: OnboardingForm(
                  step: step,
                  onNext: _nextStep,
                  onPrevious: _previousStep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
