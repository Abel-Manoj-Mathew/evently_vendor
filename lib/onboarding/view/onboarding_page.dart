import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/onboarding/business_details/business_details.dart';
import 'package:evently_vendor/onboarding/user_information/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows the onboarding step that [AppBloc] says is next.
///
/// The step is derived from saved data rather than from navigation history,
/// so a user who closes the app mid-onboarding resumes at the right step.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  /// Lets the user go back from the business step to correct their name.
  bool _revisitingProfile = false;

  void _onStepSaved() {
    setState(() => _revisitingProfile = false);
    context.read<AppBloc>().add(const AppOnboardingRefreshRequested());
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You can sign in again with your mobile number to finish setting '
          'up your business.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      context.read<AppBloc>().add(const AppSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = context.select<AppBloc, OnboardingStep?>(
      (bloc) => bloc.state.onboardingStep,
    );
    if (step == OnboardingStep.business && !_revisitingProfile) {
      return BusinessDetailsPage(
        key: const ValueKey(OnboardingStep.business),
        onBack: () => setState(() => _revisitingProfile = true),
        onSaved: _onStepSaved,
      );
    }
    return UserInformationPage(
      key: const ValueKey(OnboardingStep.profile),
      backTooltip: step == OnboardingStep.business ? 'Back' : 'Sign out',
      onBack: step == OnboardingStep.business
          ? () => setState(() => _revisitingProfile = false)
          : _confirmSignOut,
      onSaved: _onStepSaved,
    );
  }
}
