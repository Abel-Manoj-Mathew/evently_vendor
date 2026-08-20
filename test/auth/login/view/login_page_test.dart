import 'package:evently_vendor/auth/login/view/login_page.dart';
import 'package:evently_vendor/auth/login/widgets/widgets.dart';
import 'package:evently_vendor/auth/mobile_number/mobile_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders all widgets and invokes callbacks', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      await tester.tap(find.byType(MobileLoginButton));
      expect(continuePressed, isTrue);
    });

    testWidgets('navigates to MobileNumberPage when MobileLoginButton is tapped',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.tap(find.byType(MobileLoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(MobileNumberPage), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = LoginPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
