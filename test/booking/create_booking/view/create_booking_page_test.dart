import 'package:evently_vendor/booking/create_booking/create_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateBookingPage', () {
    testWidgets('renders top bar, search input, recent customers and bottom button',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      expect(find.text('Create Booking'), findsOneWidget);
      expect(find.text('Select a customer'), findsOneWidget);
      expect(
        find.text('Search an existing customer or create a new one.'),
        findsOneWidget,
      );
      expect(
        find.text('Search by customer name or mobile number'),
        findsOneWidget,
      );
      expect(find.text('RECENT CUSTOMERS'), findsOneWidget);
      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Marcus Rivera'), findsOneWidget);
      expect(find.text('Priya Nair'), findsOneWidget);
      expect(find.text('Tom Okafor'), findsOneWidget);
      expect(find.text('+ New Customer'), findsOneWidget);
    });

    testWidgets('filtering search updates customer list', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Sarah');
      await tester.pump();

      expect(find.text('Sarah Johnson'), findsOneWidget);
      expect(find.text('Marcus Rivera'), findsNothing);
    });

    testWidgets('tapping customer row triggers selection', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateBookingPage(),
        ),
      );

      await tester.tap(find.text('Sarah Johnson'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    test('route returns MaterialPageRoute', () {
      final route = CreateBookingPage.route();
      expect(route, isA<MaterialPageRoute<void>>());
    });
  });
}
