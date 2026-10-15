import 'package:authentication_client/authentication_client.dart';
import 'package:evently_vendor/app/app.dart';
import 'package:evently_vendor/auth/mobile_number/view/mobile_number_page.dart';
import 'package:evently_vendor/auth/mobile_number/widgets/mobile_number_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late AuthenticationClient client;

  setUp(() => client = MockAuthenticationClient());

  /// Hosts the page in a router so navigation to OTP is observable.
  GoRouter router() {
    return GoRouter(
      initialLocation: AppRoutes.phoneNumber,
      routes: [
        GoRoute(
          path: AppRoutes.phoneNumber,
          builder: (_, _) => const MobileNumberPage(),
        ),
        GoRoute(
          path: AppRoutes.verifyOtp,
          builder: (_, state) => Text('OTP for ${state.extra}'),
        ),
      ],
    );
  }

  testWidgets('renders and enables Continue for a valid number', (
    tester,
  ) async {
    await tester.pumpApp(
      const MobileNumberPage(),
      authenticationClient: client,
    );

    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(find.byType(MobileNumberInputField), findsOneWidget);
    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
  });

  testWidgets('explains an invalid full-length number', (tester) async {
    await tester.pumpApp(
      const MobileNumberPage(),
      authenticationClient: client,
    );
    await tester.enterText(find.byType(TextField), '1234567890');
    await tester.pump();
    expect(
      find.text('Enter a valid 10-digit Indian mobile number.'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to OTP verification after the code is sent', (
    tester,
  ) async {
    when(
      () => client.sendOtp(phoneNumber: '+919876543210'),
    ).thenAnswer((_) async {});
    await tester.pumpRouterApp(router(), authenticationClient: client);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('OTP for +919876543210'), findsOneWidget);
  });

  testWidgets('stays on the page and shows an error when sending fails', (
    tester,
  ) async {
    when(
      () => client.sendOtp(phoneNumber: any(named: 'phoneNumber')),
    ).thenThrow(const SendOtpFailure(AuthFailureReason.network, 'offline'));
    await tester.pumpRouterApp(router(), authenticationClient: client);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('OTP for'), findsNothing);
    expect(find.text('Enter your mobile number'), findsOneWidget);
    expect(
      find.text(
        "Couldn't connect. Check your internet connection and try again.",
      ),
      findsOneWidget,
    );
  });
}
