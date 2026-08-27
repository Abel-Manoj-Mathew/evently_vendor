import 'package:evently_vendor/auth/mobile_number/bloc/mobile_number_bloc.dart';
import 'package:evently_vendor/auth/mobile_number/view/mobile_number_page.dart';
import 'package:evently_vendor/auth/mobile_number/view/mobile_number_view.dart';
import 'package:evently_vendor/auth/mobile_number/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileNumberPage', () {
    testWidgets('renders MobileNumberView', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNumberPage(),
        ),
      );

      expect(find.byType(MobileNumberView), findsOneWidget);
      expect(find.text('Enter your mobile number'), findsOneWidget);
      expect(find.byType(MobileNumberInputField), findsOneWidget);
      expect(find.byType(SecurityNoteCard), findsOneWidget);
      expect(find.byType(SendOtpButton), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = MobileNumberPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });

    testWidgets('entering phone number enables Send OTP button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MobileNumberBloc(),
            child: MobileNumberView(
              onBackPressed: () {},
              onSendOtpPressed: () {},
            ),
          ),
        ),
      );

      // Button is initially disabled
      final buttonFinder = find.byType(ElevatedButton);
      var button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      // Enter 10-digit phone number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pump();

      // Button is now enabled
      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });
  });
}
