import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LegalText extends StatelessWidget {
  const LegalText({
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
  });

  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF667085),
            height: 1.5,
            fontFamily: 'Inter',
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to '),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = onTermsPressed,
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = onPrivacyPressed,
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
