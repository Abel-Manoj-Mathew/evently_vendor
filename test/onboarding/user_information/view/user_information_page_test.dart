import 'package:evently_vendor/onboarding/user_information/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserInformationPage', () {
    testWidgets('renders all widgets correctly', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<UserRepository>.value(
          value: MockUserRepository(),
          child: const MaterialApp(
            home: UserInformationPage(),
          ),
        ),
      );

      expect(find.text('Tell us about yourself'), findsOneWidget);
      expect(
        find.text("We'll use your name to personalize your workspace."),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('First Name'),
        ),
        findsOneWidget,
      );
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('entering first name enables Continue button', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<UserRepository>.value(
          value: MockUserRepository(),
          child: const MaterialApp(
            home: UserInformationPage(),
          ),
        ),
      );

      final firstNameFinder = find.widgetWithText(TextField, 'First name');
      await tester.enterText(firstNameFinder, 'John');
      await tester.pump();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(buttonFinder);

      expect(button.onPressed, isNotNull);
    });

    test('route returns MaterialPageRoute', () {
      final route = UserInformationPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
