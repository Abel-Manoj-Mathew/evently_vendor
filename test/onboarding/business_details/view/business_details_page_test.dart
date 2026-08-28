import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/onboarding/business_details/business_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

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
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<BusinessRepository>.value(
          value: businessRepository,
          child: const MaterialApp(
            home: BusinessDetailsPage(),
          ),
        ),
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
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          RepositoryProvider<BusinessRepository>.value(
            value: businessRepository,
            child: const MaterialApp(
              home: BusinessDetailsPage(),
            ),
          ),
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
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        RepositoryProvider<BusinessRepository>.value(
          value: businessRepository,
          child: const MaterialApp(
            home: BusinessDetailsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewAllFinder = find.text('+ View All Categories');
      await tester.ensureVisible(viewAllFinder);
      await tester.tap(viewAllFinder);
      await tester.pumpAndSettle();

      expect(find.text('- Show Fewer Categories'), findsOneWidget);
      expect(find.text('Venue Provider'), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = BusinessDetailsPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
