import 'package:evently_vendor/auth/login/cubit/login_cubit.dart';
import 'package:evently_vendor/auth/login/widgets/widgets.dart';
import 'package:evently_vendor/auth/mobile_number/mobile_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Builder(
        builder: (context) {
          return LoginView(
            onContinueWithMobile: () {
              context.read<LoginCubit>().continueWithMobile();
              Navigator.of(context).push(MobileNumberPage.route());
            },
            onTermsPressed: () {
              // TODO(developer): Navigate to terms of service
            },
            onPrivacyPressed: () {
              // TODO(developer): Navigate to privacy policy
            },
          );
        },
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({
    required this.onContinueWithMobile,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    super.key,
  });

  final VoidCallback onContinueWithMobile;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 48,
            bottom: 32,
          ),
          child: Column(
            children: [
              const EventlyBrand(),
              const SizedBox(height: 44),
              const LoginHero(),
              const SizedBox(height: 52),
              Expanded(
                child: Column(
                  children: [
                    MobileLoginButton(onPressed: onContinueWithMobile),
                    const SizedBox(height: 20),
                    LegalText(
                      onTermsPressed: onTermsPressed,
                      onPrivacyPressed: onPrivacyPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
