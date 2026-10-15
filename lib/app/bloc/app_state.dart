part of 'app_bloc.dart';

/// Where the user is in the app lifecycle.
enum AppStatus {
  /// Restoring the session or checking onboarding progress.
  initializing,

  /// No signed-in user.
  unauthenticated,

  /// Signed in, but onboarding is incomplete.
  onboardingRequired,

  /// Signed in and onboarded.
  ready,

  /// Signed in, but onboarding progress could not be loaded.
  failure,
}

/// The next onboarding step for a signed-in user.
enum OnboardingStep {
  /// The vendor's own name has not been saved.
  profile,

  /// The business has not been created.
  business,
}

final class AppState extends Equatable {
  const AppState({
    this.status = AppStatus.initializing,
    this.user,
    this.onboardingStep,
    this.sessionExpired = false,
    this.signOutFailed = false,
  });

  final AppStatus status;

  /// The signed-in user, when there is one.
  final AuthenticatedUser? user;

  /// Set when [status] is [AppStatus.onboardingRequired].
  final OnboardingStep? onboardingStep;

  /// Whether the user was signed out because their session expired.
  final bool sessionExpired;

  /// Whether the last sign-out attempt failed and the session is still
  /// active.
  final bool signOutFailed;

  @override
  List<Object?> get props => [
    status,
    user,
    onboardingStep,
    sessionExpired,
    signOutFailed,
  ];
}
