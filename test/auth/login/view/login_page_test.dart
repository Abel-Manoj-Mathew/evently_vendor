import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/auth/login/login.dart';
import 'package:evently_vendor/auth/login/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late AppBloc appBloc;

  setUp(() {
    appBloc = MockAppBloc();
    when(
      () => appBloc.state,
    ).thenReturn(const AppState(status: AppStatus.unauthenticated));
  });

  testWidgets('renders all widgets and invokes callbacks', (tester) async {
    tester.usePhoneViewport();
    var continuePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginView(
          onContinueWithMobile: () => continuePressed = true,
          onTermsPressed: () {},
          onPrivacyPressed: () {},
        ),
      ),
    );

    expect(find.byType(EventlyBrand), findsOneWidget);
    expect(find.byType(LoginHero), findsOneWidget);
    expect(find.byType(MobileLoginButton), findsOneWidget);
    expect(find.byType(LegalText), findsOneWidget);
    expect(find.text('E V E N T L Y'), findsOneWidget);
    expect(
      find.text('Manage your event business effortlessly'),
      findsOneWidget,
    );
    expect(find.textContaining('session has expired'), findsNothing);

    await tester.tap(find.byType(MobileLoginButton));
    expect(continuePressed, isTrue);
  });

  testWidgets('navigates to the mobile number step', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const LoginPage(),
          routes: [
            GoRoute(path: 'phone', builder: (_, _) => const Text('phone')),
          ],
        ),
      ],
    );
    await tester.pumpRouterApp(router, appBloc: appBloc);

    await tester.tap(find.byType(MobileLoginButton));
    await tester.pumpAndSettle();

    expect(find.text('phone'), findsOneWidget);
  });

  testWidgets('tells the user when their session expired', (tester) async {
    when(() => appBloc.state).thenReturn(
      const AppState(status: AppStatus.unauthenticated, sessionExpired: true),
    );
    await tester.pumpApp(const LoginPage(), appBloc: appBloc);

    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
  });
}
