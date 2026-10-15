import 'dart:async';

import 'package:evently_vendor/app/bloc/app_bloc.dart';
import 'package:evently_vendor/app/routing/app_redirect.dart';
import 'package:evently_vendor/app/routing/app_routes.dart';
import 'package:evently_vendor/app/view/app_shell.dart';
import 'package:evently_vendor/app/view/splash_page.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/auth/mobile_number/mobile_number.dart';
import 'package:evently_vendor/auth/otp/otp.dart';
import 'package:evently_vendor/booking/create_booking/create_booking.dart';
import 'package:evently_vendor/calendar/calendar.dart';
import 'package:evently_vendor/customers/customers.dart';
import 'package:evently_vendor/home/home.dart';
import 'package:evently_vendor/insights/insights.dart';
import 'package:evently_vendor/notifications/notifications.dart';
import 'package:evently_vendor/onboarding/onboarding.dart';
import 'package:evently_vendor/profile/profile.dart';
import 'package:evently_vendor/services/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Builds the app's [GoRouter].
///
/// Redirects are driven solely by [appBloc]; see [appRedirect].
GoRouter createAppRouter({
  required AppBloc appBloc,
  String initialLocation = AppRoutes.splash,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: _BlocRefreshListenable(appBloc.stream),
    redirect: (context, state) => appRedirect(appBloc.state, state.uri),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
        routes: [
          GoRoute(
            path: 'phone',
            builder: (context, state) => const MobileNumberPage(),
            routes: [
              GoRoute(
                path: 'verify',
                // The phone number travels in memory only, never in the URL.
                redirect: (context, state) =>
                    state.extra is String ? null : AppRoutes.phoneNumber,
                builder: (context, state) =>
                    OtpPage(phoneNumber: state.extra! as String),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.insights,
                builder: (context, state) => const InsightsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.newBooking,
        builder: (context, state) => const CreateBookingPage(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: AppRoutes.editBusiness,
        builder: (context, state) => const EditBusinessPage(),
      ),
      GoRoute(
        path: AppRoutes.customerDetailsPattern,
        builder: (context, state) => CustomerDetailsPage(
          customerId: state.pathParameters['customerId']!,
        ),
      ),
    ],
  );
}

/// Notifies [GoRouter] to re-run redirects whenever the app state changes.
class _BlocRefreshListenable extends ChangeNotifier {
  _BlocRefreshListenable(Stream<AppState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AppState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
