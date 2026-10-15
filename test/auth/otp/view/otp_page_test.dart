import 'dart:async';

import 'package:authentication_client/authentication_client.dart';
import 'package:evently_vendor/auth/otp/otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

const _phone = '+919876543210';

void main() {
  late AuthenticationClient client;

  setUp(() => client = MockAuthenticationClient());

  Future<void> pumpOtpPage(WidgetTester tester) => tester.pumpApp(
    const OtpPage(phoneNumber: _phone),
    authenticationClient: client,
  );

  testWidgets('shows the number the code was sent to', (tester) async {
    await pumpOtpPage(tester);
    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('RESEND AVAILABLE IN'), findsOneWidget);
  });

  testWidgets('shows feedback and clears the code for an invalid OTP', (
    tester,
  ) async {
    when(
      () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
    ).thenThrow(
      const VerifyOtpFailure(AuthFailureReason.invalidOrExpiredCode, 'x'),
    );
    await pumpOtpPage(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('otp_error_text')), findsOneWidget);
    expect(
      find.text(
        'That code is incorrect or has expired. Check the SMS or request a '
        'new code.',
      ),
      findsOneWidget,
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, isEmpty);

    // Typing again clears the error.
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(find.byKey(const Key('otp_error_text')), findsNothing);
  });

  testWidgets('shows a network message when verification cannot connect', (
    tester,
  ) async {
    when(
      () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
    ).thenThrow(const VerifyOtpFailure(AuthFailureReason.network, 'x'));
    await pumpOtpPage(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        "Couldn't connect. Check your internet connection and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('disables input while verifying', (tester) async {
    final completer = Completer<void>();
    when(
      () => client.verifyOtp(phoneNumber: _phone, code: '123456'),
    ).thenAnswer((_) => completer.future);
    await pumpOtpPage(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete();
    await tester.pump();
  });

  testWidgets('offers resend after the cooldown', (tester) async {
    when(() => client.sendOtp(phoneNumber: _phone)).thenAnswer((_) async {});
    await pumpOtpPage(tester);

    await tester.pump(const Duration(seconds: OtpView.resendCooldown));
    await tester.tap(find.text('Resend OTP'));
    await tester.pump();
    await tester.pump();

    verify(() => client.sendOtp(phoneNumber: _phone)).called(1);
    expect(find.text('A new code has been sent.'), findsOneWidget);
    expect(find.text('RESEND AVAILABLE IN'), findsOneWidget);
  });
}
