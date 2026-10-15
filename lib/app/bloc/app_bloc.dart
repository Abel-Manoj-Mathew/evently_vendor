import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:business_repository/business_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

/// Owns the authentication and onboarding lifecycle that drives routing.
///
/// Onboarding is complete when the user has a profile and a business. Both
/// are checked on every sign-in so an app killed between onboarding steps
/// resumes at the right step.
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required this._authenticationClient,
    required this._userRepository,
    required this._businessRepository,
  }) : super(const AppState()) {
    on<AppStarted>(_onStarted, transformer: droppable());
    // Sequential so an onboarding check for a stale user cannot finish after
    // a newer sign-in or sign-out has been processed.
    on<_AppAuthenticationChanged>(
      _onAuthenticationChanged,
      transformer: sequential(),
    );
    on<AppOnboardingRefreshRequested>(
      _onOnboardingRefreshRequested,
      transformer: droppable(),
    );
    on<AppSignOutRequested>(_onSignOutRequested, transformer: droppable());
  }

  final AuthenticationClient _authenticationClient;
  final UserRepository _userRepository;
  final BusinessRepository _businessRepository;
  StreamSubscription<AuthenticationChange>? _subscription;

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    await _subscription?.cancel();
    _subscription = _authenticationClient.changes.listen(
      (change) => add(_AppAuthenticationChanged(change)),
    );
  }

  Future<void> _onAuthenticationChanged(
    _AppAuthenticationChanged event,
    Emitter<AppState> emit,
  ) async {
    switch (event.change) {
      case Unauthenticated(:final sessionExpired):
        emit(
          AppState(
            status: AppStatus.unauthenticated,
            sessionExpired: sessionExpired,
          ),
        );
      case Authenticated(:final user):
        if (state.user?.id == user.id &&
            state.status != AppStatus.initializing) {
          // Same account (e.g. phone number updated); keep progress.
          emit(_copyWithUser(user));
          return;
        }
        emit(AppState(user: user));
        emit(await _resolveOnboarding(user));
    }
  }

  Future<void> _onOnboardingRefreshRequested(
    AppOnboardingRefreshRequested event,
    Emitter<AppState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;
    emit(await _resolveOnboarding(user));
  }

  Future<void> _onSignOutRequested(
    AppSignOutRequested event,
    Emitter<AppState> emit,
  ) async {
    if (state.signOutFailed) {
      emit(
        AppState(
          status: state.status,
          user: state.user,
          onboardingStep: state.onboardingStep,
        ),
      );
    }
    try {
      await _authenticationClient.signOut();
    } on SignOutFailure catch (error, stackTrace) {
      logE('Sign out failed', error: error, stackTrace: stackTrace);
      // Supabase clears the local session before contacting the server, so
      // only report a failure when the session is genuinely still there.
      if (_authenticationClient.currentUser != null) {
        emit(_copyWithSignOutFailed());
      }
    }
  }

  Future<AppState> _resolveOnboarding(AuthenticatedUser user) async {
    try {
      if (!await _userRepository.profileExists(user.id)) {
        return AppState(
          status: AppStatus.onboardingRequired,
          user: user,
          onboardingStep: OnboardingStep.profile,
        );
      }
      final businessId = await _businessRepository.getBusinessIdForOwner(
        user.id,
      );
      if (businessId == null) {
        return AppState(
          status: AppStatus.onboardingRequired,
          user: user,
          onboardingStep: OnboardingStep.business,
        );
      }
      return AppState(status: AppStatus.ready, user: user);
    } on Object catch (error, stackTrace) {
      logE(
        'Could not load onboarding progress',
        error: error,
        stackTrace: stackTrace,
      );
      return AppState(status: AppStatus.failure, user: user);
    }
  }

  AppState _copyWithUser(AuthenticatedUser user) => AppState(
    status: state.status,
    user: user,
    onboardingStep: state.onboardingStep,
  );

  AppState _copyWithSignOutFailed() => AppState(
    status: state.status,
    user: state.user,
    onboardingStep: state.onboardingStep,
    signOutFailed: true,
  );

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
