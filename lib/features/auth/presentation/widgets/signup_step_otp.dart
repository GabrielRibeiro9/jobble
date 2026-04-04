import 'package:flutter/material.dart';
import 'package:flutter_tcc/core/theme/app_colors.dart';

class SignupStepOtp extends StatefulWidget {
  final String email;
  final Function(String) onContinue;

  const SignupStepOtp({
    super.key,
    required this.email,
    required this.onContinue,
  });

  @override
  State<SignupStepOtp> createState() => _SignupStepOtpState();
}

class _SignupStepOtpState extends State<SignupStepOtp> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if OTP is complete
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      // Auto-submit or just enable button
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Digite o código enviado no seu e-mail',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'Enviamos um código de 6 dígitos para o seu e-mail ',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: widget.email,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: context.colors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              height: 50,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.borderLight),
                  ),
                ),
                onChanged: (value) => _onOtpChanged(index, value),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            // TODO: Resend OTP
          },
          child: Text(
            'Reenviar código',
            style: TextStyle(
              color: context.colors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              final otp = _controllers.map((c) => c.text).join();
              if (otp.length == 6) {
                widget.onContinue(otp);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continuar',
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
