import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:business_repository/business_repository.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/app/view/splash_page.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/calendar/calendar.dart';
import 'package:evently_vendor/home/home.dart';
import 'package:evently_vendor/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../helpers/helpers.dart';

const _profile = VendorProfile(
  businessName: 'Lens & Light Studio',
  category: 'Photographer',
  location: 'Trivandrum',
  phone: '+919876543210',
  email: 'No email provided',
);

void main() {
  late AuthenticationClient authenticationClient;
  late StreamController<AuthenticationChange> changes;
  late UserRepository userRepository;
  late BusinessRepository businessRepository;
  late CustomerRepository customerRepository;
  late NotificationsRepository notificationsRepository;

  setUp(() {
    authenticationClient = MockAuthenticationClient();
    changes = StreamController<AuthenticationChange>();
    when(() => authenticationClient.changes).thenAnswer((_) => changes.stream);
    userRepository = MockUserRepository();
    businessRepository = MockBusinessRepository();
    customerRepository = MockCustomerRepository();
    notificationsRepository = MockNotificationsRepository();
    when(
      () => userRepository.profileExists(any()),
    ).thenAnswer((_) async => true);
    when(
      () => businessRepository.getBusinessIdForOwner(any()),
    ).thenAnswer((_) async => 'business-1');
    when(
      () => businessRepository.getVendorProfileDetails(),
    ).thenAnswer((_) async => _profile);
    when(
      () => businessRepository.getCategories(),
    ).thenAnswer((_) async => ['Photographer', 'Caterer']);
  });

  tearDown(() => unawaited(changes.close()));

  Future<void> pumpApp(
    WidgetTester tester, {
    String initialLocation = AppRoutes.splash,
  }) async {
    tester.usePhoneViewport();
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authenticationClient),
          RepositoryProvider.value(value: notificationsRepository),
          RepositoryProvider.value(value: userRepository),
          RepositoryProvider.value(value: businessRepository),
          RepositoryProvider.value(value: customerRepository),
        ],
        child: BlocProvider(
          create: (_) => AppBloc(
            authenticationClient: authenticationClient,
            userRepository: userRepository,
            businessRepository: businessRepository,
          )..add(const AppStarted()),
          child: AppView(initialLocation: initialLocation),
        ),
      ),
    );
  }

  testWidgets('App wires its dependencies and starts on the splash screen', (
    tester,
  ) async {
    tester.usePhoneViewport();
    await tester.pumpWidget(
      App(
        authenticationClient: authenticationClient,
        notificationsRepository: notificationsRepository,
        userRepository: userRepository,
        businessRepository: businessRepository,
        customerRepository: customerRepository,
      ),
    );
    expect(find.byType(SplashPage), findsOneWidget);
  });

  group('routing', () {
    testWidgets('shows the splash screen while the session is restored', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('routes signed-out users to sign-in', (tester) async {
      await pumpApp(tester);
      changes.add(const Unauthenticated());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('a protected deep link cannot bypass sign-in', (tester) async {
      await pumpApp(tester, initialLocation: '/customers/c1');
      changes.add(const Unauthenticated());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      verifyNever(() => customerRepository.getCustomer(any()));
    });

    testWidgets('routes onboarded users to the four-tab shell', (
      tester,
    ) async {
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Lens & Light Studio'), findsOneWidget);
      final navigation = find.byType(NavigationBar);
      for (final label in ['Home', 'Calendar', 'Insights', 'Profile']) {
        expect(
          find.descendant(of: navigation, matching: find.text(label)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: navigation, matching: find.text('Services')),
        findsNothing,
      );
      expect(
        tester.widget<NavigationBar>(navigation).destinations,
        hasLength(4),
      );
    });

    testWidgets('switching tabs keeps the other tabs alive', (tester) async {
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.text('Calendar is coming soon'), findsOneWidget);
      expect(find.byType(HomePage, skipOffstage: false), findsOneWidget);

      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();
      expect(find.text('Insights are coming soon'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      // The profile was loaded once for the whole shell.
      verify(() => businessRepository.getVendorProfileDetails()).called(1);
    });

    testWidgets('resumes a deep link after the session is restored', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.calendar);
      await tester.pump();
      expect(find.byType(SplashPage), findsOneWidget);

      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('routes users without a profile to the profile step', (
      tester,
    ) async {
      when(
        () => userRepository.profileExists(any()),
      ).thenAnswer((_) async => false);
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.byType(UserInformationPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('routes users without a business to the business step', (
      tester,
    ) async {
      when(
        () => businessRepository.getBusinessIdForOwner(any()),
      ).thenAnswer((_) async => null);
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();

      expect(find.byType(BusinessDetailsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('returns to sign-in with a notice when the session expires', (
      tester,
    ) async {
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      changes.add(const Unauthenticated(sessionExpired: true));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        find.text('Your session has expired. Please sign in again.'),
        findsOneWidget,
      );
    });

    testWidgets('offers retry when onboarding progress cannot be loaded', (
      tester,
    ) async {
      var calls = 0;
      when(() => userRepository.profileExists(any())).thenAnswer((_) async {
        if (calls++ == 0) throw Exception('offline');
        return true;
      });
      await pumpApp(tester);
      changes.add(const Authenticated(testUser));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't load your account"), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
