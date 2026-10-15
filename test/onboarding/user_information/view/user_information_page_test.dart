import 'package:evently_vendor/onboarding/user_information/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('UserInformationPage', () {
    testWidgets('renders all widgets correctly', (tester) async {
      await tester.pumpApp(
        UserInformationPage(onBack: () {}, onSaved: () {}),
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
      await tester.pumpApp(
        UserInformationPage(onBack: () {}, onSaved: () {}),
      );

      final firstNameFinder = find.widgetWithText(TextField, 'First name');
      await tester.enterText(firstNameFinder, 'John');
      await tester.pump();

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Continue');
      final button = tester.widget<ElevatedButton>(buttonFinder);

      expect(button.onPressed, isNotNull);
    });

    testWidgets('saves the profile for the signed-in user', (tester) async {
      final userRepository = MockUserRepository();
      when(
        () => userRepository.updateProfile(
          id: any(named: 'id'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async {});
      var saved = false;
      await tester.pumpApp(
        UserInformationPage(onBack: () {}, onSaved: () => saved = true),
        userRepository: userRepository,
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'First name'),
        'Abel',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      verify(
        () => userRepository.updateProfile(
          id: testUser.id,
          firstName: 'Abel',
          lastName: '',
          phone: testUser.phone,
        ),
      ).called(1);
      expect(saved, isTrue);
    });

    testWidgets('back button uses the provided callback', (tester) async {
      var backPressed = false;
      await tester.pumpApp(
        UserInformationPage(
          onBack: () => backPressed = true,
          onSaved: () {},
          backTooltip: 'Sign out',
        ),
      );
      await tester.tap(find.byTooltip('Sign out'));
      expect(backPressed, isTrue);
    });
  });
}
