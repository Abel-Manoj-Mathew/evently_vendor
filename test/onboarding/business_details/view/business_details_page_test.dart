import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/onboarding/business_details/business_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

void main() {
  late MockBusinessRepository businessRepository;

  setUp(() {
    businessRepository = MockBusinessRepository();
    when(() => businessRepository.getCategories()).thenAnswer(
      (_) async => [
        'Photographer',
        'Videographer',
        'Caterer',
        'Decorator',
        'DJ',
        'Makeup Artist',
        'Venue Provider',
      ],
    );
  });

  group('BusinessDetailsPage', () {
    testWidgets('renders all widgets correctly', (tester) async {
      await tester.pumpApp(
        BusinessDetailsPage(onBack: () {}, onSaved: () {}),
        businessRepository: businessRepository,
      );
      await tester.pumpAndSettle();

      expect(find.text('What business do you manage?'), findsOneWidget);
      expect(
        find.text(
          "This is the business you'll manage in Evently. "
          'You can update these details anytime.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('What should we call your business?'),
        findsOneWidget,
      );
      expect(find.text('SELECTED'), findsOneWidget);
      expect(find.text('CHOOSE CATEGORIES'), findsOneWidget);
      expect(
        find.text('You can select multiple categories.'),
        findsOneWidget,
      );
      expect(find.text('+ View All Categories'), findsOneWidget);
      expect(
        find.text('Business details can be changed later.'),
        findsOneWidget,
      );
      expect(find.text('Create Business'), findsOneWidget);
    });

    testWidgets(
      'filling business name with category selected '
      'enables Create Business button',
      (tester) async {
        await tester.pumpApp(
          BusinessDetailsPage(onBack: () {}, onSaved: () {}),
          businessRepository: businessRepository,
        );
        await tester.pumpAndSettle();

        final businessNameFinder = find.widgetWithText(
          TextField,
          'e.g. Abel Photography',
        );
        await tester.enterText(businessNameFinder, 'Abel Photography');
        await tester.pump();

        final buttonFinder = find.widgetWithText(
          ElevatedButton,
          'Create Business',
        );
        final button = tester.widget<ElevatedButton>(buttonFinder);

        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('toggling View All Categories expands category chips', (
      tester,
    ) async {
      await tester.pumpApp(
        BusinessDetailsPage(onBack: () {}, onSaved: () {}),
        businessRepository: businessRepository,
      );
      await tester.pumpAndSettle();

      final viewAllFinder = find.text('+ View All Categories');
      await tester.ensureVisible(viewAllFinder);
      await tester.tap(viewAllFinder);
      await tester.pumpAndSettle();

      expect(find.text('- Show Fewer Categories'), findsOneWidget);
      expect(find.text('Venue Provider'), findsOneWidget);
    });

    testWidgets('creates the business for the signed-in user', (
      tester,
    ) async {
      when(
        () => businessRepository.createBusiness(
          ownerId: any(named: 'ownerId'),
          businessName: any(named: 'businessName'),
          categories: any(named: 'categories'),
        ),
      ).thenAnswer(
        (_) async => const Business(
          id: 'b1',
          ownerId: 'user-1',
          name: 'Abel Photography',
        ),
      );
      var saved = false;
      await tester.pumpApp(
        BusinessDetailsPage(onBack: () {}, onSaved: () => saved = true),
        businessRepository: businessRepository,
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Abel Photography'),
        'Abel Photography',
      );
      await tester.pump();
      final button = find.widgetWithText(ElevatedButton, 'Create Business');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(
        () => businessRepository.createBusiness(
          ownerId: testUser.id,
          businessName: 'Abel Photography',
          categories: ['Photographer'],
        ),
      ).called(1);
      expect(saved, isTrue);
    });

    testWidgets('offers retry when categories cannot be loaded', (
      tester,
    ) async {
      when(
        () => businessRepository.getCategories(),
      ).thenThrow(Exception('offline'));
      await tester.pumpApp(
        BusinessDetailsPage(onBack: () {}, onSaved: () {}),
        businessRepository: businessRepository,
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          "Couldn't load business categories. Check your connection.",
        ),
        findsOneWidget,
      );
      expect(
        find.text('Failed to create business. Please try again.'),
        findsNothing,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
