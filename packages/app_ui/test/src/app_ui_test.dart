import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUi Design System', () {
    test('AppColors primary evaluates to Evently coral red (#FF4040)', () {
      expect(AppColors.primary, equals(const Color(0xFFFF4040)));
    });

    test('AppTheme light theme provides valid ThemeData', () {
      final theme = const AppTheme().theme;
      expect(theme.primaryColor, equals(AppColors.primary));
      expect(theme.brightness, equals(Brightness.light));
    });

    test('AppDarkTheme dark theme provides valid ThemeData', () {
      final darkTheme = const AppDarkTheme().theme;
      expect(darkTheme.primaryColor, equals(AppColors.primary));
      expect(darkTheme.brightness, equals(Brightness.dark));
    });

    testWidgets('AppButton renders text and responds to taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('AppTextField renders label and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              labelText: 'Phone Number',
              hintText: 'Enter 10-digit number',
            ),
          ),
        ),
      );

      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Enter 10-digit number'), findsOneWidget);
    });
  });
}
