import 'dart:async';

import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/auth/login/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionExpired = context.select<AppBloc, bool>(
      (bloc) => bloc.state.sessionExpired,
    );
    return LoginView(
      sessionExpired: sessionExpired,
      onContinueWithMobile: () =>
          unawaited(context.push(AppRoutes.phoneNumber)),
      onTermsPressed: () {
        // TODO(developer): Navigate to terms of service
      },
      onPrivacyPressed: () {
        // TODO(developer): Navigate to privacy policy
      },
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({
    required this.onContinueWithMobile,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    this.sessionExpired = false,
    super.key,
  });

  /// Shows a notice that the previous session ended without a sign-out.
  final bool sessionExpired;

  final VoidCallback onContinueWithMobile;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        // Scrollable so the optional banner and large text sizes never
        // overflow on short screens.
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 48,
            bottom: 32,
          ),
          child: Column(
            children: [
              if (sessionExpired) const _SessionExpiredBanner(),
              const EventlyBrand(),
              const SizedBox(height: 44),
              const LoginHero(),
              const SizedBox(height: 52),
              MobileLoginButton(onPressed: onContinueWithMobile),
              const SizedBox(height: 20),
              LegalText(
                onTermsPressed: onTermsPressed,
                onPrivacyPressed: onPrivacyPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionExpiredBanner extends StatelessWidget {
  const _SessionExpiredBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_clock_outlined, color: Color(0xFFC2410C), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your session has expired. Please sign in again.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }
}
