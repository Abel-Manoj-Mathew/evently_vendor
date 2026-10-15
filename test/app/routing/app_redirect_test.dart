import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/app/routing/app_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

String? redirect(AppState state, String location) =>
    appRedirect(state, Uri.parse(location));

const _onboardingProfile = AppState(
  status: AppStatus.onboardingRequired,
  user: testUser,
  onboardingStep: OnboardingStep.profile,
);

const _states = <AppState>[
  AppState(),
  AppState(status: AppStatus.unauthenticated),
  _onboardingProfile,
  readyAppState,
  AppState(status: AppStatus.failure, user: testUser),
];

const _locations = <String>[
  AppRoutes.splash,
  '/?from=%2Fcalendar',
  AppRoutes.login,
  AppRoutes.phoneNumber,
  AppRoutes.verifyOtp,
  AppRoutes.onboarding,
  AppRoutes.home,
  AppRoutes.calendar,
  AppRoutes.insights,
  AppRoutes.profile,
  AppRoutes.notifications,
  AppRoutes.newBooking,
  '/customers/c1',
];

void main() {
  group('appRedirect', () {
    group('initial authentication loading', () {
      test('stays on the splash screen', () {
        expect(redirect(const AppState(), AppRoutes.splash), isNull);
      });

      test('parks protected deep links on splash, keeping the target', () {
        expect(
          redirect(const AppState(), '/customers/c1'),
          '/?from=%2Fcustomers%2Fc1',
        );
      });

      test('does not remember auth or onboarding locations', () {
        expect(redirect(const AppState(), AppRoutes.login), AppRoutes.splash);
        expect(
          redirect(const AppState(), AppRoutes.onboarding),
          AppRoutes.splash,
        );
      });
    });

    group('signed out', () {
      const state = AppState(status: AppStatus.unauthenticated);

      test('allows the sign-in flow', () {
        expect(redirect(state, AppRoutes.login), isNull);
        expect(redirect(state, AppRoutes.phoneNumber), isNull);
        expect(redirect(state, AppRoutes.verifyOtp), isNull);
      });

      test('sends every other location to sign-in', () {
        for (final location in [
          AppRoutes.splash,
          AppRoutes.home,
          AppRoutes.onboarding,
          '/customers/c1',
          '/loginx',
        ]) {
          expect(redirect(state, location), AppRoutes.login, reason: location);
        }
      });
    });

    group('onboarding required', () {
      test('only allows onboarding', () {
        expect(redirect(_onboardingProfile, AppRoutes.onboarding), isNull);
        expect(
          redirect(_onboardingProfile, AppRoutes.home),
          AppRoutes.onboarding,
        );
        expect(
          redirect(_onboardingProfile, AppRoutes.newBooking),
          AppRoutes.onboarding,
        );
        expect(
          redirect(_onboardingProfile, AppRoutes.login),
          AppRoutes.onboarding,
        );
      });
    });

    group('authenticated and onboarded', () {
      test('allows app locations', () {
        for (final location in [
          AppRoutes.home,
          AppRoutes.calendar,
          AppRoutes.insights,
          AppRoutes.profile,
          AppRoutes.notifications,
          '/customers/c1',
        ]) {
          expect(redirect(readyAppState, location), isNull, reason: location);
        }
      });

      test('leaves splash, sign-in and onboarding for home', () {
        expect(redirect(readyAppState, AppRoutes.splash), AppRoutes.home);
        expect(redirect(readyAppState, AppRoutes.verifyOtp), AppRoutes.home);
        expect(redirect(readyAppState, AppRoutes.onboarding), AppRoutes.home);
      });

      test('resumes a deep link parked during restoration', () {
        expect(
          redirect(readyAppState, '/?from=%2Fcustomers%2Fc1'),
          '/customers/c1',
        );
      });

      test('ignores unsafe or pointless resume targets', () {
        for (final from in [
          'https://evil.example/x',
          '//evil.example/x',
          '/login/phone',
          '/onboarding',
          '/',
          'relative',
        ]) {
          final location = Uri(
            path: '/',
            queryParameters: {'from': from},
          ).toString();
          expect(
            redirect(readyAppState, location),
            AppRoutes.home,
            reason: from,
          );
        }
      });
    });

    group('startup failure', () {
      test('keeps the user on splash with retry', () {
        const state = AppState(status: AppStatus.failure, user: testUser);
        expect(redirect(state, AppRoutes.splash), isNull);
        expect(redirect(state, AppRoutes.home), '/?from=%2Fhome');
      });
    });

    test('never loops: every redirect target is accepted as-is', () {
      for (final state in _states) {
        for (final location in _locations) {
          final target = redirect(state, location);
          if (target == null) continue;
          expect(
            redirect(state, target),
            isNull,
            reason: '${state.status} $location -> $target',
          );
        }
      }
    });
  });
}
