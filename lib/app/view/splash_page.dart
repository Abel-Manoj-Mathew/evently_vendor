import 'package:app_ui/app_ui.dart';
import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shown while the session is restored, and when the signed-in user's
/// onboarding progress cannot be loaded.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final failed = context.select<AppBloc, bool>(
      (bloc) => bloc.state.status == AppStatus.failure,
    );
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: failed
            ? AppEmptyState(
                icon: Icons.cloud_off_outlined,
                title: "We couldn't load your account",
                message:
                    'Check your internet connection and try again. Your '
                    'account and data are safe.',
                action: Column(
                  children: [
                    FilledButton(
                      onPressed: () => context.read<AppBloc>().add(
                        const AppOnboardingRefreshRequested(),
                      ),
                      child: const Text('Try again'),
                    ),
                    TextButton(
                      onPressed: () => context.read<AppBloc>().add(
                        const AppSignOutRequested(),
                      ),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
      ),
    );
  }
}
