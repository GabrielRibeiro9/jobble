import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          surface: const Color(0xFFFAFAFA),
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          isDense: true,
          constraints: const BoxConstraints(minHeight: 42, maxHeight: 42),
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
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
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.transparent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Anterior',
                            style: TextStyle(
                              color: _currentStep > 0
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.transparent,
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
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.transparent,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevron_right,
                            size: 18,
                            color: _currentStep < 1
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.transparent,
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF666666),
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
