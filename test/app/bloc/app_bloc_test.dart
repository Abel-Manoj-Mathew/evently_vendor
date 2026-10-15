import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  late AuthenticationClient authenticationClient;
  late UserRepository userRepository;
  late BusinessRepository businessRepository;
  late StreamController<AuthenticationChange> changes;

  setUp(() {
    authenticationClient = MockAuthenticationClient();
    userRepository = MockUserRepository();
    businessRepository = MockBusinessRepository();
    changes = StreamController<AuthenticationChange>();
    when(() => authenticationClient.changes).thenAnswer((_) => changes.stream);
    when(
      () => userRepository.profileExists(any()),
    ).thenAnswer((_) async => true);
    when(
      () => businessRepository.getBusinessIdForOwner(any()),
    ).thenAnswer((_) async => 'business-1');
  });

  // Not awaited: closing a never-listened single-subscription controller
  // only completes once someone listens.
  tearDown(() => unawaited(changes.close()));

  AppBloc buildBloc() => AppBloc(
    authenticationClient: authenticationClient,
    userRepository: userRepository,
    businessRepository: businessRepository,
  );

  test('starts in initializing while the session is restored', () async {
    final bloc = buildBloc();
    expect(bloc.state, const AppState());
    expect(bloc.state.status, AppStatus.initializing);
    await bloc.close();
  });

  group('session restoration', () {
    blocTest<AppBloc, AppState>(
      'emits unauthenticated when no session was restored',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Unauthenticated());
      },
      expect: () => const [AppState(status: AppStatus.unauthenticated)],
    );

    blocTest<AppBloc, AppState>(
      'emits ready for a restored, onboarded user',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Authenticated(testUser));
      },
      expect: () => const [AppState(user: testUser), readyAppState],
    );

    blocTest<AppBloc, AppState>(
      'requires the profile step when no profile exists',
      setUp: () => when(
        () => userRepository.profileExists(testUser.id),
      ).thenAnswer((_) async => false),
      build: buildBloc,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Authenticated(testUser));
      },
      expect: () => const [
        AppState(user: testUser),
        AppState(
          status: AppStatus.onboardingRequired,
          user: testUser,
          onboardingStep: OnboardingStep.profile,
        ),
      ],
      verify: (_) => verifyNever(
        () => businessRepository.getBusinessIdForOwner(any()),
      ),
    );

    blocTest<AppBloc, AppState>(
      'requires the business step when a profile but no business exists',
      setUp: () => when(
        () => businessRepository.getBusinessIdForOwner(testUser.id),
      ).thenAnswer((_) async => null),
      build: buildBloc,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Authenticated(testUser));
      },
      expect: () => const [
        AppState(user: testUser),
        AppState(
          status: AppStatus.onboardingRequired,
          user: testUser,
          onboardingStep: OnboardingStep.business,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits failure instead of guessing when progress cannot be loaded',
      setUp: () => when(
        () => userRepository.profileExists(any()),
      ).thenThrow(Exception('offline')),
      build: buildBloc,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Authenticated(testUser));
      },
      expect: () => const [
        AppState(user: testUser),
        AppState(status: AppStatus.failure, user: testUser),
      ],
    );
  });

  group('session expiration', () {
    blocTest<AppBloc, AppState>(
      'signs out with sessionExpired when the session ends involuntarily',
      build: buildBloc,
      seed: () => readyAppState,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Unauthenticated(sessionExpired: true));
      },
      expect: () => const [
        AppState(status: AppStatus.unauthenticated, sessionExpired: true),
      ],
    );

    blocTest<AppBloc, AppState>(
      'clears sessionExpired after the next sign-in',
      build: buildBloc,
      seed: () => const AppState(
        status: AppStatus.unauthenticated,
        sessionExpired: true,
      ),
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(const Authenticated(testUser));
      },
      expect: () => const [AppState(user: testUser), readyAppState],
    );
  });

  group('AppOnboardingRefreshRequested', () {
    blocTest<AppBloc, AppState>(
      'moves to ready once the business exists',
      build: buildBloc,
      seed: () => const AppState(
        status: AppStatus.onboardingRequired,
        user: testUser,
        onboardingStep: OnboardingStep.business,
      ),
      act: (bloc) => bloc.add(const AppOnboardingRefreshRequested()),
      expect: () => const [readyAppState],
    );

    blocTest<AppBloc, AppState>(
      'does nothing without a user',
      build: buildBloc,
      act: (bloc) => bloc.add(const AppOnboardingRefreshRequested()),
      expect: () => const <AppState>[],
    );
  });

  group('same user updates', () {
    blocTest<AppBloc, AppState>(
      'keep onboarding progress without re-checking',
      build: buildBloc,
      seed: () => readyAppState,
      act: (bloc) {
        bloc.add(const AppStarted());
        changes.add(
          const Authenticated(AuthenticatedUser(id: 'user-1', phone: '+91')),
        );
      },
      expect: () => const [
        AppState(
          status: AppStatus.ready,
          user: AuthenticatedUser(id: 'user-1', phone: '+91'),
        ),
      ],
      verify: (_) => verifyNever(() => userRepository.profileExists(any())),
    );
  });

  group('AppSignOutRequested', () {
    blocTest<AppBloc, AppState>(
      'signs out through the client; state follows the auth stream',
      setUp: () =>
          when(() => authenticationClient.signOut()).thenAnswer((_) async {}),
      build: buildBloc,
      seed: () => readyAppState,
      act: (bloc) async {
        bloc
          ..add(const AppStarted())
          ..add(const AppSignOutRequested());
        await Future<void>.delayed(Duration.zero);
        changes.add(const Unauthenticated());
      },
      expect: () => const [AppState(status: AppStatus.unauthenticated)],
      verify: (_) => verify(() => authenticationClient.signOut()).called(1),
    );

    blocTest<AppBloc, AppState>(
      'reports a failure when the session is still present',
      setUp: () {
        when(() => authenticationClient.signOut()).thenThrow(
          const SignOutFailure(AuthFailureReason.network, 'offline'),
        );
        when(() => authenticationClient.currentUser).thenReturn(testUser);
      },
      build: buildBloc,
      seed: () => readyAppState,
      act: (bloc) => bloc.add(const AppSignOutRequested()),
      expect: () => const [
        AppState(status: AppStatus.ready, user: testUser, signOutFailed: true),
      ],
    );

    blocTest<AppBloc, AppState>(
      'does not report a failure when the local session was cleared',
      setUp: () {
        when(() => authenticationClient.signOut()).thenThrow(
          const SignOutFailure(AuthFailureReason.network, 'offline'),
        );
        when(() => authenticationClient.currentUser).thenReturn(null);
      },
      build: buildBloc,
      seed: () => readyAppState,
      act: (bloc) => bloc.add(const AppSignOutRequested()),
      expect: () => const <AppState>[],
    );
  });
}
