part of 'app_bloc.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Starts listening to authentication changes. Dispatch once at startup.
final class AppStarted extends AppEvent {
  const AppStarted();
}

/// Re-checks onboarding progress, e.g. after an onboarding step was saved
/// or when retrying after a failure.
final class AppOnboardingRefreshRequested extends AppEvent {
  const AppOnboardingRefreshRequested();
}

/// The user asked to sign out.
final class AppSignOutRequested extends AppEvent {
  const AppSignOutRequested();
}

final class _AppAuthenticationChanged extends AppEvent {
  const _AppAuthenticationChanged(this.change);

  final AuthenticationChange change;

  @override
  List<Object?> get props => [change];
}
