import 'package:evently_vendor/auth/mobile_number/view/mobile_number_page.dart';
import 'package:evently_vendor/auth/mobile_number/widgets/mobile_number_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileNumberPage', () {
    testWidgets('renders MobileNumberPage', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNumberPage(),
        ),
      );

      expect(find.text('Enter your mobile number'), findsOneWidget);
      expect(find.byType(MobileNumberInputField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('entering phone number enables Continue button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: MobileNumberPage(),
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
